# rharv 0.3.0

Release polish and fixes from a pre-release review.

* Fixed `rh_size_for(vary = "demand")` for targets below 100%: the search
  bound was clipped at the zero-deficit maximum, silently understating the
  result (also affected `rh_iso_curve()`/`rh_resource_curve()` solving for
  demand at sub-100 levels).
* `rh_size_for(vary = "capacity")` now clamps a fixed `initial` to the trial
  capacity (it used to error) and accepts a per-day demand vector; it also
  validates that `base` contains the required parameters.
* `rh_guarantee_curve()` returns `NA` for infeasible points instead of
  aborting the whole frontier; `rh_guaranteed_capacity()` detects
  supply-limited (structurally infeasible) problems early with a clear
  message.
* `rh_plot_resource_curve()` falls back to facets when a resource is entirely
  unreachable; `rh_plot_monthly_balance()` labels months correctly for
  partial-year simulations; `rh_plot_design_curve()` gives a friendly error
  when grid attributes were lost; `rh_series_spread()` tolerates all-NA
  groups; the `step` solver rejects non-positive steps.
* Shiny explorer: debounced recomputation of the trade-off grid and guarantee
  values, fast-mode now also applies to the guarantee values, and the initial
  storage slider stays consistent with the capacity slider.

* The demo notebook (`rh_demo()`) was rewritten as an annotated, paper-style
  document (in Portuguese): every section states the model and its equations,
  runs the code, and explains how to read the result, covering the YAS and YBS
  operating rules, the mass-balance check, the standard versus legacy
  attendance algebra, and a reading guide for each chart.
* `rh_simulate()` documentation now names the two `overflow_timing` rules by
  their literature names (YBS = `after_demand`, YAS = `before_demand`).
* pkgdown now renders equations properly (MathJax enabled).

# rharv 0.2.0

Analysis tools, decision plots and an interactive app.

* `rh_sweep()` (one parameter) and `rh_grid()` (two parameters) compute
  performance metrics over a range of designs, with a fast day-of-year
  `climatology` mode; metrics are selectable (`"attendance_pct"`,
  `"reliability_pct"`, ...).
* `rh_plot_tradeoff()` draws the area x capacity surface with iso-guarantee
  contours, and `rh_plot_levers()` compares the levers (more roof, more tank or
  less demand).
* `rh_guarantee_curve()` traces the zero-deficit frontier, `rh_plot_syr()` the
  storage-yield-reliability curves and `rh_plot_design_curve()` the
  dimensionless, site-transferable version.
* `rh_size_for()` sizes any lever to an arbitrary guarantee level;
  `rh_iso_curve()` with `rh_plot_iso()` draws iso-guarantee curves relating two
  levers (optionally faceted by a third); `rh_resource_curve()` with
  `rh_plot_resource_curve()` plots the required capacity and area against the
  guarantee level on a dual axis, the stage-area-volume analogue.
* Diagnostic plots `rh_plot_behaviour()`, `rh_plot_monthly_balance()` and
  `rh_plot_failure_calendar()`.
* Variability and scenario helpers: `rh_series_spread()` with
  `rh_plot_spread()`, `rh_seasonal_demand()` (monthly demand profile),
  `rh_scenarios_from_years()` (dry-to-wet or wet-to-dry stress series) and
  `rh_compare()`.
* `rh_explore()` and `rh_app()` launch a Shiny explorer to vary parameters and
  watch the behaviour, metrics, trade-off surface and guarantee values update
  live.
* New `analysis-and-sizing` vignette, and a full-feature demo notebook shipped
  with the package: open it in your editor with `rh_demo()`.

# rharv 0.1.0

Initial release.

* `rh_simulate()` runs the daily reservoir water-balance simulation, returning
  an `rharv_sim` object with `print()`, `summary()`, `as.data.frame()` and
  `autoplot()` methods.
* `rh_available_volume()` computes the captured rainwater volume from
  precipitation, area, runoff and efficiency (`Vdisp = P * A * C * eta`).
* `rh_metrics()` and accessors (`rh_attendance()`, `rh_deficit_total()`,
  `rh_overflow_total()`).
* Guarantee-based sizing: `rh_guaranteed_demand()`, `rh_guaranteed_capacity()`,
  `rh_required_area()`, with `bisection`, `optimize` (base R `stats::optimize`)
  and `step` solvers.
* `rh_daily_demand()` and plotting helpers `rh_plot_climatology()`/`autoplot()`.
* Example datasets `precip_pi` and `areas_pi`, and the `ifpb-pi-case-study`
  vignette (a worked example).
