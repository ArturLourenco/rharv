test_that("rh_series_spread summarises by year", {
  sp <- rh_series_spread(precip_pi, by = "year")
  expect_true(all(c("group", "n", "total", "mean", "sd", "cv", "p10", "p90",
                    "wet_days") %in% names(sp)))
  expect_identical(attr(sp, "by"), "year")
  expect_gt(nrow(sp), 50)
  expect_true(all(sp$wet_days <= sp$n))
})

test_that("rh_series_spread supports month and doy", {
  expect_equal(nrow(rh_series_spread(precip_pi, by = "month")), 12)
  expect_lte(nrow(rh_series_spread(precip_pi, by = "doy")), 366)
})

test_that("rh_series_spread tolerates an all-NA group", {
  df <- data.frame(date = seq.Date(as.Date("2000-01-01"), as.Date("2001-12-31"),
                                   by = "day"))
  df$value <- ifelse(format(df$date, "%Y") == "2001", NA_real_, 1)
  sp <- rh_series_spread(df, by = "year")
  expect_equal(nrow(sp), 2)
  expect_true(is.na(sp$mean[sp$group == 2001]))
  expect_equal(sp$n[sp$group == 2001], 0L)
})
