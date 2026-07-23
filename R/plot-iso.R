#' Plot iso-guarantee design curves
#'
#' Draws the family of iso-guarantee curves from [rh_iso_curve()]: one line per
#' target guarantee level relating two design levers (e.g. area on the x-axis and
#' the reservoir capacity needed on the y-axis). Reading along a line shows how to
#' trade one lever for another while keeping the guarantee fixed. If the curve was
#' built with a `by` variable, it is shown as facets.
#'
#' @param iso A data frame from [rh_iso_curve()].
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' iso <- rh_iso_curve(
#'   precip_pi$value, base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
#'   x = "area", x_values = seq(1000, 6000, length.out = 8),
#'   y = "capacity", levels = c(80, 90, 95, 100),
#'   dates = precip_pi$date, climatology = TRUE
#' )
#' if (requireNamespace("ggplot2", quietly = TRUE)) rh_plot_iso(iso)
rh_plot_iso <- function(iso) {
  rlang::check_installed("ggplot2", reason = "to plot iso-guarantee curves.")
  x <- attr(iso, "x")
  y <- attr(iso, "y")
  by <- attr(iso, "by")
  if (is.null(x) || is.null(y)) rlang::abort("`iso` must come from `rh_iso_curve()`.")
  d <- iso[!is.na(iso[[y]]), , drop = FALSE]

  p <- ggplot2::ggplot(
    d, ggplot2::aes(x = .data[[x]], y = .data[[y]],
                    colour = factor(.data$level), group = .data$level)
  ) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 0.8) +
    ggplot2::labs(x = x, y = y, colour = "Guarantee (%)") +
    ggplot2::theme_minimal()

  if (!is.null(by)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", by)))
  }
  p
}

#' Plot required resources versus guarantee level
#'
#' Draws the output of [rh_resource_curve()] as a guarantee "design curve":
#' guarantee level on the x-axis, with the required resources on the y-axis. For
#' exactly two resources (the default capacity + area) it uses a dual y-axis,
#' echoing the reservoir stage-area-volume curve; otherwise it facets.
#'
#' @param rc A data frame from [rh_resource_curve()].
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' rc <- rh_resource_curve(
#'   precip_pi$value,
#'   base = list(demand = 6.6, area = 4170, capacity = 400,
#'               runoff = 0.85, efficiency = 1),
#'   levels = seq(60, 100, by = 10),
#'   dates = precip_pi$date, climatology = TRUE
#' )
#' if (requireNamespace("ggplot2", quietly = TRUE)) rh_plot_resource_curve(rc)
rh_plot_resource_curve <- function(rc) {
  rlang::check_installed("ggplot2", reason = "to plot the resource curve.")
  lbl <- c(capacity = "Required capacity (m3)", area = "Required area (m2)",
           demand = "Max demand (m3/day)")
  # Drop unreachable points first, THEN decide the layout: a resource that is
  # entirely NA must not silently break the dual-axis scale factor.
  rc <- rc[is.finite(rc$value), , drop = FALSE]
  if (!nrow(rc)) {
    rlang::abort("All values in `rc` are NA (unreachable levels); nothing to plot.")
  }
  res <- unique(rc$resource)
  sf <- if (length(res) == 2) {
    max(rc$value[rc$resource == res[1]]) / max(rc$value[rc$resource == res[2]])
  } else {
    NA_real_
  }

  if (length(res) == 2 && is.finite(sf) && sf > 0) {
    a <- rc[rc$resource == res[1], ]
    b <- rc[rc$resource == res[2], ]
    ggplot2::ggplot(mapping = ggplot2::aes(x = .data$level, y = .data$value)) +
      ggplot2::geom_line(data = a, ggplot2::aes(colour = res[1])) +
      ggplot2::geom_point(data = a, ggplot2::aes(colour = res[1])) +
      ggplot2::geom_line(data = transform(b, value = b$value * sf),
                         ggplot2::aes(colour = res[2])) +
      ggplot2::geom_point(data = transform(b, value = b$value * sf),
                          ggplot2::aes(colour = res[2])) +
      ggplot2::scale_y_continuous(
        name = lbl[[res[1]]],
        sec.axis = ggplot2::sec_axis(~ . / sf, name = lbl[[res[2]]])
      ) +
      ggplot2::labs(x = "Guarantee (%)", colour = NULL) +
      ggplot2::theme_minimal()
  } else {
    ggplot2::ggplot(rc, ggplot2::aes(x = .data$level, y = .data$value,
                                     colour = .data$resource)) +
      ggplot2::geom_line() +
      ggplot2::geom_point() +
      ggplot2::facet_wrap(~resource, scales = "free_y") +
      ggplot2::labs(x = "Guarantee (%)", y = "Required value", colour = NULL) +
      ggplot2::theme_minimal()
  }
}
