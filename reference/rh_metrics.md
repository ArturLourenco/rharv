# Summary metrics of a rainwater harvesting simulation

Extracts the water-balance metrics from a
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
result. All volume totals are in cubic metres (m3).

## Usage

``` r
rh_metrics(sim)

rh_attendance(sim, method = c("standard", "legacy"))

rh_deficit_total(sim)

rh_overflow_total(sim)
```

## Arguments

- sim:

  A `rharv_sim` object from
  [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md).

- method:

  For `rh_attendance()`, either `"standard"` (volumetric, the default)
  or `"legacy"` (the original case-study formula).

## Value

`rh_metrics()` returns a one-row data frame of metrics. The accessors
`rh_attendance()`, `rh_deficit_total()` and `rh_overflow_total()` return
a single numeric value.

## Details

Definitions: `overflow_total` (*vertimento*) is the spilled volume;
`deficit_total` (*deficit*) is the unmet demand; `usable_volume`
(*volume aproveitavel*) is `captured_total - overflow_total`;
`attendance_pct` (*atendimento*) is
`100 * supplied_total / demand_total`; `days_unmet` is the number of
time steps with any deficit; `reliability_pct` is the temporal
reliability `100 * (1 - days_unmet / n)`. `attendance_pct_legacy`
reproduces the formula used in the original case study.

## Examples

``` r
sim <- rh_simulate(c(0, 25, 0, 40), demand = 0.5, area = 775.53, capacity = 5)
rh_metrics(sim)
#>   n captured_total overflow_total supplied_total deficit_total demand_total
#> 1 4       34.27843       32.27843              2             0            2
#>   usable_volume final_storage days_unmet reliability_pct attendance_pct
#> 1             2             5          0             100            100
#>   attendance_pct_legacy
#> 1                   100
rh_attendance(sim)
#> [1] 100
```
