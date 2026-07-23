# Scientific regression: the bundled data + generic functions must reproduce
# the published IFPB-PI case study (XVII SRHNE). In that study the runoff and
# system efficiency were combined into a single coefficient C = 0.85, so here
# runoff = 0.85 and efficiency = 1. Volumes are in m3; the reservoir is full at
# the start (initial = capacity), per NBR 15527:2007 A.2.

test_that("the IFPB-PI case study (C1/C2) is reproduced", {
  area_total <- sum(areas_pi$area_m2)
  dem <- rh_daily_demand(1089, 6.03)
  yr <- as.integer(format(precip_pi$date, "%Y"))

  c1 <- rh_simulate(precip_pi$value, demand = dem, area = area_total,
                    capacity = 400, runoff = 0.85, efficiency = 1, initial = 400)
  c2 <- rh_simulate(precip_pi$value[yr >= 1989], demand = dem, area = area_total,
                    capacity = 400, runoff = 0.85, efficiency = 1, initial = 400)

  # Attendance (%) reported in the paper: C1 = 69.26, C2 = 70.45
  expect_equal(c1$summary$attendance_pct, 69.26, tolerance = 1e-3)
  expect_equal(c2$summary$attendance_pct, 70.45, tolerance = 1e-3)

  # Table 1 per-year volumes for C1 (106 years): vertimento 1235.40,
  # deficit 737.26, usable 1657.40 m3/year
  n_years <- length(unique(yr))
  expect_equal(c1$summary$overflow_total / n_years, 1235.40, tolerance = 1e-3)
  expect_equal(c1$summary$deficit_total / n_years, 737.26, tolerance = 1e-3)
  expect_equal(c1$summary$usable_volume / n_years, 1657.40, tolerance = 1e-3)
})

test_that("guarantee figures match the case study order of magnitude", {
  area_total <- sum(areas_pi$area_m2)
  dem <- rh_daily_demand(1089, 6.03)

  # Guaranteed demand ~ 1900 L/day; guaranteed capacity > 3,000,000 L
  dg <- rh_guaranteed_demand(precip_pi$value, area = area_total, capacity = 400,
                             runoff = 0.85, efficiency = 1, initial = 400, tol = 1e-3)
  cg <- rh_guaranteed_capacity(precip_pi$value, demand = dem, area = area_total,
                               runoff = 0.85, efficiency = 1, tol = 1)
  expect_gt(dg * 1000, 1700)
  expect_lt(dg * 1000, 2100)
  expect_gt(cg * 1000, 3e6)
})
