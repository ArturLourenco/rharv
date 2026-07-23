#' Plot precipitation variability
#'
#' Draws the output of [rh_series_spread()]: the mean per group with a shaded
#' 10th-90th percentile band, highlighting how variable the rainfall is across
#' years (or months/days of the year).
#'
#' @param spread A data frame from [rh_series_spread()].
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' sp <- rh_series_spread(precip_pi, by = "year")
#' if (requireNamespace("ggplot2", quietly = TRUE)) rh_plot_spread(sp)
rh_plot_spread <- function(spread) {
  rlang::check_installed("ggplot2", reason = "to plot the spread.")
  by <- attr(spread, "by") %||% "group"
  p <- ggplot2::ggplot(spread, ggplot2::aes(x = .data$group))
  if (all(c("p10", "p90") %in% names(spread))) {
    p <- p + ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$p10, ymax = .data$p90),
      alpha = 0.2, fill = "steelblue"
    )
  }
  p +
    ggplot2::geom_line(ggplot2::aes(y = .data$mean), colour = "steelblue") +
    ggplot2::geom_point(ggplot2::aes(y = .data$mean), size = 0.8, colour = "steelblue") +
    ggplot2::labs(x = by, y = "Precipitation (mm)") +
    ggplot2::theme_minimal()
}
