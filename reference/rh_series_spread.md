# Precipitation variability summary

Summarises the spread of a precipitation series by year, month or
day-of-year: totals, mean, standard deviation, coefficient of variation,
the 10th/90th percentiles and the number of wet days. Water security
depends on how rainfall is distributed within and between years, which
the annual mean hides.

## Usage

``` r
rh_series_spread(
  data,
  value_col = "value",
  date_col = "date",
  by = c("year", "month", "doy")
)
```

## Arguments

- data:

  A data frame with a date column and a value column.

- value_col, date_col:

  Column names. Defaults `"value"` and `"date"`.

- by:

  Grouping: `"year"` (default), `"month"` or `"doy"` (day of year).

## Value

A data frame with columns
`group, n, total, mean, sd, cv, p10, p90, wet_days`; the grouping is
stored in `attr(, "by")`.

## Examples

``` r
head(rh_series_spread(precip_pi, by = "year"))
#>   group   n  total      mean       sd       cv p10  p90 wet_days
#> 1  1912 366  671.8 1.8355191 6.920487 3.770316   0 3.45       77
#> 2  1913 365  968.6 2.6536986 8.918407 3.360746   0 4.92       98
#> 3  1914 365 1030.3 2.8227397 8.411877 2.980040   0 8.42      101
#> 4  1915 365  287.4 0.7873973 3.476215 4.414817   0 0.00       36
#> 5  1916 366  999.6 2.7311475 8.965163 3.282563   0 6.15       86
#> 6  1917 365  878.3 2.4063014 8.406698 3.493618   0 4.82       80
```
