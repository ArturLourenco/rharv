#' Size a parameter to reach a target guarantee level
#'
#' Generalises the zero-deficit sizing functions ([rh_guaranteed_capacity()] etc.)
#' to any guarantee level: it finds the value of one design parameter
#' (`"capacity"`, `"area"` or `"demand"`) at which a chosen guarantee metric
#' reaches `target_value`. Because the metric is monotone in each parameter the
#' search is a bisection: for capacity/area it returns the *smallest* value that
#' reaches the target; for demand the *largest* value that still does.
#'
#' @inheritParams rh_sweep
#' @param base Named list of the fixed [rh_simulate()] arguments (everything
#'   except `vary`).
#' @param vary Parameter to solve for: `"capacity"`, `"area"` or `"demand"`.
#' @param target_value Target guarantee value (e.g. `95` for 95 percent).
#' @param metric Guarantee metric: `"attendance_pct"` (default, volumetric) or
#'   `"reliability_pct"` (time-based).
#' @param tol Search tolerance (in units of `vary`).
#' @param max Optional upper bound for the search; grown automatically if needed.
#'
#' @return A single numeric value of `vary`.
#' @seealso [rh_iso_curve()], [rh_resource_curve()].
#' @export
#' @examples
#' # capacity needed for 90% volumetric attendance
#' rh_size_for(precip_pi$value,
#'             base = list(demand = 6.6, area = 4170, runoff = 0.85, efficiency = 1),
#'             vary = "capacity", target_value = 90,
#'             dates = precip_pi$date, climatology = TRUE)
rh_size_for <- function(precip, base = list(), vary, target_value,
                        metric = "attendance_pct", tol = 1e-2, max = NULL,
                        dates = NULL, climatology = FALSE) {
  vary <- match.arg(vary, c("capacity", "area", "demand"))
  metric <- .metric_col(metric)
  if (!metric %in% c("attendance_pct", "reliability_pct")) {
    rlang::abort("`metric` must be 'attendance_pct' or 'reliability_pct'.")
  }
  .check_number(target_value, "target_value", lower = 1e-9, upper = 100)
  needed <- setdiff(c("demand", "area", "capacity"), vary)
  missing_args <- needed[!needed %in% names(base)]
  if (length(missing_args)) {
    rlang::abort(sprintf(
      "`base` must contain '%s' when solving for '%s'.",
      paste(missing_args, collapse = "', '"), vary
    ))
  }
  if (isTRUE(climatology)) precip <- .climatology(precip, dates)
  n <- length(precip)

  value_at <- function(v) {
    args <- base
    args[[vary]] <- v
    # When searching capacities below a fixed `initial`, clamp it (same
    # semantics as rh_guaranteed_capacity): the reservoir cannot start fuller
    # than the trial capacity.
    if (vary == "capacity" && !is.null(args$initial)) {
      args$initial <- min(args$initial, v)
    }
    do.call(rh_simulate, c(list(precip = precip), args))$summary[[metric]]
  }
  feasible <- function(v) value_at(v) >= target_value - 1e-9

  if (vary == "demand") {
    cap <- rh_available_volume(precip, base$area, base$runoff %||% 0.8,
                               base$efficiency %||% 0.85)
    # Start from the zero-deficit bound, then GROW while still feasible: for
    # targets below 100% the largest demand reaching the target exceeds the
    # zero-deficit maximum (attendance ~ supplied/demand keeps falling as
    # demand grows past it).
    upper <- max %||% ((sum(cap) + (base$initial %||% base$capacity)) / n)
    if (!is.finite(upper) || upper <= 0) upper <- 1
    if (is.null(max)) {
      k <- 0
      while (feasible(upper) && k < 60) {
        upper <- upper * 2
        k <- k + 1
      }
    }
    .bisect_max(feasible, upper = upper, tol = tol)
  } else {
    upper <- max %||% (if (vary == "capacity") {
      sum(.recycle(base$demand, n, "demand"))
    } else {
      1000
    })
    k <- 0
    while (!feasible(upper) && k < 60) {
      upper <- upper * 2
      k <- k + 1
    }
    if (!feasible(upper)) {
      rlang::abort(sprintf("Target %s = %g not reachable by '%s'; raise `max`.",
                           metric, target_value, vary))
    }
    .bisect_min(feasible, upper = upper, tol = tol)
  }
}

