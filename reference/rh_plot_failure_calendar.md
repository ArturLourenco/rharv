# Failure (deficit) calendar

Heatmap of daily deficit by year (y) and day-of-year (x), showing when
shortfalls occur and how they cluster in the dry season.

## Usage

``` r
rh_plot_failure_calendar(sim, dates)
```

## Arguments

- sim:

  A `rharv_sim` object.

- dates:

  Date vector aligned with the simulation (same length as `sim$series`).

## Value

A ggplot2 object.

## Examples

``` r
sim <- rh_simulate(precip_pi$value, demand = 6.6, area = 4170, capacity = 400,
                   runoff = 0.85, efficiency = 1)
if (requireNamespace("ggplot2", quietly = TRUE)) {
  rh_plot_failure_calendar(sim, dates = precip_pi$date)
}
```
