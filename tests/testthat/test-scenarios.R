test_that("rh_seasonal_demand expands to the daily length", {
  d <- rh_seasonal_demand(rep(5, 12), precip_pi$date)
  expect_equal(length(d), nrow(precip_pi))
  expect_true(all(d == 5))
  expect_error(rh_seasonal_demand(rep(5, 11), precip_pi$date), "12")
})

test_that("rh_scenarios_from_years reorders whole years by total", {
  inc <- rh_scenarios_from_years(precip_pi, order = "increasing")
  expect_equal(nrow(inc), nrow(precip_pi))
  expect_true(all(c("step", "year", "date", "value") %in% names(inc)))
  yt <- tapply(inc$value, inc$year, sum)
  ord_years <- unique(inc$year)
  expect_lte(yt[[as.character(ord_years[1])]],
             yt[[as.character(ord_years[length(ord_years)])]])
})

test_that("rh_compare binds a named list of sims", {
  a <- rh_simulate(precip_pi$value, 6.6, 4170, 400, runoff = 0.85, efficiency = 1)
  b <- rh_simulate(precip_pi$value, 4, 4170, 400, runoff = 0.85, efficiency = 1)
  cmp <- rh_compare(list(high = a, low = b))
  expect_equal(nrow(cmp), 2)
  expect_true("name" %in% names(cmp))
  expect_error(rh_compare(list(a, b)), "named")
})
