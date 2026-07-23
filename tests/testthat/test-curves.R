test_that("rh_guarantee_curve gives a monotone zero-deficit frontier", {
  gc <- rh_guarantee_curve(
    precip_pi$value, base = list(area = 4170, runoff = 0.85, efficiency = 1),
    vary = "capacity", values = seq(100, 1000, by = 150), target = "demand",
    dates = precip_pi$date, climatology = TRUE
  )
  expect_true(all(c("capacity", "demand") %in% names(gc)))
  expect_identical(attr(gc, "vary"), "capacity")
  expect_identical(attr(gc, "target"), "demand")
  # guaranteed demand grows with capacity
  expect_true(all(diff(gc$demand) >= -1e-3))
})

test_that("rh_guarantee_curve rejects equal vary/target", {
  expect_error(
    rh_guarantee_curve(precip_pi$value, base = list(runoff = 0.85),
                       vary = "demand", values = 1:3, target = "demand"),
    "different"
  )
})
