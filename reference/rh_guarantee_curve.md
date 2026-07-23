# Zero-deficit guarantee frontier

Traces, over a range of one design variable, the guaranteed value of
another: for each `vary` value it calls the matching sizing function
([`rh_guaranteed_demand()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md),
[`rh_guaranteed_capacity()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md)
or
[`rh_required_area()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md))
to find the `target` that yields zero deficit. For example, vary the
capacity and read the guaranteed demand for each, giving the
demand-versus-capacity frontier.

## Usage

``` r
rh_guarantee_curve(
  precip,
  base = list(),
  vary,
  values,
  target,
  method = "bisection",
  tol = 0.001,
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
  arguments needed by the chosen sizing function (everything except
  `vary` and `target`).

- vary:

  Variable to range over: `"capacity"`, `"area"` or `"demand"`.

- values:

  Numeric values of `vary`.

- target:

  Variable to solve for (zero deficit): `"demand"`, `"capacity"` or
  `"area"`. Must differ from `vary`.

- method, tol:

  Passed to the sizing function (`"bisection"`/`"optimize"`/`"step"`).

- dates:

  Optional date vector aligned with `precip`, required only when
  `climatology = TRUE`.

- climatology:

  If `TRUE`, simulate on the day-of-year climatology (much faster)
  instead of the full series. Default `FALSE`.

## Value

A data frame with two columns named after `vary` and `target`; the names
are also stored in `attr(, "vary")` and `attr(, "target")`. Points where
no feasible `target` exists are `NA`.

## Examples

``` r
rh_guarantee_curve(
  precip_pi$value, base = list(area = 4170, runoff = 0.85, efficiency = 1),
  vary = "capacity", values = seq(100, 1000, by = 100), target = "demand",
  dates = precip_pi$date, climatology = TRUE
)
#>    capacity   demand
#> 1       100 2.150582
#> 2       200 3.055740
#> 3       300 3.781799
#> 4       400 4.422881
#> 5       500 5.014123
#> 6       600 5.536078
#> 7       700 6.049458
#> 8       800 6.546215
#> 9       900 7.013268
#> 10     1000 7.459210
```
