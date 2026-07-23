# Daily water-balance simulation of a rainwater harvesting reservoir

Simulates the daily operation of a finite rainwater reservoir using the
*method of simulation* of ABNT NBR 15527:2007 (Annex A.2), with the
available-volume equation of NBR 15527:2019 (see
[`rh_available_volume()`](https://arturlourenco.github.io/rharv/reference/rh_available_volume.md)).
The mass-balance (continuity) equation for a finite reservoir is

## Usage

``` r
rh_simulate(
  precip,
  demand,
  area,
  capacity,
  runoff = 0.8,
  efficiency = 0.85,
  initial = capacity,
  overflow_timing = c("after_demand", "before_demand")
)
```

## Arguments

- precip:

  Numeric vector of precipitation depths, in millimetres (mm). Each
  element is one time step (typically a day).

- demand:

  Non-potable demand per time step, in cubic metres (m3). Scalar or
  vector recycled to `length(precip)`.

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

  Initial stored volume `S(0)`, in cubic metres (m3). Defaults to
  `capacity` (a full reservoir, per the NBR 15527:2007 A.2 hypothesis).
  Must not exceed `capacity`.

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

## Value

An object of class `rharv_sim`: a list with elements `series` (a data
frame with one row per time step and columns `step`, `captured`,
`overflow`, `supplied`, `deficit`, `storage`), `inputs` (the parameters
used) and `summary` (the metrics returned by
[`rh_metrics()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)).
The [`print()`](https://rdrr.io/r/base/print.html) and
[`summary()`](https://rdrr.io/r/base/summary.html) methods give a quick
overview.

## Details

\$\$S(t) = Q(t) + S(t-1) - D(t), \quad 0 \le S(t) \le V\$\$

where `Q(t)` is the captured volume, `D(t)` the demand and `V` the
reservoir capacity. Evaporation is not considered. Following the
standard, the reservoir is assumed full at the start
(`initial = capacity` by default).

## Examples

``` r
precip <- c(0, 0, 25, 0, 40, 0, 0)
sim <- rh_simulate(precip, demand = 0.5, area = 775.53, capacity = 5)
sim
#> <rharv_sim>
#>   steps: 7 | area: 775.53 m2 | capacity: 5 m3 | timing: after_demand
#>   attendance: 100.0% | reliability: 100.0% | days unmet: 0
#>   totals (m3): deficit 0.00 | overflow 31.78 | usable 2.50
rh_metrics(sim)
#>   n captured_total overflow_total supplied_total deficit_total demand_total
#> 1 7       34.27843       31.77843            3.5             0          3.5
#>   usable_volume final_storage days_unmet reliability_pct attendance_pct
#> 1           2.5             4          0             100            100
#>   attendance_pct_legacy
#> 1                   100
```
