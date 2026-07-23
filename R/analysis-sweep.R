#' Sweep one design parameter and record performance metrics
#'
#' Runs [rh_simulate()] repeatedly while varying a single parameter, keeping the
#' others fixed, and collects one or more summary metrics. Useful to see how the
#' system responds to a single "lever" (e.g. reliability versus reservoir
#' capacity). Returns a plain data frame, so it works without \pkg{ggplot2}.
#'
#' @param precip Numeric vector of daily precipitation (mm). If
#'   `climatology = TRUE`, it is first collapsed to its day-of-year mean (see
#'   `dates`).
#' @param base A named list of the fixed arguments passed to [rh_simulate()]
#'   (e.g. `list(demand = 6.6, area = 4170, capacity = 400, runoff = 0.85,
#'   efficiency = 1)`). Must supply every required argument except the one being
#'   swept.
#' @param param Name of the parameter to vary: one of `"demand"`, `"area"`,
#'   `"capacity"`, `"runoff"`, `"efficiency"`, `"initial"`.
#' @param values Numeric vector of values for `param`.
#' @param metrics Character vector of metric names to record (any of the columns
#'   of [rh_metrics()]); default `"attendance_pct"`.
#' @param dates Optional date vector aligned with `precip`, required only when
#'   `climatology = TRUE`.
#' @param climatology If `TRUE`, simulate on the day-of-year climatology (much
#'   faster) instead of the full series. Default `FALSE`.
#'
#' @return A data frame with one column named after `param` (the swept values)
#'   plus one column per requested metric.
#' @seealso [rh_grid()] for two parameters at once.
#' @export
#' @examples
#' caps <- seq(50, 600, by = 50)
#' rh_sweep(precip_pi$value, base = list(demand = 6.6, area = 4170),
#'          param = "capacity", values = caps,
#'          metrics = c("attendance_pct", "reliability_pct"))
rh_sweep <- function(precip, base = list(), param, values,
                     metrics = "attendance_pct", dates = NULL,
                     climatology = FALSE) {
  param <- match.arg(param, c("demand", "area", "capacity", "runoff",
                              "efficiency", "initial"))
  for (m in metrics) .metric_col(m)
  if (isTRUE(climatology)) precip <- .climatology(precip, dates)

  rows <- lapply(values, function(v) {
    args <- base
    args[[param]] <- v
    cbind(stats::setNames(data.frame(v), param),
          .sim_metrics(precip, args, metrics))
  })
  do.call(rbind, rows)
}

#' Two-parameter grid of performance metrics
#'
#' Runs [rh_simulate()] over a grid of two design parameters (by default
#' catchment area and reservoir capacity) and records performance metrics. This
#' is the data behind the area-capacity-demand trade-off surface
#' ([rh_plot_tradeoff()]).
#'
#' Each grid cell is one simulation. On a multi-decade daily series this is a few
#' hundred simulations (tens of seconds); for interactive use set
#' `climatology = TRUE` to simulate on the day-of-year mean (around 70x faster).
#'
#' @inheritParams rh_sweep
#' @param x,y Names of the two parameters to vary (each one of `"demand"`,
#'   `"area"`, `"capacity"`, `"runoff"`, `"efficiency"`, `"initial"`); defaults
#'   `x = "area"`, `y = "capacity"`.
#' @param x_values,y_values Numeric vectors of values for `x` and `y`.
#'
#' @return A long data frame with columns named after `x` and `y`, plus `metric`
#'   and `value`. The names of the two swept parameters are also stored in
#'   `attr(, "x")` and `attr(, "y")`.
#' @export
#' @examples
#' g <- rh_grid(precip_pi$value,
#'              base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
#'              x = "area", x_values = seq(500, 5000, length.out = 8),
#'              y = "capacity", y_values = seq(100, 1000, length.out = 8),
#'              dates = precip_pi$date, climatology = TRUE)
#' head(g)
rh_grid <- function(precip, base = list(), x = "area", x_values,
                    y = "capacity", y_values, metrics = "attendance_pct",
                    dates = NULL, climatology = FALSE) {
  choices <- c("demand", "area", "capacity", "runoff", "efficiency", "initial")
  x <- match.arg(x, choices)
  y <- match.arg(y, choices)
  if (x == y) rlang::abort("`x` and `y` must be different parameters.")
  for (m in metrics) .metric_col(m)
  if (isTRUE(climatology)) precip <- .climatology(precip, dates)

  cells <- expand.grid(xv = x_values, yv = y_values)
  rows <- lapply(seq_len(nrow(cells)), function(i) {
    args <- base
    args[[x]] <- cells$xv[i]
    args[[y]] <- cells$yv[i]
    vals <- .sim_metrics(precip, args, metrics)
    do.call(rbind, lapply(metrics, function(m) {
      data.frame(xv = cells$xv[i], yv = cells$yv[i], metric = m,
                 value = vals[[m]])
    }))
  })
  res <- do.call(rbind, rows)
  names(res)[1:2] <- c(x, y)
  attr(res, "x") <- x
  attr(res, "y") <- y
  res
}
