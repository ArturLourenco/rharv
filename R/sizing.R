# Total deficit (m3) for a given set of engine parameters.
.deficit_for <- function(precip, demand, area, capacity, runoff, efficiency,
                         initial, overflow_timing) {
  sim <- rh_simulate(
    precip = precip, demand = demand, area = area, capacity = capacity,
    runoff = runoff, efficiency = efficiency, initial = initial,
    overflow_timing = overflow_timing
  )
  sim$summary$deficit_total
}

# Automatic optimiser-backed sizing via base R `stats::optimize`.
# `sense` is "max" to maximise the variable (guaranteed demand) or "min" to
# minimise it (capacity/area), subject to the zero-deficit constraint, which
# is enforced with a large penalty on any deficit above `tol`.
.size_optimize <- function(g, lower, upper, sense, tol) {
  penalty <- 1e6
  obj <- if (sense == "max") {
    function(x) x - penalty * max(g(x) - tol, 0)
  } else {
    function(x) -x - penalty * max(g(x) - tol, 0)
  }
  res <- stats::optimize(obj, lower = lower, upper = upper, maximum = TRUE, tol = tol)
  res$maximum
}

# Largest x in [0, upper] that is feasible (feasibility is TRUE up to a
# threshold and FALSE beyond it).
.bisect_max <- function(feasible, upper, tol) {
  if (feasible(upper)) {
    return(upper)
  }
  lo <- 0
  hi <- upper
  while (hi - lo > tol) {
    mid <- (lo + hi) / 2
    if (feasible(mid)) lo <- mid else hi <- mid
  }
  lo
}

# Smallest x in [0, upper] that is feasible (feasibility is FALSE up to a
# threshold and TRUE beyond it).
.bisect_min <- function(feasible, upper, tol) {
  if (feasible(0)) {
    return(0)
  }
  lo <- 0
  hi <- upper
  while (hi - lo > tol) {
    mid <- (lo + hi) / 2
    if (feasible(mid)) hi <- mid else lo <- mid
  }
  hi
}

#' Guarantee-based sizing of rainwater harvesting systems
#'
#' These functions find the design value that guarantees zero deficit over
#' the whole simulation, by repeatedly calling the engine [rh_simulate()]:
#'
#' * [rh_guaranteed_demand()] - the largest constant daily demand that can be
#'   met with no deficit (the *demanda garantia*).
#' * [rh_guaranteed_capacity()] - the smallest reservoir capacity giving no
#'   deficit (the *capacidade/volume garantia*). The reservoir is assumed full
#'   at the start, so `initial` follows the trial capacity unless set.
#' * [rh_required_area()] - the smallest catchment area giving no deficit.
#'
#' Because the total deficit is monotone in each of these variables, the default
#' solver is an efficient bisection controlled by `tol`. Two alternatives are
#' available: an automatic optimiser (`"optimize"`, base R [stats::optimize()])
#' and a simple incremental search (`"step"`, a `for`-loop advancing by `step`).
#'
#' @inheritParams rh_simulate
#' @param initial Initial stored volume `S(0)`, in cubic metres (m3). For
#'   [rh_guaranteed_demand()] and [rh_required_area()] it defaults to
#'   `capacity` (full reservoir). For [rh_guaranteed_capacity()] the default
#'   `NULL` makes the reservoir start full at each trial capacity, and an
#'   explicit value is clamped to the trial capacity during the search.
#' @param method Solver: `"bisection"` (default), `"optimize"` (automatic
#'   optimisation with [stats::optimize()]) or `"step"` (incremental search by
#'   `step`).
#' @param tol Tolerance: a deficit not greater than `tol` is treated as zero, and
#'   the solver stops when the search interval is narrower than `tol`.
#' @param step Increment for `method = "step"`. Defaults to one thousandth of the
#'   search upper bound.
#'
#' @return A single numeric value: the guaranteed demand (m3/day), guaranteed
#'   capacity (m3) or required area (m2).
#' @name rh_sizing
#' @examples
#' precip <- rep(c(0, 0, 30, 0, 0, 0, 50), 8)
#' rh_guaranteed_demand(precip, area = 775.53, capacity = 5)
#' rh_guaranteed_capacity(precip, demand = 0.4, area = 775.53)
#' rh_required_area(precip, demand = 0.4, capacity = 5)
NULL

