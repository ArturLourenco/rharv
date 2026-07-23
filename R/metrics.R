# Compute the summary metrics from a simulation series.
.compute_metrics <- function(series, inputs) {
  n <- nrow(series)
  captured_total <- sum(series$captured)
  overflow_total <- sum(series$overflow)
  supplied_total <- sum(series$supplied)
  deficit_total <- sum(series$deficit)
  demand_total <- supplied_total + deficit_total
  usable_volume <- captured_total - overflow_total
  final_storage <- series$storage[n]
  days_unmet <- sum(series$deficit > 1e-9)

  attendance_pct <- if (demand_total > 0) {
    100 * supplied_total / demand_total
  } else {
    100
  }
  # Legacy formula used by the original author/case study:
  # ((usable + initial) * 100) / (total demand + final storage)
  attendance_pct_legacy <- if ((demand_total + final_storage) > 0) {
    100 * (usable_volume + inputs$initial) / (demand_total + final_storage)
  } else {
    NA_real_
  }

  list(
    n = n,
    captured_total = captured_total,
    overflow_total = overflow_total,
    supplied_total = supplied_total,
    deficit_total = deficit_total,
    demand_total = demand_total,
    usable_volume = usable_volume,
    final_storage = final_storage,
    days_unmet = days_unmet,
    reliability_pct = 100 * (1 - days_unmet / n),
    attendance_pct = attendance_pct,
    attendance_pct_legacy = attendance_pct_legacy
  )
}

#' Summary metrics of a rainwater harvesting simulation
#'
#' Extracts the water-balance metrics from a [rh_simulate()] result. All volume
#' totals are in cubic metres (m3).
#'
#' Definitions: `overflow_total` (*vertimento*) is the spilled volume;
#' `deficit_total` (*deficit*) is the unmet demand; `usable_volume` (*volume
#' aproveitavel*) is `captured_total - overflow_total`; `attendance_pct`
#' (*atendimento*) is `100 * supplied_total / demand_total`; `days_unmet` is the
#' number of time steps with any deficit; `reliability_pct` is the temporal
#' reliability `100 * (1 - days_unmet / n)`. `attendance_pct_legacy` reproduces
#' the formula used in the original case study.
#'
#' @param sim A `rharv_sim` object from [rh_simulate()].
#' @param method For [rh_attendance()], either `"standard"` (volumetric, the
#'   default) or `"legacy"` (the original case-study formula).
#'
#' @return [rh_metrics()] returns a one-row data frame of metrics. The accessors
#'   [rh_attendance()], [rh_deficit_total()] and [rh_overflow_total()] return a
#'   single numeric value.
#' @export
#' @examples
#' sim <- rh_simulate(c(0, 25, 0, 40), demand = 0.5, area = 775.53, capacity = 5)
#' rh_metrics(sim)
#' rh_attendance(sim)
rh_metrics <- function(sim) {
  stopifnot(inherits(sim, "rharv_sim"))
  as.data.frame(sim$summary)
}

#' @rdname rh_metrics
#' @export
rh_attendance <- function(sim, method = c("standard", "legacy")) {
  stopifnot(inherits(sim, "rharv_sim"))
  method <- match.arg(method)
  if (method == "legacy") sim$summary$attendance_pct_legacy else sim$summary$attendance_pct
}

#' @rdname rh_metrics
#' @export
rh_deficit_total <- function(sim) {
  stopifnot(inherits(sim, "rharv_sim"))
  sim$summary$deficit_total
}

#' @rdname rh_metrics
#' @export
rh_overflow_total <- function(sim) {
  stopifnot(inherits(sim, "rharv_sim"))
  sim$summary$overflow_total
}
