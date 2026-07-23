#' Storage-yield-reliability (SYR) curves
#'
#' Plots a performance metric against one design variable (typically reservoir
#' capacity on the x-axis), with one line per value of the other variable
#' (typically demand or area). This is the classic Storage-Yield-Reliability
#' (SYR) view used in rainwater-tank design (e.g. McMahon & Adeloye; Fewkes;
#' Mitchell).
#'
#' @param grid A data frame from [rh_grid()]: the x-attribute becomes the x-axis
#'   and the y-attribute becomes the colour (one line per value).
#' @param metric Which metric column to plot; default the first in `grid`.
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' g <- rh_grid(precip_pi$value, base = list(runoff = 0.85, efficiency = 1, area = 4170),
#'              x = "capacity", x_values = seq(100, 1200, length.out = 12),
#'              y = "demand", y_values = c(3, 5, 7),
#'              metrics = "reliability_pct",
#'              dates = precip_pi$date, climatology = TRUE)
#' if (requireNamespace("ggplot2", quietly = TRUE)) rh_plot_syr(g)
rh_plot_syr <- function(grid, metric = NULL) {
  rlang::check_installed("ggplot2", reason = "to plot SYR curves.")
  x <- attr(grid, "x")
  colour <- attr(grid, "y")
  if (is.null(x) || is.null(colour)) rlang::abort("`grid` must come from `rh_grid()`.")
  metric <- metric %||% grid$metric[1]
  d <- grid[grid$metric == metric, , drop = FALSE]
  ggplot2::ggplot(
    d, ggplot2::aes(x = .data[[x]], y = .data$value,
                    colour = factor(.data[[colour]]), group = .data[[colour]])
  ) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 0.8) +
    ggplot2::labs(x = x, y = metric, colour = colour) +
    ggplot2::theme_minimal()
}

#' Dimensionless design curve
#'
#' Re-expresses a demand x capacity [rh_grid()] in non-dimensional terms so the
#' chart is transferable across sites (after Fewkes): demand becomes the
#' *demand fraction* (annual demand / annual inflow) and capacity becomes the
#' *storage fraction* (capacity / annual inflow). Filled by a performance metric
#' with iso-performance contours.
#'
#' @param grid A data frame from [rh_grid()] varying `"demand"` and `"capacity"`.
#' @param annual_inflow Mean annual captured volume (m3), e.g.
#'   `sum(rh_available_volume(precip, area, runoff, efficiency)) / n_years`.
#' @param period_days Days per year used to annualise demand. Default 365.
#' @param metric,contours,breaks As in [rh_plot_tradeoff()].
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' area <- 4170
#' n_years <- length(unique(format(precip_pi$date, "%Y")))
#' inflow <- sum(rh_available_volume(precip_pi$value, area, 0.85, 1)) / n_years
#' g <- rh_grid(precip_pi$value, base = list(area = area, runoff = 0.85, efficiency = 1),
#'              x = "demand", x_values = seq(2, 12, length.out = 10),
#'              y = "capacity", y_values = seq(100, 1500, length.out = 10),
#'              metrics = "reliability_pct",
#'              dates = precip_pi$date, climatology = TRUE)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_design_curve(g, annual_inflow = inflow)
#' }
rh_plot_design_curve <- function(grid, annual_inflow, period_days = 365,
                                 metric = NULL, contours = TRUE, breaks = NULL) {
  rlang::check_installed("ggplot2", reason = "to plot the design curve.")
  x <- attr(grid, "x")
  y <- attr(grid, "y")
  if (is.null(x) || is.null(y)) {
    rlang::abort("`grid` must come from `rh_grid()` (attributes were lost).")
  }
  if (!all(c(x, y) %in% c("demand", "capacity"))) {
    rlang::abort("`grid` must vary 'demand' and 'capacity'.")
  }
  metric <- metric %||% grid$metric[1]
  d <- grid[grid$metric == metric, , drop = FALSE]
  frac <- function(name, vals) {
    if (name == "demand") vals * period_days / annual_inflow else vals / annual_inflow
  }
  lab <- function(name) {
    if (name == "demand") "demand fraction (annual demand / inflow)" else "storage fraction (capacity / inflow)"
  }
  d$.xf <- frac(x, d[[x]])
  d$.yf <- frac(y, d[[y]])

  p <- ggplot2::ggplot(d, ggplot2::aes(x = .data$.xf, y = .data$.yf, z = .data$value)) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$value)) +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::labs(x = lab(x), y = lab(y), fill = metric) +
    ggplot2::theme_minimal()
  if (isTRUE(contours)) {
    p <- p + ggplot2::geom_contour(colour = "white", linewidth = 0.3, breaks = breaks)
  }
  p
}
