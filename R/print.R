#' @export
print.rharv_sim <- function(x, ...) {
  s <- x$summary
  i <- x$inputs
  cat("<rharv_sim>\n")
  cat(sprintf(
    "  steps: %d | area: %s m2 | capacity: %s m3 | timing: %s\n",
    i$n, format(i$area), format(i$capacity), i$overflow_timing
  ))
  cat(sprintf(
    "  attendance: %.1f%% | reliability: %.1f%% | days unmet: %d\n",
    s$attendance_pct, s$reliability_pct, s$days_unmet
  ))
  cat(sprintf(
    "  totals (m3): deficit %.2f | overflow %.2f | usable %.2f\n",
    s$deficit_total, s$overflow_total, s$usable_volume
  ))
  invisible(x)
}

#' @export
summary.rharv_sim <- function(object, ...) {
  rh_metrics(object)
}

#' @export
as.data.frame.rharv_sim <- function(x, ...) {
  x$series
}

#' @exportS3Method tibble::as_tibble
as_tibble.rharv_sim <- function(x, ...) {
  tibble::as_tibble(x$series, ...)
}
