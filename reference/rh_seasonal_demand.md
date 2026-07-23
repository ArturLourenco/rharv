# Seasonal (monthly) demand as a daily vector

Expands a 12-value monthly demand profile into a daily demand vector
aligned with `dates`, ready to pass to `rh_simulate(demand = ...)`. Use
it to model demand that varies by month (e.g. higher in the dry season).

## Usage

``` r
rh_seasonal_demand(monthly, dates)
```

## Arguments

- monthly:

  Numeric vector of length 12 (Jan..Dec), demand per day in each month,
  in m3/day.

- dates:

  Date vector for which to build the daily demand.

## Value

A numeric vector the same length as `dates`.

## Examples

``` r
d <- rh_seasonal_demand(monthly = c(7,7,6,6,5,5,5,6,7,7,7,7), dates = precip_pi$date)
length(d)
#> [1] 38716
```
