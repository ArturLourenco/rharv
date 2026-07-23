test_that("rh_sweep returns one row per value with the metric columns", {
  vals <- seq(100, 500, by = 100)
  s <- rh_sweep(precip_pi$value,
                base = list(demand = 6.6, area = 4170, runoff = 0.85, efficiency = 1),
                param = "capacity", values = vals,
                metrics = c("attendance_pct", "reliability_pct"),
                dates = precip_pi$date, climatology = TRUE)
  expect_equal(nrow(s), length(vals))
  expect_true(all(c("capacity", "attendance_pct", "reliability_pct") %in% names(s)))
  expect_true(all(diff(s$attendance_pct) >= -1e-6))  # non-decreasing in capacity
})

test_that("rh_sweep validates the metric name", {
  expect_error(
    rh_sweep(precip_pi$value, base = list(demand = 6.6, area = 4170),
             param = "capacity", values = c(100, 200), metrics = "bogus",
             dates = precip_pi$date, climatology = TRUE),
    "metric"
  )
})

test_that("rh_grid returns a long grid with x/y attributes and is monotone", {
  g <- rh_grid(precip_pi$value, base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
               x = "area", x_values = seq(1000, 5000, length.out = 5),
               y = "capacity", y_values = seq(100, 900, length.out = 5),
               metrics = "attendance_pct", dates = precip_pi$date, climatology = TRUE)
  expect_equal(nrow(g), 25)
  expect_identical(attr(g, "x"), "area")
  expect_identical(attr(g, "y"), "capacity")
  expect_true(all(c("area", "capacity", "metric", "value") %in% names(g)))
  a1 <- g[g$area == unique(g$area)[1], ]
  a1 <- a1[order(a1$capacity), ]
  expect_true(all(diff(a1$value) >= -1e-6))
})

test_that("climatology and full-series grids share the same shape", {
  base <- list(demand = 6.6, runoff = 0.85, efficiency = 1)
  gf <- rh_grid(precip_pi$value, base, x = "area", x_values = c(2000, 4000),
                y = "capacity", y_values = c(200, 400), metrics = "attendance_pct")
  gc <- rh_grid(precip_pi$value, base, x = "area", x_values = c(2000, 4000),
                y = "capacity", y_values = c(200, 400), metrics = "attendance_pct",
                dates = precip_pi$date, climatology = TRUE)
  expect_equal(dim(gf), dim(gc))
})
