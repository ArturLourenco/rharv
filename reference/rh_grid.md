# Two-parameter grid of performance metrics

Runs
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
over a grid of two design parameters (by default catchment area and
reservoir capacity) and records performance metrics. This is the data
behind the area-capacity-demand trade-off surface
([`rh_plot_tradeoff()`](https://arturlourenco.github.io/rharv/reference/rh_plot_tradeoff.md)).

## Usage

``` r
rh_grid(
  precip,
  base = list(),
  x = "area",
  x_values,
  y = "capacity",
  y_values,
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

- x, y:

  Names of the two parameters to vary (each one of `"demand"`, `"area"`,
  `"capacity"`, `"runoff"`, `"efficiency"`, `"initial"`); defaults
  `x = "area"`, `y = "capacity"`.

- x_values, y_values:

  Numeric vectors of values for `x` and `y`.

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

A long data frame with columns named after `x` and `y`, plus `metric`
and `value`. The names of the two swept parameters are also stored in
`attr(, "x")` and `attr(, "y")`.

## Details

Each grid cell is one simulation. On a multi-decade daily series this is
a few hundred simulations (tens of seconds); for interactive use set
`climatology = TRUE` to simulate on the day-of-year mean (around 70x
faster).

## Examples

``` r
g <- rh_grid(precip_pi$value,
             base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
             x = "area", x_values = seq(500, 5000, length.out = 8),
             y = "capacity", y_values = seq(100, 1000, length.out = 8),
             dates = precip_pi$date, climatology = TRUE)
head(g)
#>       area capacity         metric    value
#> 1  500.000      100 attendance_pct 18.51622
#> 2 1142.857      100 attendance_pct 37.00024
#> 3 1785.714      100 attendance_pct 52.81987
#> 4 2428.571      100 attendance_pct 58.33713
#> 5 3071.429      100 attendance_pct 63.34860
#> 6 3714.286      100 attendance_pct 67.67787
```
