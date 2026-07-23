# Validate a metric name against the scalar metrics of `sim$summary`.
.metric_col <- function(metric) {
  metric <- metric[1]
  ok <- c(
    "captured_total", "overflow_total", "supplied_total", "deficit_total",
    "demand_total", "usable_volume", "final_storage", "days_unmet",
    "reliability_pct", "attendance_pct", "attendance_pct_legacy"
  )
  if (!is.character(metric) || !metric %in% ok) {
    rlang::abort(sprintf(
      "`metric` must be one of: %s.", paste(ok, collapse = ", ")
    ))
  }
  metric
}

# Collapse a daily precipitation vector to its day-of-year climatology (the mean
# for each calendar day across years). Used for the fast interactive mode.
# Note: the result has 366 values when the record contains any Feb 29 (that
# entry averages only the leap years) and 365 otherwise.
.climatology <- function(precip, dates) {
  if (is.null(dates)) {
    rlang::abort("`climatology = TRUE` requires `dates` (same length as `precip`).")
  }
  if (length(dates) != length(precip)) {
    rlang::abort("`dates` must have the same length as `precip`.")
  }
  if (anyNA(precip)) {
    rlang::abort("`precip` must not contain NA to be collapsed to a climatology.")
  }
  md <- format(as.Date(dates), "%m-%d")
  as.numeric(tapply(precip, md, mean))
}

# One simulation -> the requested metric scalars, as a one-row data.frame.
.sim_metrics <- function(precip, args, metrics) {
  sim <- do.call(rh_simulate, c(list(precip = precip), args))
  as.data.frame(sim$summary[metrics], stringsAsFactors = FALSE)
}
