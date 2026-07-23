#' Trade-off surface: catchment area vs reservoir capacity
#'
#' Draws the performance surface produced by [rh_grid()] as a heatmap with
#' iso-performance contours. With area on the x-axis and capacity on the y-axis
#' (the defaults), it shows whether enlarging the roof or the tank moves
#' the system across a target guarantee level faster. The demand (and any other
#' parameter) is whatever was fixed in the `base` of [rh_grid()].
#'
#' @param grid A data frame from [rh_grid()].
#' @param metric Which metric column to display; defaults to the first metric in
#'   `grid`. Typically `"attendance_pct"` (volumetric) or `"reliability_pct"`
#'   (time-based).
#' @param contours Logical; overlay iso-performance contour lines. Default `TRUE`.
#' @param breaks Numeric contour levels (e.g. `c(80, 90, 95, 100)` for a
#'   percentage metric). Default `NULL` (automatic).
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' g <- rh_grid(precip_pi$value,
#'              base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
#'              x = "area", x_values = seq(500, 6000, length.out = 12),
#'              y = "capacity", y_values = seq(100, 1200, length.out = 12),
#'              metrics = "attendance_pct",
#'              dates = precip_pi$date, climatology = TRUE)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_tradeoff(g, breaks = c(50, 70, 90, 100))
#' }
rh_plot_tradeoff <- function(grid, metric = NULL, contours = TRUE,
                             breaks = NULL) {
  rlang::check_installed("ggplot2", reason = "to plot the trade-off surface.")
  x <- attr(grid, "x")
  y <- attr(grid, "y")
  if (is.null(x) || is.null(y)) {
    rlang::abort("`grid` must come from `rh_grid()`.")
  }
  metric <- metric %||% grid$metric[1]
  d <- grid[grid$metric == metric, , drop = FALSE]
  if (!nrow(d)) rlang::abort(sprintf("Metric '%s' is not in `grid`.", metric))

  p <- ggplot2::ggplot(
    d, ggplot2::aes(x = .data[[x]], y = .data[[y]], z = .data$value)
  ) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$value)) +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::labs(x = x, y = y, fill = metric) +
    ggplot2::theme_minimal()

  if (isTRUE(contours)) {
    p <- p + ggplot2::geom_contour(colour = "white", linewidth = 0.3,
                                   breaks = breaks)
  }
  p
}

#' Effect of each design lever on performance
#'
#' From a chosen operating point, applies a multiplicative change to each lever
#' (catchment area, reservoir capacity and demand) one at a time and shows the
#' resulting performance metric, with a dashed line at the baseline, so that
#' enlarging the roof, enlarging the tank and trimming demand can be compared
#' directly.
#'
#' @inheritParams rh_sweep
#' @param base Named list with the operating point (must include the levers to be
#'   changed, e.g. `area`, `capacity`, `demand`).
#' @param changes Named list of multiplicative factors applied to each lever in
#'   turn, e.g. `list(area = 1.25, capacity = 1.25, demand = 0.9)`.
#' @param metric Single metric to compare (default `"attendance_pct"`).
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rh_plot_levers(
#'     precip_pi$value,
#'     base = list(demand = 6.6, area = 4170, capacity = 400,
#'                 runoff = 0.85, efficiency = 1),
#'     dates = precip_pi$date, climatology = TRUE
#'   )
#' }
rh_plot_levers <- function(precip, base,
                           changes = list(area = 1.25, capacity = 1.25,
                                          demand = 0.9),
                           metric = "attendance_pct", dates = NULL,
                           climatology = FALSE) {
  rlang::check_installed("ggplot2", reason = "to plot the levers chart.")
  metric <- .metric_col(metric)
  if (isTRUE(climatology)) precip <- .climatology(precip, dates)

  run <- function(args) {
    do.call(rh_simulate, c(list(precip = precip), args))$summary[[metric]]
  }
  baseline <- run(base)
  rows <- lapply(names(changes), function(lever) {
    if (is.null(base[[lever]])) {
      rlang::abort(sprintf("`base` must contain the lever '%s'.", lever))
    }
    args <- base
    args[[lever]] <- base[[lever]] * changes[[lever]]
    data.frame(lever = sprintf("%s x%.2f", lever, changes[[lever]]),
               value = run(args))
  })
  df <- rbind(data.frame(lever = "baseline", value = baseline),
              do.call(rbind, rows))

  ggplot2::ggplot(
    df, ggplot2::aes(x = stats::reorder(.data$lever, .data$value),
                     y = .data$value)
  ) +
    ggplot2::geom_col(fill = "steelblue") +
    ggplot2::geom_hline(yintercept = baseline, linetype = 2) +
    ggplot2::coord_flip() +
    ggplot2::labs(x = NULL, y = metric) +
    ggplot2::theme_minimal()
}
