#' Precipitation variability summary
#'
#' Summarises the spread of a precipitation series by year, month or day-of-year:
#' totals, mean, standard deviation, coefficient of variation, the 10th/90th
#' percentiles and the number of wet days. Water security depends on how rainfall
#' is distributed within and between years, which the annual mean hides.
#'
#' @param data A data frame with a date column and a value column.
#' @param value_col,date_col Column names. Defaults `"value"` and `"date"`.
#' @param by Grouping: `"year"` (default), `"month"` or `"doy"` (day of year).
#'
#' @return A data frame with columns `group, n, total, mean, sd, cv, p10, p90,
#'   wet_days`; the grouping is stored in `attr(, "by")`.
#' @export
#' @examples
#' head(rh_series_spread(precip_pi, by = "year"))
rh_series_spread <- function(data, value_col = "value", date_col = "date",
                             by = c("year", "month", "doy")) {
  by <- match.arg(by)
  stopifnot(is.data.frame(data), value_col %in% names(data), date_col %in% names(data))
  dts <- as.Date(data[[date_col]])
  v <- data[[value_col]]
  grp <- switch(by,
    year = as.integer(format(dts, "%Y")),
    month = as.integer(format(dts, "%m")),
    doy = as.integer(format(dts, "%j"))
  )
  spl <- split(v, grp)
  out <- do.call(rbind, lapply(names(spl), function(g) {
    x <- spl[[g]]
    x <- x[!is.na(x)]
    if (length(x) == 0) {
      return(data.frame(
        group = as.integer(g), n = 0L, total = NA_real_, mean = NA_real_,
        sd = NA_real_, cv = NA_real_, p10 = NA_real_, p90 = NA_real_,
        wet_days = 0L
      ))
    }
    mu <- mean(x)
    data.frame(
      group = as.integer(g), n = length(x), total = sum(x), mean = mu,
      sd = stats::sd(x),
      cv = if (isTRUE(mu > 0)) stats::sd(x) / mu else NA_real_,
      p10 = stats::quantile(x, 0.1, names = FALSE),
      p90 = stats::quantile(x, 0.9, names = FALSE),
      wet_days = sum(x > 0)
    )
  }))
  attr(out, "by") <- by
  out
}
