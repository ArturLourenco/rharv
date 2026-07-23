#' Plot a rainwater harvesting simulation
#'
#' Draws the daily series of a [rh_simulate()] result: reservoir storage,
#' captured volume (inflow) and deficit over time. Requires the \pkg{ggplot2}
#' package.
#'
#' @param object,x A `rharv_sim` object from [rh_simulate()].
#' @param vars Character vector of series to draw; any of `"storage"`,
#'   `"captured"`, `"overflow"`, `"supplied"`, `"deficit"`. Defaults to
#'   storage, captured and deficit.
#' @param ... Passed on (currently unused).
#'
#' @return A \pkg{ggplot2} object.
#' @exportS3Method ggplot2::autoplot
#' @examples
#' sim <- rh_simulate(rep(c(0, 0, 30, 0, 50), 10), demand = 0.4,
#'                    area = 775.53, capacity = 5)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::autoplot(sim)
#' }
autoplot.rharv_sim <- function(object, vars = c("storage", "captured", "deficit"), ...) {
  rlang::check_installed("ggplot2", reason = "to plot a `rharv_sim`.")
  vars <- match.arg(vars, c("storage", "captured", "overflow", "supplied", "deficit"),
                    several.ok = TRUE)
  df <- object$series
  long <- do.call(rbind, lapply(vars, function(v) {
    data.frame(step = df$step, variable = v, value = df[[v]])
  }))
  long$variable <- factor(long$variable, levels = vars)
  ggplot2::ggplot(
    long,
    ggplot2::aes(x = .data$step, y = .data$value, colour = .data$variable)
  ) +
    ggplot2::geom_line() +
    ggplot2::labs(x = "Time step", y = "Volume (m3)", colour = NULL) +
    ggplot2::theme_minimal()
}

#' @rdname autoplot.rharv_sim
#' @export
plot.rharv_sim <- function(x, vars = c("storage", "captured", "deficit"), ...) {
  print(autoplot.rharv_sim(x, vars = vars, ...))
  invisible(x)
}

#' Day-of-year precipitation climatology heatmap
#'
#' Aggregates a daily precipitation series to a month-by-day climatology and
#' draws it as a tile heatmap (the "precipitation matrix"). Requires the
#' \pkg{ggplot2} package.
#'
#' @param data A data frame with a date column and a value column.
#' @param date_col,value_col Column names (strings) holding the dates and the
#'   precipitation values. Default `"date"` and `"value"`.
#' @param fun Aggregation function applied per calendar day across years.
#'   Default [mean()].
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_climatology(precip_pi)
#' }
rh_plot_climatology <- function(data, date_col = "date", value_col = "value",
                                fun = mean) {
  rlang::check_installed("ggplot2", reason = "to draw the climatology heatmap.")
  stopifnot(is.data.frame(data), date_col %in% names(data), value_col %in% names(data))
  dts <- as.Date(data[[date_col]])
  month <- as.integer(format(dts, "%m"))
  day <- as.integer(format(dts, "%d"))
  agg <- stats::aggregate(
    list(value = data[[value_col]]),
    by = list(month = month, day = day),
    FUN = fun, na.rm = TRUE
  )
  ggplot2::ggplot(
    agg,
    ggplot2::aes(x = .data$month, y = .data$day, fill = .data$value)
  ) +
    ggplot2::geom_tile(colour = "grey90", linewidth = 0.2) +
    ggplot2::scale_x_continuous(breaks = 1:12) +
    ggplot2::scale_fill_gradient(low = "lightyellow", high = "darkblue") +
    ggplot2::labs(x = "Month", y = "Day", fill = "P (mm)") +
    ggplot2::theme_minimal()
}
