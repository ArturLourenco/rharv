# Changelog

## rharv 0.3.0

Release polish and fixes from a pre-release review.

- Fixed `rh_size_for(vary = "demand")` for targets below 100%: the
  search bound was clipped at the zero-deficit maximum, silently
  understating the result (also affected
  [`rh_iso_curve()`](https://arturlourenco.github.io/rharv/reference/rh_iso_curve.md)/[`rh_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_resource_curve.md)
  solving for demand at sub-100 levels).

- `rh_size_for(vary = "capacity")` now clamps a fixed `initial` to the
  trial capacity (it used to error) and accepts a per-day demand vector;
  it also validates that `base` contains the required parameters.

- [`rh_guarantee_curve()`](https://arturlourenco.github.io/rharv/reference/rh_guarantee_curve.md)
  returns `NA` for infeasible points instead of aborting the whole
  frontier;
  [`rh_guaranteed_capacity()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md)
  detects supply-limited (structurally infeasible) problems early with a
  clear message.

- [`rh_plot_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_resource_curve.md)
  falls back to facets when a resource is entirely unreachable;
  [`rh_plot_monthly_balance()`](https://arturlourenco.github.io/rharv/reference/rh_plot_monthly_balance.md)
  labels months correctly for partial-year simulations;
  [`rh_plot_design_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_design_curve.md)
  gives a friendly error when grid attributes were lost;
  [`rh_series_spread()`](https://arturlourenco.github.io/rharv/reference/rh_series_spread.md)
  tolerates all-NA groups; the `step` solver rejects non-positive steps.

- Shiny explorer: debounced recomputation of the trade-off grid and
  guarantee values, fast-mode now also applies to the guarantee values,
  and the initial storage slider stays consistent with the capacity
  slider.

- The demo notebook
  ([`rh_demo()`](https://arturlourenco.github.io/rharv/reference/rh_demo.md))
  was rewritten as an annotated, paper-style document (in Portuguese):
  every section states the model and its equations, runs the code, and
  explains how to read the result, covering the YAS and YBS operating
  rules, the mass-balance check, the standard versus legacy attendance
  algebra, and a reading guide for each chart.

- [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
  documentation now names the two `overflow_timing` rules by their
  literature names (YBS = `after_demand`, YAS = `before_demand`).

- pkgdown now renders equations properly (MathJax enabled).

## rharv 0.2.0

Analysis tools, decision plots and an interactive app.

- [`rh_sweep()`](https://arturlourenco.github.io/rharv/reference/rh_sweep.md)
  (one parameter) and
  [`rh_grid()`](https://arturlourenco.github.io/rharv/reference/rh_grid.md)
  (two parameters) compute performance metrics over a range of designs,
  with a fast day-of-year `climatology` mode; metrics are selectable
  (`"attendance_pct"`, `"reliability_pct"`, …).
- [`rh_plot_tradeoff()`](https://arturlourenco.github.io/rharv/reference/rh_plot_tradeoff.md)
  draws the area x capacity surface with iso-guarantee contours, and
  [`rh_plot_levers()`](https://arturlourenco.github.io/rharv/reference/rh_plot_levers.md)
  compares the levers (more roof, more tank or less demand).
- [`rh_guarantee_curve()`](https://arturlourenco.github.io/rharv/reference/rh_guarantee_curve.md)
  traces the zero-deficit frontier,
  [`rh_plot_syr()`](https://arturlourenco.github.io/rharv/reference/rh_plot_syr.md)
  the storage-yield-reliability curves and
  [`rh_plot_design_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_design_curve.md)
  the dimensionless, site-transferable version.
- [`rh_size_for()`](https://arturlourenco.github.io/rharv/reference/rh_size_for.md)
  sizes any lever to an arbitrary guarantee level;
  [`rh_iso_curve()`](https://arturlourenco.github.io/rharv/reference/rh_iso_curve.md)
  with
  [`rh_plot_iso()`](https://arturlourenco.github.io/rharv/reference/rh_plot_iso.md)
  draws iso-guarantee curves relating two levers (optionally faceted by
  a third);
  [`rh_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_resource_curve.md)
  with
  [`rh_plot_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_resource_curve.md)
  plots the required capacity and area against the guarantee level on a
  dual axis, the stage-area-volume analogue.
- Diagnostic plots
  [`rh_plot_behaviour()`](https://arturlourenco.github.io/rharv/reference/rh_plot_behaviour.md),
  [`rh_plot_monthly_balance()`](https://arturlourenco.github.io/rharv/reference/rh_plot_monthly_balance.md)
  and
  [`rh_plot_failure_calendar()`](https://arturlourenco.github.io/rharv/reference/rh_plot_failure_calendar.md).
- Variability and scenario helpers:
  [`rh_series_spread()`](https://arturlourenco.github.io/rharv/reference/rh_series_spread.md)
  with
  [`rh_plot_spread()`](https://arturlourenco.github.io/rharv/reference/rh_plot_spread.md),
  [`rh_seasonal_demand()`](https://arturlourenco.github.io/rharv/reference/rh_seasonal_demand.md)
  (monthly demand profile),
  [`rh_scenarios_from_years()`](https://arturlourenco.github.io/rharv/reference/rh_scenarios_from_years.md)
  (dry-to-wet or wet-to-dry stress series) and
  [`rh_compare()`](https://arturlourenco.github.io/rharv/reference/rh_compare.md).
- [`rh_explore()`](https://arturlourenco.github.io/rharv/reference/rh_explore.md)
  and
  [`rh_app()`](https://arturlourenco.github.io/rharv/reference/rh_explore.md)
  launch a Shiny explorer to vary parameters and watch the behaviour,
  metrics, trade-off surface and guarantee values update live.
- New `analysis-and-sizing` vignette, and a full-feature demo notebook
  shipped with the package: open it in your editor with
  [`rh_demo()`](https://arturlourenco.github.io/rharv/reference/rh_demo.md).

## rharv 0.1.0

Initial release.

- [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
  runs the daily reservoir water-balance simulation, returning an
  `rharv_sim` object with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) and
  `autoplot()` methods.
- [`rh_available_volume()`](https://arturlourenco.github.io/rharv/reference/rh_available_volume.md)
  computes the captured rainwater volume from precipitation, area,
  runoff and efficiency (`Vdisp = P * A * C * eta`).
- [`rh_metrics()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
  and accessors
  ([`rh_attendance()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md),
  [`rh_deficit_total()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md),
  [`rh_overflow_total()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)).
- Guarantee-based sizing:
  [`rh_guaranteed_demand()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md),
  [`rh_guaranteed_capacity()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md),
  [`rh_required_area()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md),
  with `bisection`, `optimize` (base R
  [`stats::optimize`](https://rdrr.io/r/stats/optimize.html)) and `step`
  solvers.
- [`rh_daily_demand()`](https://arturlourenco.github.io/rharv/reference/rh_daily_demand.md)
  and plotting helpers
  [`rh_plot_climatology()`](https://arturlourenco.github.io/rharv/reference/rh_plot_climatology.md)/`autoplot()`.
- Example datasets `precip_pi` and `areas_pi`, and the
  `ifpb-pi-case-study` vignette (a worked example).
