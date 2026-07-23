# Guarantee-based sizing of rainwater harvesting systems

These functions find the design value that guarantees zero deficit over
the whole simulation, by repeatedly calling the engine
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md):

## Usage

``` r
rh_guaranteed_demand(
  precip,
  area,
  capacity,
  runoff = 0.8,
  efficiency = 0.85,
  initial = capacity,
  overflow_timing = c("after_demand", "before_demand"),
  method = c("bisection", "optimize", "step"),
  tol = 0.001,
  step = NULL
)

rh_guaranteed_capacity(
  precip,
  demand,
  area,
  runoff = 0.8,
  efficiency = 0.85,
  initial = NULL,
  overflow_timing = c("after_demand", "before_demand"),
  method = c("bisection", "optimize", "step"),
  tol = 0.001,
  step = NULL,
  max_capacity = NULL
)

rh_required_area(
  precip,
  demand,
  capacity,
  runoff = 0.8,
  efficiency = 0.85,
  initial = capacity,
  overflow_timing = c("after_demand", "before_demand"),
  method = c("bisection", "optimize", "step"),
  tol = 0.001,
  step = NULL,
  max_area = NULL
)
```

## Arguments

- precip:

  Numeric vector of precipitation depths, in millimetres (mm). Each
  element is one time step (typically a day).

- area:

  Catchment area in square metres (m2). May be a vector of per-block
  areas, in which case the total `sum(area)` is used.

- capacity:

  Reservoir capacity `V`, in cubic metres (m3).

- runoff:

  Runoff coefficient `C` (the *coeficiente de escoamento superficial*),
  dimensionless in `[0, 1]`. Scalar or vector recycled to
  `length(precip)`. Default `0.8`.

- efficiency:

  System efficiency `eta` (dimensionless, `[0, 1]`), accounting for the
  first-flush diverter/solids-discard device. Scalar or vector recycled
  to `length(precip)`. ABNT NBR 15527:2019 recommends `0.85` when no
  data are available (the default).

- initial:

  Initial stored volume `S(0)`, in cubic metres (m3). For
  `rh_guaranteed_demand()` and `rh_required_area()` it defaults to
  `capacity` (full reservoir). For `rh_guaranteed_capacity()` the
  default `NULL` makes the reservoir start full at each trial capacity,
  and an explicit value is clamped to the trial capacity during the
  search.

- overflow_timing:

  Order of operations within a time step:

  - `"after_demand"` (default): inflow is added, demand is withdrawn,
    and only the remainder can overflow. This is the continuity-equation
    form `S(t) = S(t-1) + Q(t) - D(t)` clamped to `[0, V]`, the YBS
    (yield before spillage) operating rule of the rainwater-tank
    literature (Jenkins et al., 1978; Fewkes and Butler, 2000), and
    reproduces the published case-study results.

  - `"before_demand"`: inflow is added and the reservoir overflows
    before demand is withdrawn, the YAS (yield after spillage) rule. It
    spills more water, giving slightly conservative yields, and is
    provided for sensitivity analysis.

- method:

  Solver: `"bisection"` (default), `"optimize"` (automatic optimisation
  with [`stats::optimize()`](https://rdrr.io/r/stats/optimize.html)) or
  `"step"` (incremental search by `step`).

- tol:

  Tolerance: a deficit not greater than `tol` is treated as zero, and
  the solver stops when the search interval is narrower than `tol`.

- step:

  Increment for `method = "step"`. Defaults to one thousandth of the
  search upper bound.

- demand:

  Non-potable demand per time step, in cubic metres (m3). Scalar or
  vector recycled to `length(precip)`.

- max_capacity:

  Optional upper bound for the capacity search. Defaults to the total
  demand (which trivially guarantees no deficit), grown if needed.

- max_area:

  Optional upper bound for the area search. Grown automatically until a
  feasible area is found.

## Value

A single numeric value: the guaranteed demand (m3/day), guaranteed
capacity (m3) or required area (m2).

## Details

- `rh_guaranteed_demand()` - the largest constant daily demand that can
  be met with no deficit (the *demanda garantia*).

- `rh_guaranteed_capacity()` - the smallest reservoir capacity giving no
  deficit (the *capacidade/volume garantia*). The reservoir is assumed
  full at the start, so `initial` follows the trial capacity unless set.

- `rh_required_area()` - the smallest catchment area giving no deficit.

Because the total deficit is monotone in each of these variables, the
default solver is an efficient bisection controlled by `tol`. Two
alternatives are available: an automatic optimiser (`"optimize"`, base R
[`stats::optimize()`](https://rdrr.io/r/stats/optimize.html)) and a
simple incremental search (`"step"`, a `for`-loop advancing by `step`).

## Examples

``` r
precip <- rep(c(0, 0, 30, 0, 0, 0, 50), 8)
rh_guaranteed_demand(precip, area = 775.53, capacity = 5)
#> [1] 1.666442
rh_guaranteed_capacity(precip, demand = 0.4, area = 775.53)
#> [1] 1.200391
rh_required_area(precip, demand = 0.4, capacity = 5)
#> [1] 42.3708
```
