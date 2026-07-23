test_that("available volume matches the NBR 15527:2019 formula", {
  # 10 mm over 100 m2 with C = 0.8 and eta = 0.85 -> 10*100*0.8*0.85/1000 = 0.68 m3
  expect_equal(rh_available_volume(10, 100, 0.8, 0.85), 0.68)
  # a vector of per-block areas is summed
  expect_equal(rh_available_volume(10, c(60, 40)), rh_available_volume(10, 100))
  expect_equal(rh_available_volume(0, 100), 0)
  # vectorised over precip
  expect_equal(rh_available_volume(c(0, 10), 100), c(0, 0.68))
})

test_that("available volume validates its inputs", {
  expect_error(rh_available_volume(-1, 100), "precip")
  expect_error(rh_available_volume(10, -100), "area")
  expect_error(rh_available_volume(10, 100, runoff = 1.5), "runoff")
  expect_error(rh_available_volume(10, 100, efficiency = -0.1), "efficiency")
  expect_error(rh_available_volume(c(10, 20), 100, runoff = c(0.8, 0.9, 1)), "runoff")
})
