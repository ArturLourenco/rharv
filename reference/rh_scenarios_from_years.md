# Build a stress-test series by ordering whole years

Reorders the years of a precipitation series by their annual total to
create increasing (dry to wet) or decreasing (wet to dry) sequences,
useful to stress-test a system against runs of dry years. Note: partial
boundary years (a series starting or ending mid-year) are included
as-is, so their totals reflect only the observed days; trim the series
to whole years first if that matters for the ordering.

## Usage

``` r
rh_scenarios_from_years(
  data,
  order = c("increasing", "decreasing", "asis"),
  value_col = "value",
  date_col = "date"
)
```

## Arguments

- data:

  A data frame with a date column and a value column.

- order:

  `"increasing"` (dry to wet), `"decreasing"` (wet to dry) or `"asis"`
  (chronological).

- value_col, date_col:

  Column names. Defaults `"value"` and `"date"`.

## Value

A data frame with columns `step, year, date, value` (years concatenated
in the requested order). Feed `precip = result$value` to
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md).

## Examples

``` r
s <- rh_scenarios_from_years(precip_pi, order = "increasing")
head(s)
#>   step year       date value
#> 1    1 1919 1919-01-01   0.0
#> 2    2 1919 1919-01-02   8.2
#> 3    3 1919 1919-01-03   0.0
#> 4    4 1919 1919-01-04   0.0
#> 5    5 1919 1919-01-05   0.0
#> 6    6 1919 1919-01-06   0.0
```
