# Plot precipitation variability

Draws the output of
[`rh_series_spread()`](https://arturlourenco.github.io/rharv/reference/rh_series_spread.md):
the mean per group with a shaded 10th-90th percentile band, highlighting
how variable the rainfall is across years (or months/days of the year).

## Usage

``` r
rh_plot_spread(spread)
```

## Arguments

- spread:

  A data frame from
  [`rh_series_spread()`](https://arturlourenco.github.io/rharv/reference/rh_series_spread.md).

## Value

A ggplot2 object.

## Examples

``` r
sp <- rh_series_spread(precip_pi, by = "year")
if (requireNamespace("ggplot2", quietly = TRUE)) rh_plot_spread(sp)
```
