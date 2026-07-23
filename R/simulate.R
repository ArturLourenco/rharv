#' Daily water-balance simulation of a rainwater harvesting reservoir
#'
#' Simulates the daily operation of a finite rainwater reservoir using the
#' *method of simulation* of ABNT NBR 15527:2007 (Annex A.2), with the
#' available-volume equation of NBR 15527:2019 (see [rh_available_volume()]).
#' The mass-balance (continuity) equation for a finite reservoir is
#'
#' \deqn{S(t) = Q(t) + S(t-1) - D(t), \quad 0 \le S(t) \le V}
#'
#' where `Q(t)` is the captured volume, `D(t)` the demand and `V` the reservoir
#' capacity. Evaporation is not considered. Following the standard, the reservoir
#' is assumed full at the start (`initial = capacity` by default).
#'
#' @inheritParams rh_available_volume
#' @param demand Non-potable demand per time step, in cubic metres (m3). Scalar
#'   or vector recycled to `length(precip)`.
#' @param capacity Reservoir capacity `V`, in cubic metres (m3).
#' @param initial Initial stored volume `S(0)`, in cubic metres (m3). Defaults to
#'   `capacity` (a full reservoir, per the NBR 15527:2007 A.2 hypothesis). Must
#'   not exceed `capacity`.
#' @param overflow_timing Order of operations within a time step:
#'   * `"after_demand"` (default): inflow is added, demand is withdrawn, and only
#'     the remainder can overflow. This is the continuity-equation form
#'     `S(t) = S(t-1) + Q(t) - D(t)` clamped to `[0, V]`, the YBS (yield before
#'     spillage) operating rule of the rainwater-tank literature (Jenkins et
#'     al., 1978; Fewkes and Butler, 2000), and reproduces the published
#'     case-study results.
#'   * `"before_demand"`: inflow is added and the reservoir overflows before
#'     demand is withdrawn, the YAS (yield after spillage) rule. It spills more
#'     water, giving slightly conservative yields, and is provided for
#'     sensitivity analysis.
#'
#' @return An object of class `rharv_sim`: a list with elements `series` (a
#'   data frame with one row per time step and columns `step`, `captured`,
#'   `overflow`, `supplied`, `deficit`, `storage`), `inputs` (the parameters
#'   used) and `summary` (the metrics returned by [rh_metrics()]). The
#'   [print()] and [summary()] methods give a quick overview.
#' @export
#' @examples
#' precip <- c(0, 0, 25, 0, 40, 0, 0)
#' sim <- rh_simulate(precip, demand = 0.5, area = 775.53, capacity = 5)
#' sim
#' rh_metrics(sim)
rh_simulate <- function(precip, demand, area, capacity,
                        runoff = 0.8, efficiency = 0.85, initial = capacity,
                        overflow_timing = c("after_demand", "before_demand")) {
  overflow_timing <- match.arg(overflow_timing)
  .check_number(precip, "precip", lower = 0, allow_vector = TRUE)
  n <- length(precip)
  .check_number(capacity, "capacity", lower = 0)
  .check_number(initial, "initial", lower = 0)
  if (initial > capacity) {
    rlang::abort("`initial` cannot exceed `capacity`.")
  }
  demand <- .recycle(demand, n, "demand")
  .check_number(demand, "demand", lower = 0, allow_vector = TRUE)

  captured <- rh_available_volume(precip, area, runoff, efficiency)

  overflow <- numeric(n)
  supplied <- numeric(n)
  deficit <- numeric(n)
  storage <- numeric(n)
  s <- initial

  for (t in seq_len(n)) {
    if (overflow_timing == "before_demand") {
      pool <- s + captured[t]
      ov <- max(pool - capacity, 0)
      pool <- pool - ov
      sup <- min(pool, demand[t])
      s <- pool - sup
    } else {
      # after_demand: continuity equation, demand has priority over spilling
      vp <- s + captured[t] - demand[t]
      ov <- max(vp - capacity, 0)
      sup <- min(demand[t], s + captured[t])
      s <- min(max(vp, 0), capacity)
    }
    overflow[t] <- ov
    supplied[t] <- sup
    deficit[t] <- demand[t] - sup
    storage[t] <- s
  }

  series <- data.frame(
    step = seq_len(n),
    captured = captured,
    overflow = overflow,
    supplied = supplied,
    deficit = deficit,
    storage = storage
  )
  inputs <- list(
    n = n,
    area = sum(area),
    capacity = capacity,
    initial = initial,
    runoff = runoff,
    efficiency = efficiency,
    overflow_timing = overflow_timing,
    demand = demand
  )
  structure(
    list(
      series = series,
      inputs = inputs,
      summary = .compute_metrics(series, inputs)
    ),
    class = "rharv_sim"
  )
}
