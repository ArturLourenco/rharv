test_that("guaranteed demand yields zero deficit and is the supremum", {
  precip <- fx_precip(8)
  dg <- rh_guaranteed_demand(precip, area = 775.53, capacity = 5)
  expect_lte(rh_deficit_total(rh_simulate(precip, dg, 775.53, 5)), 1e-3)
  expect_gt(rh_deficit_total(rh_simulate(precip, dg + 0.1, 775.53, 5)), 0)
})

test_that("bisection and step solvers agree for guaranteed demand", {
  precip <- fx_precip(6)
  dgb <- rh_guaranteed_demand(precip, 775.53, 5, method = "bisection", tol = 1e-4)
  dgs <- rh_guaranteed_demand(precip, 775.53, 5, method = "step", step = 2e-3)
  expect_equal(dgb, dgs, tolerance = 3e-3)
})

test_that("guaranteed capacity yields zero deficit at the demand", {
  precip <- fx_precip(8)
  cg <- rh_guaranteed_capacity(precip, demand = 0.4, area = 775.53)
  expect_lte(rh_deficit_total(rh_simulate(precip, 0.4, 775.53, cg, initial = cg)), 1e-3)
  expect_gt(rh_deficit_total(rh_simulate(precip, 0.4, 775.53, cg * 0.5, initial = cg * 0.5)), 0)
})

test_that("required area yields zero deficit at the demand", {
  precip <- fx_precip(8)
  ar <- rh_required_area(precip, demand = 0.4, capacity = 5)
  expect_lte(rh_deficit_total(rh_simulate(precip, 0.4, ar, 5)), 1e-3)
  expect_gt(rh_deficit_total(rh_simulate(precip, 0.4, ar * 0.5, 5)), 0)
})

test_that("optimize solver agrees with bisection", {
  precip <- fx_precip(6)
  dgb <- rh_guaranteed_demand(precip, 775.53, 5, method = "bisection", tol = 1e-4)
  dgo <- rh_guaranteed_demand(precip, 775.53, 5, method = "optimize", tol = 1e-4)
  expect_equal(dgb, dgo, tolerance = 1e-2)

  cgb <- rh_guaranteed_capacity(precip, demand = 0.4, area = 775.53,
                                method = "bisection", tol = 1e-3)
  cgo <- rh_guaranteed_capacity(precip, demand = 0.4, area = 775.53,
                                method = "optimize", tol = 1e-3)
  expect_equal(cgb, cgo, tolerance = 1e-2)
})
