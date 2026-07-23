clim_pi <- function() {
  as.numeric(tapply(precip_pi$value, format(precip_pi$date, "%m-%d"), mean))
}

test_that("rh_size_for reaches the target metric", {
  cf <- rh_size_for(precip_pi$value,
                    base = list(demand = 6.6, area = 4170, runoff = 0.85, efficiency = 1),
                    vary = "capacity", target_value = 90,
                    dates = precip_pi$date, climatology = TRUE)
  clim <- clim_pi()
  att <- rh_simulate(clim, 6.6, 4170, cf, runoff = 0.85, efficiency = 1)$summary$attendance_pct
  expect_gte(att, 90 - 0.5)
  att2 <- rh_simulate(clim, 6.6, 4170, cf * 0.8, runoff = 0.85, efficiency = 1)$summary$attendance_pct
  expect_lt(att2, 90)
})

test_that("rh_size_for rejects non-guarantee metrics", {
  expect_error(
    rh_size_for(precip_pi$value, base = list(demand = 6.6, area = 4170),
                vary = "capacity", target_value = 90, metric = "deficit_total",
                dates = precip_pi$date, climatology = TRUE),
    "attendance_pct"
  )
})

test_that("rh_iso_curve: required capacity falls as area grows at fixed guarantee", {
  iso <- rh_iso_curve(precip_pi$value, base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
                      x = "area", x_values = seq(1500, 6000, length.out = 6), y = "capacity",
                      levels = c(90, 100), dates = precip_pi$date, climatology = TRUE)
  expect_true(all(c("area", "capacity", "level") %in% names(iso)))
  expect_identical(attr(iso, "y"), "capacity")
  s90 <- iso[iso$level == 90, ]
  s90 <- s90[order(s90$area), ]
  expect_true(all(diff(s90$capacity) <= 1e-6, na.rm = TRUE))
  skip_if_not_installed("ggplot2")
  expect_no_error(ggplot2::ggplot_build(rh_plot_iso(iso)))
})

test_that("rh_iso_curve supports a 'by' variable", {
  iso <- rh_iso_curve(precip_pi$value, base = list(runoff = 0.85, efficiency = 1),
                      x = "area", x_values = c(2000, 4000), y = "capacity", levels = 90,
                      by = "demand", by_values = c(4, 6),
                      dates = precip_pi$date, climatology = TRUE)
  expect_true("demand" %in% names(iso))
  expect_identical(attr(iso, "by"), "demand")
  expect_error(
    rh_iso_curve(precip_pi$value, base = list(), x = "area", x_values = 2000,
                 y = "capacity", by = "demand"),
    "by_values"
  )
})

test_that("rh_resource_curve grows with the guarantee level", {
  rc <- rh_resource_curve(precip_pi$value,
          base = list(demand = 6.6, area = 4170, capacity = 400,
                      runoff = 0.85, efficiency = 1),
          levels = seq(60, 100, by = 10), dates = precip_pi$date, climatology = TRUE)
  expect_true(all(c("level", "resource", "value") %in% names(rc)))
  cap <- rc[rc$resource == "capacity", ]
  cap <- cap[order(cap$level), ]
  expect_true(all(diff(cap$value) >= -1e-6, na.rm = TRUE))
  skip_if_not_installed("ggplot2")
  expect_no_error(ggplot2::ggplot_build(rh_plot_resource_curve(rc)))
})

test_that("rh_size_for(vary='demand') is not clipped at the zero-deficit bound", {
  clim <- clim_pi()
  d100 <- rh_guaranteed_demand(clim, area = 4170, capacity = 400,
                               runoff = 0.85, efficiency = 1, initial = 400)
  d80 <- rh_size_for(precip_pi$value,
                     base = list(area = 4170, capacity = 400,
                                 runoff = 0.85, efficiency = 1, initial = 400),
                     vary = "demand", target_value = 80,
                     dates = precip_pi$date, climatology = TRUE)
  # the 80%-attendance demand must exceed the zero-deficit (100%) maximum
  expect_gt(d80, d100 * 1.05)
  att <- rh_simulate(clim, d80, 4170, 400, runoff = 0.85, efficiency = 1,
                     initial = 400)$summary$attendance_pct
  expect_gte(att, 80 - 0.5)
  expect_lte(att, 81)
})

test_that("rh_size_for(vary='capacity') clamps a fixed initial and accepts vector demand", {
  clim <- clim_pi()
  # fixed initial in base used to abort ("initial cannot exceed capacity")
  v1 <- rh_size_for(clim,
                    base = list(demand = 6.6, area = 4170, runoff = 0.85,
                                efficiency = 1, initial = 400),
                    vary = "capacity", target_value = 80)
  expect_true(is.finite(v1) && v1 >= 0)
  # per-day demand vector used to break the default upper bound
  v2 <- rh_size_for(clim,
                    base = list(demand = rep(6.6, length(clim)), area = 4170,
                                runoff = 0.85, efficiency = 1),
                    vary = "capacity", target_value = 90)
  expect_true(is.finite(v2) && v2 > 0)
})

test_that("rh_size_for validates the base list", {
  expect_error(
    rh_size_for(clim_pi(), base = list(demand = 6.6), vary = "capacity",
                target_value = 90),
    "area"
  )
  expect_error(
    rh_size_for(clim_pi(), base = list(demand = 6.6, area = 100, capacity = 5),
                vary = "capacity", target_value = 0),
    "target_value"
  )
})

test_that("rh_guarantee_curve returns NA for structurally infeasible points", {
  clim <- clim_pi()
  gc <- rh_guarantee_curve(
    clim, base = list(area = 50, runoff = 0.85, efficiency = 1, initial = 0),
    vary = "demand", values = c(50), target = "capacity", tol = 1
  )
  expect_true(is.na(gc$capacity[1]))
})

test_that("rh_plot_resource_curve falls back to facets when a resource is all NA", {
  skip_if_not_installed("ggplot2")
  rc <- data.frame(level = c(60, 70, 60, 70),
                   resource = c("capacity", "capacity", "area", "area"),
                   value = c(10, 20, NA, NA))
  expect_no_error(ggplot2::ggplot_build(rh_plot_resource_curve(rc)))
})
