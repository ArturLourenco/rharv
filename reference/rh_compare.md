# Compare several simulations

Binds the metrics of a named list of
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
results into one table, for side-by-side scenario comparison.

## Usage

``` r
rh_compare(sims)
```

## Arguments

- sims:

  A named list of `rharv_sim` objects.

## Value

A data frame: one row per simulation (a leading `name` column) with all
[`rh_metrics()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
columns.

## Examples

``` r
a <- rh_simulate(precip_pi$value, 6.6, 4170, 400, runoff = 0.85, efficiency = 1)
b <- rh_simulate(precip_pi$value, 4.0, 4170, 400, runoff = 0.85, efficiency = 1)
rh_compare(list(high = a, low = b))
#>   name     n captured_total overflow_total supplied_total deficit_total
#> 1 high 38716       306631.2       130489.6       176541.5      78984.07
#> 2  low 38716       306631.2       172670.3       134289.7      20574.35
#>   demand_total usable_volume final_storage days_unmet reliability_pct
#> 1     255525.6      176141.5       0.00000      12257        68.34125
#> 2     154864.0      133960.8      71.15115       5275        86.37514
#>   attendance_pct attendance_pct_legacy
#> 1       69.08957              69.08957
#> 2       86.71457              86.72067
```
