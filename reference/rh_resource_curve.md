# Required resources versus guarantee level

Builds the data behind
[`rh_plot_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_resource_curve.md):
for each guarantee level, the amount of each resource (reservoir
capacity and/or catchment area) required to reach it, at the operating
point given in `base`. This is the closest analogue to the reservoir
stage-area-volume curve, with the guarantee playing the role of the
"stage".

## Usage

``` r
rh_resource_curve(
  precip,
  base = list(),
  levels = seq(50, 100, by = 5),
  resources = c("capacity", "area"),
  metric = "attendance_pct",
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

  Named list with the operating point (`area`, `capacity`, `demand`,
  ...); each resource is solved for in turn while the others stay fixed.

- levels:

  Guarantee levels on the x-axis (default `seq(50, 100, by = 5)`).

- resources:

  Which resources to size: any of `"capacity"`, `"area"`, `"demand"`.
  Default `c("capacity", "area")`.

- metric:

  Guarantee metric: `"attendance_pct"` (default, volumetric) or
  `"reliability_pct"` (time-based).

- tol:

  Search tolerance (in units of `vary`).

- dates:

  Optional date vector aligned with `precip`, required only when
  `climatology = TRUE`.

- climatology:

  If `TRUE`, simulate on the day-of-year climatology (much faster)
  instead of the full series. Default `FALSE`.

## Value

A long data frame with columns `level, resource, value` (`NA` where a
level is unreachable); the metric is in `attr(, "metric")`.

## Examples

``` r
rc <- rh_resource_curve(
  precip_pi$value,
  base = list(demand = 6.6, area = 4170, capacity = 400,
              runoff = 0.85, efficiency = 1),
  levels = seq(60, 100, by = 10),
  dates = precip_pi$date, climatology = TRUE
)
rc
#>    level resource      value
#> 1     60 capacity    0.00000
#> 2     70 capacity   86.78482
#> 3     80 capacity  328.35035
#> 4     90 capacity  569.90667
#> 5    100 capacity  811.47220
#> 6     60     area 1510.84137
#> 7     70     area 2338.16528
#> 8     80     area 3699.86725
#> 9     90     area 5684.63135
#> 10   100     area 9735.23712
```
