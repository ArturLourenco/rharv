test_that("attendance is 100 when there is no deficit", {
  sim <- rh_simulate(rep(c(0, 50), 20), demand = 0.1, area = 775, capacity = 10)
  m <- rh_metrics(sim)
  expect_equal(m$deficit_total, 0)
  expect_equal(m$attendance_pct, 100)
})

test_that("metrics return one row with the expected columns", {
  sim <- rh_simulate(fx_precip(4), demand = 0.3, area = 100, capacity = 2)
  m <- rh_metrics(sim)
  expect_gte(m$attendance_pct, 0)
  expect_lte(m$attendance_pct, 100)
  expect_s3_class(m, "data.frame")
  expect_equal(nrow(m), 1L)
  expect_true(all(c(
    "overflow_total", "deficit_total", "usable_volume", "attendance_pct",
    "days_unmet", "reliability_pct", "attendance_pct_legacy"
  ) %in% names(m)))
})

test_that("usable volume equals captured minus overflow", {
  sim <- rh_simulate(fx_precip(8), demand = 0.4, area = 775.53, capacity = 5)
  s <- sim$summary
  expect_equal(s$usable_volume, s$captured_total - s$overflow_total)
})

test_that("attendance is non-decreasing in catchment area", {
  precip <- rep(c(0, 0, 40, 0, 0), 20)
  areas <- c(10, 50, 100, 500, 1000)
  att <- vapply(areas, function(a) {
    rh_simulate(precip, demand = 0.3, area = a, capacity = 2)$summary$attendance_pct
  }, numeric(1))
  expect_true(all(diff(att) >= -1e-6))
})

test_that("accessors agree with the summary", {
  sim <- rh_simulate(fx_precip(4), demand = 0.3, area = 100, capacity = 2)
  expect_equal(rh_deficit_total(sim), sim$summary$deficit_total)
  expect_equal(rh_overflow_total(sim), sim$summary$overflow_total)
  expect_equal(rh_attendance(sim), sim$summary$attendance_pct)
  expect_equal(rh_attendance(sim, "legacy"), sim$summary$attendance_pct_legacy)
})
