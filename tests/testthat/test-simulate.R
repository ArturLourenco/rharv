test_that("mass balance is conserved for both timings", {
  precip <- fx_precip(8)
  for (timing in c("after_demand", "before_demand")) {
    sim <- rh_simulate(precip, demand = 0.4, area = 775.53, capacity = 5,
                       overflow_timing = timing)
    s <- sim$summary
    lhs <- s$captured_total + sim$inputs$initial
    rhs <- s$final_storage + s$supplied_total + s$overflow_total
    expect_equal(lhs, rhs)
  }
})

test_that("zero rain drains the reservoir then accrues deficit", {
  sim <- rh_simulate(rep(0, 10), demand = 1, area = 100, capacity = 5) # initial = 5 (full)
  ser <- sim$series
  expect_equal(sum(ser$overflow), 0)
  expect_equal(ser$storage[1:6], c(4, 3, 2, 1, 0, 0))
  expect_equal(sim$summary$deficit_total, 5)
  expect_equal(sim$summary$days_unmet, 5)
  expect_equal(sim$summary$attendance_pct, 50)
})

test_that("inflow below demand never overflows", {
  sim <- rh_simulate(rep(2, 30), demand = 0.5, area = 100, capacity = 100, initial = 0)
  expect_equal(sim$summary$overflow_total, 0)
  expect_true(all(sim$series$storage <= 100))
})

test_that("large inflow saturates storage at capacity and spills", {
  sim <- rh_simulate(rep(100, 10), demand = 0, area = 1000, capacity = 1, initial = 0)
  expect_true(all(sim$series$storage <= 1 + 1e-9))
  expect_equal(max(sim$series$storage), 1)
  expect_gt(sim$summary$overflow_total, 0)
})

test_that("scalar and vector demand give identical results", {
  precip <- fx_precip(4)
  a <- rh_simulate(precip, demand = 0.3, area = 100, capacity = 2)
  b <- rh_simulate(precip, demand = rep(0.3, length(precip)), area = 100, capacity = 2)
  expect_equal(a$series, b$series)
})

test_that("before_demand spills at least as much as after_demand", {
  precip <- fx_precip(8)
  a <- rh_simulate(precip, 0.4, 775.53, 5, overflow_timing = "after_demand")
  b <- rh_simulate(precip, 0.4, 775.53, 5, overflow_timing = "before_demand")
  expect_gte(b$summary$overflow_total, a$summary$overflow_total)
})

test_that("simulate validates its inputs", {
  expect_error(rh_simulate(c(0, 10), 1, 100, capacity = 5, initial = 10), "initial")
  expect_error(rh_simulate(c(0, 10), 1, 100, capacity = -5), "capacity")
  expect_error(rh_simulate(c(0, 10), 1, -100, capacity = 5), "area")
  expect_error(rh_simulate(c(0, 10), c(1, 2, 3), 100, capacity = 5), "demand")
})
