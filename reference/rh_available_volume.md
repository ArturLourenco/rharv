# Available rainwater volume (ABNT NBR 15527:2019)

Computes the theoretical volume of rainwater available for capture,
using the equation given in ABNT NBR 15527:2019, item 4.1.6:

## Usage

``` r
rh_available_volume(precip, area, runoff = 0.8, efficiency = 0.85)
```

## Arguments

- precip:

  Numeric vector of precipitation depths, in millimetres (mm). Each
  element is one time step (typically a day).

- area:

  Catchment area in square metres (m2). May be a vector of per-block
  areas, in which case the total `sum(area)` is used.

- runoff:

  Runoff coefficient `C` (the *coeficiente de escoamento superficial*),
  dimensionless in `[0, 1]`. Scalar or vector recycled to
  `length(precip)`. Default `0.8`.

- efficiency:

  System efficiency `eta` (dimensionless, `[0, 1]`), accounting for the
  first-flush diverter/solids-discard device. Scalar or vector recycled
  to `length(precip)`. ABNT NBR 15527:2019 recommends `0.85` when no
  data are available (the default).

## Value

A numeric vector, the same length as `precip`, of available volumes in
cubic metres (m3).

## Details

\$\$V\_{disp} = P \times A \times C \times \eta\$\$

The result is converted from litres to cubic metres (division by 1000).

## Examples

``` r
# Daily available volume for a 775.53 m2 roof over three days
rh_available_volume(precip = c(0, 12, 30), area = 775.53)
#> [1]  0.000000  6.328325 15.820812
```
