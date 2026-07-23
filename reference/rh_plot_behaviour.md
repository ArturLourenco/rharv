# Reservoir behaviour over time

Plots the daily series of a
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
result (storage, captured inflow, deficit, overflow, supplied). A richer
companion to
[`autoplot.rharv_sim()`](https://arturlourenco.github.io/rharv/reference/autoplot.rharv_sim.md):
it can show more variables and use real dates on the x-axis.

## Usage

``` r
rh_plot_behaviour(
  sim,
  dates = NULL,
  vars = c("storage", "captured", "deficit", "overflow")
)
```

## Arguments

- sim:

  A `rharv_sim` object.

- dates:

  Optional date vector aligned with the simulation (same length as
  `sim$series`); if supplied, the x-axis uses dates instead of step
  index.

- vars:

  Variables to draw; any of `"storage"`, `"captured"`, `"supplied"`,
  `"deficit"`, `"overflow"`.

## Value

A ggplot2 object.

## Examples

``` r
sim <- rh_simulate(precip_pi$value[1:1095], demand = 4, area = 4170,
                   capacity = 400, runoff = 0.85, efficiency = 1)
if (requireNamespace("ggplot2", quietly = TRUE)) {
  rh_plot_behaviour(sim, dates = precip_pi$date[1:1095])
}
```
