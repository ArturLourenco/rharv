#' Seasonal (monthly) demand as a daily vector
#'
#' Expands a 12-value monthly demand profile into a daily demand vector aligned
#' with `dates`, ready to pass to `rh_simulate(demand = ...)`. Use it to model
#' demand that varies by month (e.g. higher in the dry season).
#'
#' @param monthly Numeric vector of length 12 (Jan..Dec), demand per day in each
#'   month, in m3/day.
#' @param dates Date vector for which to build the daily demand.
#'
#' @return A numeric vector the same length as `dates`.
#' @export
#' @examples
#' d <- rh_seasonal_demand(monthly = c(7,7,6,6,5,5,5,6,7,7,7,7), dates = precip_pi$date)
#' length(d)
rh_seasonal_demand <- function(monthly, dates) {
  if (length(monthly) != 12) rlang::abort("`monthly` must have length 12 (Jan..Dec).")
  m <- as.integer(format(as.Date(dates), "%m"))
  as.numeric(monthly[m])
}

#' Build a stress-test series by ordering whole years
#'
#' Reorders the years of a precipitation series by their annual total to create
#' increasing (dry to wet) or decreasing (wet to dry) sequences, useful to
#' stress-test a system against runs of dry years. Note: partial boundary years
#' (a series starting or ending mid-year) are included as-is, so their totals
#' reflect only the observed days; trim the series to whole years first if that
#' matters for the ordering.
#'
#' @param data A data frame with a date column and a value column.
#' @param order `"increasing"` (dry to wet), `"decreasing"` (wet to dry) or
#'   `"asis"` (chronological).
#' @param value_col,date_col Column names. Defaults `"value"` and `"date"`.
#'
#' @return A data frame with columns `step, year, date, value` (years
#'   concatenated in the requested order). Feed `precip = result$value` to
#'   [rh_simulate()].
#' @export
#' @examples
#' s <- rh_scenarios_from_years(precip_pi, order = "increasing")
#' head(s)
rh_scenarios_from_years <- function(data, order = c("increasing", "decreasing", "asis"),
                                    value_col = "value", date_col = "date") {
  order <- match.arg(order)
  stopifnot(is.data.frame(data), value_col %in% names(data), date_col %in% names(data))
  dts <- as.Date(data[[date_col]])
  v <- data[[value_col]]
  yr <- as.integer(format(dts, "%Y"))
  totals <- tapply(v, yr, sum, na.rm = TRUE)
  yrs <- as.integer(names(totals))
  ord <- switch(order,
    increasing = yrs[base::order(totals)],
    decreasing = yrs[base::order(-totals)],
    asis = sort(yrs)
  )
  parts <- lapply(ord, function(y) {
    idx <- which(yr == y)
    data.frame(year = y, date = dts[idx], value = v[idx])
  })
  out <- do.call(rbind, parts)
  out$step <- seq_len(nrow(out))
  out[c("step", "year", "date", "value")]
}

#' Compare several simulations
#'
#' Binds the metrics of a named list of [rh_simulate()] results into one table,
#' for side-by-side scenario comparison.
#'
#' @param sims A named list of `rharv_sim` objects.
#'
#' @return A data frame: one row per simulation (a leading `name` column) with
#'   all [rh_metrics()] columns.
#' @export
#' @examples
#' a <- rh_simulate(precip_pi$value, 6.6, 4170, 400, runoff = 0.85, efficiency = 1)
#' b <- rh_simulate(precip_pi$value, 4.0, 4170, 400, runoff = 0.85, efficiency = 1)
#' rh_compare(list(high = a, low = b))
rh_compare <- function(sims) {
  if (!is.list(sims) || is.null(names(sims)) || any(names(sims) == "")) {
    rlang::abort("`sims` must be a named list of `rharv_sim` objects.")
  }
  rows <- lapply(names(sims), function(nm) {
    s <- sims[[nm]]
    stopifnot(inherits(s, "rharv_sim"))
    cbind(data.frame(name = nm), rh_metrics(s))
  })
  do.call(rbind, rows)
}
