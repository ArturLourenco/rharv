# Launch the rharv explorer (Shiny app)

Opens an interactive Shiny app to explore a rainwater harvesting system:
move sliders for catchment area, reservoir capacity, demand, runoff,
efficiency and initial storage, pick the performance metric, and watch
the reservoir behaviour, the metrics, the area-capacity trade-off
surface and the guarantee values update live. A "fast mode" simulates on
the day-of-year climatology so the trade-off grid recomputes quickly.

## Usage

``` r
rh_explore(...)

rh_app(...)
```

## Arguments

- ...:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Invisibly `NULL`; called to launch the app.

## Details

Requires the suggested packages shiny, bslib and ggplot2.

## Examples

``` r
if (FALSE) { # \dontrun{
rh_explore()
} # }
```
