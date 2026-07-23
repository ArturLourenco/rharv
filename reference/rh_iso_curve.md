# Iso-guarantee design curves

Builds the "design curve" data behind
[`rh_plot_iso()`](https://arturlourenco.github.io/rharv/reference/rh_plot_iso.md):
for each target guarantee level and each value of the x-parameter, it
solves (via
[`rh_size_for()`](https://arturlourenco.github.io/rharv/reference/rh_size_for.md))
for the y-parameter that reaches that level. The result is a family of
iso-guarantee curves relating two design levers (the third is fixed in
`base`), the rainwater-harvesting analogue of a reservoir design chart.

## Usage

``` r
rh_iso_curve(
  precip,
  base = list(),
  x,
  x_values,
  y,
  levels = c(80, 90, 95, 100),
  metric = "attendance_pct",
  by = NULL,
  by_values = NULL,
  tol = 0.01,
  dates = NULL,
  climatology = FALSE
)
```

## Arguments

- precip:

  Numeric vector of daily precipitation (mm). If `climatology = TRUE`,
  it is first collapsed to its day-of-year mean (see `dates`).

- base:

  Named list of the fixed
  [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
  arguments (everything except `vary`).

- x, y:

  The two parameters to relate (each `"area"`, `"capacity"` or
  `"demand"`); `x` is the axis you set, `y` is solved for.

- x_values:

  Numeric values of `x`.

- levels:

  Target guarantee levels (default `c(80, 90, 95, 100)`).

- metric:

  Guarantee metric: `"attendance_pct"` (default, volumetric) or
  `"reliability_pct"` (time-based).

- by:

  Optional third parameter to vary as panels/colour (e.g. `"demand"`).

- by_values:

  Values of `by` (required if `by` is set).

- tol:

  Search tolerance (in units of `vary`).

- dates:

  Optional date vector aligned with `precip`, required only when
  `climatology = TRUE`.

- climatology:

  If `TRUE`, simulate on the day-of-year climatology (much faster)
  instead of the full series. Default `FALSE`.

## Value

A long data frame with columns named after `x`, `y`, plus `level` (and
`by` if used). Unreachable points are `NA`. Axis names are stored in
`attr(, "x")`, `attr(, "y")`, `attr(, "by")`, `attr(, "metric")`.

## Examples

``` r
iso <- rh_iso_curve(
  precip_pi$value, base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
  x = "area", x_values = seq(1000, 6000, length.out = 8),
  y = "capacity", levels = c(80, 90, 100),
  dates = precip_pi$date, climatology = TRUE
)
head(iso)
#>       area  capacity level
#> 1 1000.000 1237.9323    80
#> 2 1714.286  773.2401    80
#> 3 2428.571  623.2971    80
#> 4 3142.857  490.6135    80
#> 5 3857.143  374.4151    80
#> 6 4571.429  278.0653    80
```