#' @rdname rh_sizing
#' @export
rh_guaranteed_demand <- function(precip, area, capacity,
                                 runoff = 0.8, efficiency = 0.85, initial = capacity,
                                 overflow_timing = c("after_demand", "before_demand"),
                                 method = c("bisection", "optimize", "step"),
                                 tol = 1e-3, step = NULL) {
  overflow_timing <- match.arg(overflow_timing)
  method <- match.arg(method)
  n <- length(precip)
  captured <- rh_available_volume(precip, area, runoff, efficiency)
  # Demand above (total inflow + initial) / n always produces a deficit.
  upper <- (sum(captured) + initial) / n
  g <- function(d) {
    .deficit_for(precip, d, area, capacity, runoff, efficiency, initial, overflow_timing)
  }
  feasible <- function(d) g(d) <= tol

  if (method == "optimize") {
    return(.size_optimize(g, lower = 0, upper = upper, sense = "max", tol = tol))
  }
  if (method == "step") {
    by <- step %||% (upper / 1000)
    if (!is.finite(by) || by <= 0) {
      if (upper <= 0) return(0)
      rlang::abort("`step` must be a positive number.")
    }
    d <- 0
    while (d + by <= upper && feasible(d + by)) d <- d + by
    return(d)
  }
  .bisect_max(feasible, upper = upper, tol = tol)
}

#' @rdname rh_sizing
#' @param max_capacity Optional upper bound for the capacity search. Defaults to
#'   the total demand (which trivially guarantees no deficit), grown if needed.
#' @export
rh_guaranteed_capacity <- function(precip, demand, area,
                                   runoff = 0.8, efficiency = 0.85, initial = NULL,
                                   overflow_timing = c("after_demand", "before_demand"),
                                   method = c("bisection", "optimize", "step"),
                                   tol = 1e-3, step = NULL, max_capacity = NULL) {
  overflow_timing <- match.arg(overflow_timing)
  method <- match.arg(method)
  n <- length(precip)
  dem <- .recycle(demand, n, "demand")
  # If `initial` is NULL the reservoir starts full (initial = trial capacity).
  initial_of <- function(cap) if (is.null(initial)) cap else min(initial, cap)
  g <- function(cap) {
    .deficit_for(precip, dem, area, cap, runoff, efficiency, initial_of(cap), overflow_timing)
  }
  feasible <- function(cap) g(cap) <= tol

  # With an explicit `initial`, the problem can be structurally infeasible (a
  # tank cannot create water): detect it cheaply instead of doubling 50 times.
  if (!is.null(initial)) {
    inflow <- sum(rh_available_volume(precip, area, runoff, efficiency))
    if (inflow + initial < sum(dem) - tol) {
      rlang::abort(paste0(
        "Total inflow plus initial storage is below total demand; ",
        "no capacity can avoid a deficit (the system is supply-limited)."
      ))
    }
  }

  upper <- max_capacity %||% sum(dem)
  k <- 0
  while (!feasible(upper) && k < 50) {
    upper <- upper * 2
    k <- k + 1
  }
  if (!feasible(upper)) {
    rlang::abort("Could not find a feasible capacity; increase `max_capacity`.")
  }

  if (method == "optimize") {
    return(.size_optimize(g, lower = 0, upper = upper, sense = "min", tol = tol))
  }
  if (method == "step") {
    by <- step %||% (upper / 1000)
    if (!is.finite(by) || by <= 0) {
      if (upper <= 0) return(0)
      rlang::abort("`step` must be a positive number.")
    }
    cap <- 0
    while (cap < upper && !feasible(cap)) cap <- cap + by
    return(min(cap, upper))
  }
  .bisect_min(feasible, upper = upper, tol = tol)
}

#' @rdname rh_sizing
#' @param max_area Optional upper bound for the area search. Grown automatically
#'   until a feasible area is found.
#' @export
rh_required_area <- function(precip, demand, capacity,
                             runoff = 0.8, efficiency = 0.85, initial = capacity,
                             overflow_timing = c("after_demand", "before_demand"),
                             method = c("bisection", "optimize", "step"),
                             tol = 1e-3, step = NULL, max_area = NULL) {
  overflow_timing <- match.arg(overflow_timing)
  method <- match.arg(method)
  n <- length(precip)
  dem <- .recycle(demand, n, "demand")
  g <- function(a) {
    .deficit_for(precip, dem, a, capacity, runoff, efficiency, initial, overflow_timing)
  }
  feasible <- function(a) g(a) <= tol

  upper <- max_area %||% 1000
  k <- 0
  while (!feasible(upper) && k < 60) {
    upper <- upper * 2
    k <- k + 1
  }
  if (!feasible(upper)) {
    rlang::abort("Could not find a feasible area; increase `max_area`.")
  }

  if (method == "optimize") {
    return(.size_optimize(g, lower = 0, upper = upper, sense = "min", tol = tol))
  }
  if (method == "step") {
    by <- step %||% (upper / 1000)
    if (!is.finite(by) || by <= 0) {
      if (upper <= 0) return(0)
      rlang::abort("`step` must be a positive number.")
    }
    a <- 0
    while (a < upper && !feasible(a)) a <- a + by
    return(min(a, upper))
  }
  .bisect_min(feasible, upper = upper, tol = tol)
}
