# Plot a rainwater harvesting simulation

Draws the daily series of a
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
result: reservoir storage, captured volume (inflow) and deficit over
time. Requires the ggplot2 package.

## Usage

``` r
# S3 method for class 'rharv_sim'
autoplot(object, vars = c("storage", "captured", "deficit"), ...)

# S3 method for class 'rharv_sim'
plot(x, vars = c("storage", "captured", "deficit"), ...)
```

## Arguments

- object, x:

  A `rharv_sim` object from
  [`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md).

- vars:

  Character vector of series to draw; any of `"storage"`, `"captured"`,
  `"overflow"`, `"supplied"`, `"deficit"`. Defaults to storage, captured
  and deficit.

- ...:

  Passed on (currently unused).

## Value

A ggplot2 object.

## Examples

``` r
sim <- rh_simulate(rep(c(0, 0, 30, 0, 50), 10), demand = 0.4,
                   area = 775.53, capacity = 5)
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::autoplot(sim)
}
```