#' Iso-guarantee design curves
#'
#' Builds the "design curve" data behind [rh_plot_iso()]: for each target
#' guarantee level and each value of the x-parameter, it solves (via
#' [rh_size_for()]) for the y-parameter that reaches that level. The result is a
#' family of iso-guarantee curves relating two design levers (the third is fixed
#' in `base`), the rainwater-harvesting analogue of a reservoir design chart.
#'
#' @inheritParams rh_size_for
#' @param x,y The two parameters to relate (each `"area"`, `"capacity"` or
#'   `"demand"`); `x` is the axis you set, `y` is solved for.
#' @param x_values Numeric values of `x`.
#' @param levels Target guarantee levels (default `c(80, 90, 95, 100)`).
#' @param by Optional third parameter to vary as panels/colour (e.g. `"demand"`).
#' @param by_values Values of `by` (required if `by` is set).
#'
#' @return A long data frame with columns named after `x`, `y`, plus `level`
#'   (and `by` if used). Unreachable points are `NA`. Axis names are stored in
#'   `attr(, "x")`, `attr(, "y")`, `attr(, "by")`, `attr(, "metric")`.
#' @export
#' @examples
#' iso <- rh_iso_curve(
#'   precip_pi$value, base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
#'   x = "area", x_values = seq(1000, 6000, length.out = 8),
#'   y = "capacity", levels = c(80, 90, 100),
#'   dates = precip_pi$date, climatology = TRUE
#' )
#' head(iso)
rh_iso_curve <- function(precip, base = list(), x, x_values, y,
                         levels = c(80, 90, 95, 100), metric = "attendance_pct",
                         by = NULL, by_values = NULL, tol = 1e-2,
                         dates = NULL, climatology = FALSE) {
  x <- match.arg(x, c("area", "capacity", "demand"))
  y <- match.arg(y, c("area", "capacity", "demand"))
  if (x == y) rlang::abort("`x` and `y` must be different.")
  metric <- .metric_col(metric)
  if (isTRUE(climatology)) {
    precip <- .climatology(precip, dates)
  }
  if (!is.null(by) && is.null(by_values)) {
    rlang::abort("`by_values` is required when `by` is set.")
  }
  by_grid <- if (is.null(by)) list(NULL) else by_values

  rows <- list()
  i <- 1L
  for (b in by_grid) {
    for (lv in levels) {
      for (xv in x_values) {
        base2 <- base
        base2[[x]] <- xv
        if (!is.null(by)) base2[[by]] <- b
        yv <- tryCatch(
          rh_size_for(precip, base2, vary = y, target_value = lv,
                      metric = metric, tol = tol),
          error = function(e) NA_real_
        )
        row <- data.frame(xv = xv, yv = yv, level = lv)
        if (!is.null(by)) row$byv <- b
        rows[[i]] <- row
        i <- i + 1L
      }
    }
  }
  res <- do.call(rbind, rows)
  names(res)[names(res) == "xv"] <- x
  names(res)[names(res) == "yv"] <- y
  if (!is.null(by)) names(res)[names(res) == "byv"] <- by
  attr(res, "x") <- x
  attr(res, "y") <- y
  attr(res, "by") <- by
  attr(res, "metric") <- metric
  res
}

#' Required resources versus guarantee level
#'
#' Builds the data behind [rh_plot_resource_curve()]: for each guarantee level,
#' the amount of each resource (reservoir capacity and/or catchment area)
#' required to reach it, at the operating point given in `base`. This is the
#' closest analogue to the reservoir stage-area-volume curve, with the guarantee
#' playing the role of the "stage".
#'
#' @inheritParams rh_size_for
#' @param base Named list with the operating point (`area`, `capacity`, `demand`,
#'   ...); each resource is solved for in turn while the others stay fixed.
#' @param levels Guarantee levels on the x-axis (default `seq(50, 100, by = 5)`).
#' @param resources Which resources to size: any of `"capacity"`, `"area"`,
#'   `"demand"`. Default `c("capacity", "area")`.
#'
#' @return A long data frame with columns `level, resource, value` (`NA` where a
#'   level is unreachable); the metric is in `attr(, "metric")`.
#' @export
#' @examples
#' rc <- rh_resource_curve(
#'   precip_pi$value,
#'   base = list(demand = 6.6, area = 4170, capacity = 400,
#'               runoff = 0.85, efficiency = 1),
#'   levels = seq(60, 100, by = 10),
#'   dates = precip_pi$date, climatology = TRUE
#' )
#' rc
rh_resource_curve <- function(precip, base = list(), levels = seq(50, 100, by = 5),
                              resources = c("capacity", "area"),
                              metric = "attendance_pct", tol = 1e-2,
                              dates = NULL, climatology = FALSE) {
  resources <- match.arg(resources, c("capacity", "area", "demand"),
                         several.ok = TRUE)
  metric <- .metric_col(metric)
  if (isTRUE(climatology)) {
    precip <- .climatology(precip, dates)
  }
  rows <- list()
  i <- 1L
  for (r in resources) {
    for (lv in levels) {
      val <- tryCatch(
        rh_size_for(precip, base, vary = r, target_value = lv,
                    metric = metric, tol = tol),
        error = function(e) NA_real_
      )
      rows[[i]] <- data.frame(level = lv, resource = r, value = val)
      i <- i + 1L
    }
  }
  res <- do.call(rbind, rows)
  attr(res, "metric") <- metric
  res
}
