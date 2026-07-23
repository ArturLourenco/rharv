# Package index

## Available volume and simulation

Captured-volume relation and the daily water-balance engine.

- [`rh_available_volume()`](https://arturlourenco.github.io/rharv/reference/rh_available_volume.md)
  : Available rainwater volume (ABNT NBR 15527:2019)
- [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
  : Daily water-balance simulation of a rainwater harvesting reservoir

## Metrics

- [`rh_metrics()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
  [`rh_attendance()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
  [`rh_deficit_total()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
  [`rh_overflow_total()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
  : Summary metrics of a rainwater harvesting simulation

## Sizing

Guarantee-based sizing of demand, capacity and area.

- [`rh_guaranteed_demand()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md)
  [`rh_guaranteed_capacity()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md)
  [`rh_required_area()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md)
  : Guarantee-based sizing of rainwater harvesting systems

## Analysis

Parameter sweeps, grids, frontiers, variability and scenarios.

- [`rh_sweep()`](https://arturlourenco.github.io/rharv/reference/rh_sweep.md)
  : Sweep one design parameter and record performance metrics
- [`rh_grid()`](https://arturlourenco.github.io/rharv/reference/rh_grid.md)
  : Two-parameter grid of performance metrics
- [`rh_guarantee_curve()`](https://arturlourenco.github.io/rharv/reference/rh_guarantee_curve.md)
  : Zero-deficit guarantee frontier
- [`rh_size_for()`](https://arturlourenco.github.io/rharv/reference/rh_size_for.md)
  : Size a parameter to reach a target guarantee level
- [`rh_iso_curve()`](https://arturlourenco.github.io/rharv/reference/rh_iso_curve.md)
  : Iso-guarantee design curves
- [`rh_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_resource_curve.md)
  : Required resources versus guarantee level
- [`rh_series_spread()`](https://arturlourenco.github.io/rharv/reference/rh_series_spread.md)
  : Precipitation variability summary
- [`rh_seasonal_demand()`](https://arturlourenco.github.io/rharv/reference/rh_seasonal_demand.md)
  : Seasonal (monthly) demand as a daily vector
- [`rh_scenarios_from_years()`](https://arturlourenco.github.io/rharv/reference/rh_scenarios_from_years.md)
  : Build a stress-test series by ordering whole years
- [`rh_compare()`](https://arturlourenco.github.io/rharv/reference/rh_compare.md)
  : Compare several simulations

## Demand

- [`rh_daily_demand()`](https://arturlourenco.github.io/rharv/reference/rh_daily_demand.md)
  : Estimate daily water demand from population

## Plots

- [`autoplot(`*`<rharv_sim>`*`)`](https://arturlourenco.github.io/rharv/reference/autoplot.rharv_sim.md)
  [`plot(`*`<rharv_sim>`*`)`](https://arturlourenco.github.io/rharv/reference/autoplot.rharv_sim.md)
  : Plot a rainwater harvesting simulation
- [`rh_plot_climatology()`](https://arturlourenco.github.io/rharv/reference/rh_plot_climatology.md)
  : Day-of-year precipitation climatology heatmap
- [`rh_plot_tradeoff()`](https://arturlourenco.github.io/rharv/reference/rh_plot_tradeoff.md)
  : Trade-off surface: catchment area vs reservoir capacity
- [`rh_plot_levers()`](https://arturlourenco.github.io/rharv/reference/rh_plot_levers.md)
  : Effect of each design lever on performance
- [`rh_plot_syr()`](https://arturlourenco.github.io/rharv/reference/rh_plot_syr.md)
  : Storage-yield-reliability (SYR) curves
- [`rh_plot_design_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_design_curve.md)
  : Dimensionless design curve
- [`rh_plot_iso()`](https://arturlourenco.github.io/rharv/reference/rh_plot_iso.md)
  : Plot iso-guarantee design curves
- [`rh_plot_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_resource_curve.md)
  : Plot required resources versus guarantee level
- [`rh_plot_behaviour()`](https://arturlourenco.github.io/rharv/reference/rh_plot_behaviour.md)
  : Reservoir behaviour over time
- [`rh_plot_monthly_balance()`](https://arturlourenco.github.io/rharv/reference/rh_plot_monthly_balance.md)
  : Monthly water balance
- [`rh_plot_failure_calendar()`](https://arturlourenco.github.io/rharv/reference/rh_plot_failure_calendar.md)
  : Failure (deficit) calendar
- [`rh_plot_spread()`](https://arturlourenco.github.io/rharv/reference/rh_plot_spread.md)
  : Plot precipitation variability

## Interactive app

- [`rh_explore()`](https://arturlourenco.github.io/rharv/reference/rh_explore.md)
  [`rh_app()`](https://arturlourenco.github.io/rharv/reference/rh_explore.md)
  : Launch the rharv explorer (Shiny app)
- [`rh_demo()`](https://arturlourenco.github.io/rharv/reference/rh_demo.md)
  : Open the rharv demonstration notebook

## Datasets

- [`precip_pi`](https://arturlourenco.github.io/rharv/reference/precip_pi.md)
  : Daily precipitation at Princesa Isabel (1912-2019)
- [`areas_pi`](https://arturlourenco.github.io/rharv/reference/areas_pi.md)
  : Catchment (roof) areas of the IFPB-PI campus
