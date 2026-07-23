# Estimate daily water demand from population

Converts a population and a per-capita daily water use into a total
daily demand, a convenience for parameterising
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md).

## Usage

``` r
rh_daily_demand(population, per_capita_l = 6.03)
```

## Arguments

- population:

  Number of people served.

- per_capita_l:

  Per-capita daily water use, in litres per person per day. Default
  `6.03` (a value reported for educational institutions).

## Value

Daily demand in cubic metres per day (m3/day).

## Examples

``` r
rh_daily_demand(1089, 6.03)
#> [1] 6.56667
```
