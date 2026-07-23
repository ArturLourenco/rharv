test_that("autoplot and the climatology heatmap build without error", {
  skip_if_not_installed("ggplot2")
  sim <- rh_simulate(fx_precip(6), demand = 0.4, area = 775.53, capacity = 5)
  expect_no_error(ggplot2::ggplot_build(ggplot2::autoplot(sim)))
  df <- data.frame(date = as.Date("2020-01-01") + 0:364,
                   value = rep(c(0, 5, 10), length.out = 365))
  expect_no_error(ggplot2::ggplot_build(rh_plot_climatology(df)))
})

test_that("simulation plot is visually stable", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("vdiffr")
  sim <- rh_simulate(fx_precip(6), demand = 0.4, area = 775.53, capacity = 5)
  vdiffr::expect_doppelganger("autoplot-sim", ggplot2::autoplot(sim))
})
