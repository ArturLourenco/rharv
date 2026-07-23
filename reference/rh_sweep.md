# Sweep one design parameter and record performance metrics

Runs
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
repeatedly while varying a single parameter, keeping the others fixed,
and collects one or more summary metrics. Useful to see how the system
responds to a single "lever" (e.g. reliability versus reservoir
capacity). Returns a plain data frame, so it works without ggplot2.

## Usage

``` r
rh_sweep(
  precip,
  base = list(),
  param,
  values,
  metrics = "attendance_pct",
  dates = NULL,
  climatology = FALSE
)
```

## Arguments

- precip:

  Numeric vector of daily precipitation (mm). If `climatology = TRUE`,
  it is first collapsed to its day-of-year mean (see `dates`).

- base:

  A named list of the fixed arguments passed to
  [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
  (e.g.
  `list(demand = 6.6, area = 4170, capacity = 400, runoff = 0.85, efficiency = 1)`).
  Must supply every required argument except the one being swept.

- param:

  Name of the parameter to vary: one of `"demand"`, `"area"`,
  `"capacity"`, `"runoff"`, `"efficiency"`, `"initial"`.

- values:

  Numeric vector of values for `param`.

- metrics:

  Character vector of metric names to record (any of the columns of
  [`rh_metrics()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md));
  default `"attendance_pct"`.

- dates:

  Optional date vector aligned with `precip`, required only when
  `climatology = TRUE`.

- climatology:

  If `TRUE`, simulate on the day-of-year climatology (much faster)
  instead of the full series. Default `FALSE`.

## Value

A data frame with one column named after `param` (the swept values) plus
one column per requested metric.

## See also

[`rh_grid()`](https://arturlourenco.github.io/rharv/reference/rh_grid.md)
for two parameters at once.

## Examples

``` r
caps <- seq(50, 600, by = 50)
rh_sweep(precip_pi$value, base = list(demand = 6.6, area = 4170),
         param = "capacity", values = caps,
         metrics = c("attendance_pct", "reliability_pct"))
#>    capacity attendance_pct reliability_pct
#> 1        50       41.25324        38.67393
#> 2       100       49.20007        47.47391
#> 3       150       53.37051        51.82870
#> 4       200       56.35354        55.00827
#> 5       250       58.67158        57.45687
#> 6       300       60.83589        59.74274
#> 7       350       62.88305        61.87364
#> 8       400       64.85176        63.92706
#> 9       450       66.70168        65.82292
#> 10      500       68.47761        67.62837
#> 11      550       70.18857        69.36925
#> 12      600       71.79939        71.00682
```
