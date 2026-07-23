#' Reservoir behaviour over time
#'
#' Plots the daily series of a [rh_simulate()] result (storage, captured inflow,
#' deficit, overflow, supplied). A richer companion to [autoplot.rharv_sim()]:
#' it can show more variables and use real dates on the x-axis.
#'
#' @param sim A `rharv_sim` object.
#' @param dates Optional date vector aligned with the simulation (same length as
#'   `sim$series`); if supplied, the x-axis uses dates instead of step index.
#' @param vars Variables to draw; any of `"storage"`, `"captured"`, `"supplied"`,
#'   `"deficit"`, `"overflow"`.
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' sim <- rh_simulate(precip_pi$value[1:1095], demand = 4, area = 4170,
#'                    capacity = 400, runoff = 0.85, efficiency = 1)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_behaviour(sim, dates = precip_pi$date[1:1095])
#' }
rh_plot_behaviour <- function(sim, dates = NULL,
                              vars = c("storage", "captured", "deficit", "overflow")) {
  rlang::check_installed("ggplot2", reason = "to plot reservoir behaviour.")
  stopifnot(inherits(sim, "rharv_sim"))
  vars <- match.arg(vars, c("storage", "captured", "supplied", "deficit", "overflow"),
                    several.ok = TRUE)
  s <- sim$series
  if (!is.null(dates)) {
    if (length(dates) != nrow(s)) rlang::abort("`dates` must match the simulation length.")
    xvar <- as.Date(dates)
    xlab <- "Date"
  } else {
    xvar <- s$step
    xlab <- "Time step"
  }
  long <- do.call(rbind, lapply(vars, function(v) {
    data.frame(x = xvar, variable = v, value = s[[v]])
  }))
  long$variable <- factor(long$variable, levels = vars)
  ggplot2::ggplot(long, ggplot2::aes(x = .data$x, y = .data$value, colour = .data$variable)) +
    ggplot2::geom_line() +
    ggplot2::labs(x = xlab, y = "Volume (m3)", colour = NULL) +
    ggplot2::theme_minimal()
}

#' Monthly water balance
#'
#' Aggregates the simulation to calendar months and draws grouped bars of the
#' main fluxes (captured, supplied, deficit, overflow) to expose seasonal
#' shortfalls. Requires `dates` because the simulation series is indexed by step,
#' not by date.
#'
#' @param sim A `rharv_sim` object.
#' @param dates Date vector aligned with the simulation (same length as `sim$series`).
#' @param vars Fluxes to aggregate; default captured/supplied/deficit/overflow.
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' sim <- rh_simulate(precip_pi$value, demand = 6.6, area = 4170, capacity = 400,
#'                    runoff = 0.85, efficiency = 1)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_monthly_balance(sim, dates = precip_pi$date)
#' }
rh_plot_monthly_balance <- function(sim, dates,
                                    vars = c("captured", "supplied", "deficit", "overflow")) {
  rlang::check_installed("ggplot2", reason = "to plot the monthly balance.")
  stopifnot(inherits(sim, "rharv_sim"))
  s <- sim$series
  if (length(dates) != nrow(s)) rlang::abort("`dates` must match the simulation length.")
  vars <- match.arg(vars, c("captured", "supplied", "deficit", "overflow", "storage"),
                    several.ok = TRUE)
  month <- as.integer(format(as.Date(dates), "%m"))
  agg <- stats::aggregate(s[vars], list(month = month), sum)
  long <- do.call(rbind, lapply(vars, function(v) {
    data.frame(month = agg$month, variable = v, value = agg[[v]])
  }))
  long$variable <- factor(long$variable, levels = vars)
  # Fixed 1:12 levels keep the month order right for series covering part of a year.
  long$month <- factor(long$month, levels = 1:12, labels = month.abb)
  ggplot2::ggplot(long, ggplot2::aes(x = .data$month, y = .data$value,
                                     fill = .data$variable)) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::labs(x = "Month", y = "Volume (m3, total over the period)", fill = NULL) +
    ggplot2::theme_minimal()
}

#' Failure (deficit) calendar
#'
#' Heatmap of daily deficit by year (y) and day-of-year (x), showing when
#' shortfalls occur and how they cluster in the dry season.
#'
#' @param sim A `rharv_sim` object.
#' @param dates Date vector aligned with the simulation (same length as `sim$series`).
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' sim <- rh_simulate(precip_pi$value, demand = 6.6, area = 4170, capacity = 400,
#'                    runoff = 0.85, efficiency = 1)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_failure_calendar(sim, dates = precip_pi$date)
#' }
rh_plot_failure_calendar <- function(sim, dates) {
  rlang::check_installed("ggplot2", reason = "to plot the failure calendar.")
  stopifnot(inherits(sim, "rharv_sim"))
  s <- sim$series
  if (length(dates) != nrow(s)) rlang::abort("`dates` must match the simulation length.")
  dts <- as.Date(dates)
  df <- data.frame(
    year = as.integer(format(dts, "%Y")),
    doy = as.integer(format(dts, "%j")),
    deficit = s$deficit
  )
  ggplot2::ggplot(df, ggplot2::aes(x = .data$doy, y = .data$year, fill = .data$deficit)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradient(low = "white", high = "firebrick") +
    ggplot2::labs(x = "Day of year", y = "Year", fill = "Deficit (m3)") +
    ggplot2::theme_minimal()
}
