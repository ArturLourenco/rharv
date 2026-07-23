#' Estimate daily water demand from population
#'
#' Converts a population and a per-capita daily water use into a total daily
#' demand, a convenience for parameterising [rh_simulate()].
#'
#' @param population Number of people served.
#' @param per_capita_l Per-capita daily water use, in litres per person per day.
#'   Default `6.03` (a value reported for educational institutions).
#'
#' @return Daily demand in cubic metres per day (m3/day).
#' @export
#' @examples
#' rh_daily_demand(1089, 6.03)
rh_daily_demand <- function(population, per_capita_l = 6.03) {
  .check_number(population, "population", lower = 0)
  .check_number(per_capita_l, "per_capita_l", lower = 0)
  population * per_capita_l / 1000
}
