test_that("analysis and diagnostic plots build without error", {
  skip_if_not_installed("ggplot2")
  p <- precip_pi$value
  d <- precip_pi$date

  g <- rh_grid(p, base = list(demand = 6.6, runoff = 0.85, efficiency = 1),
               x = "area", x_values = seq(1000, 5000, length.out = 5),
               y = "capacity", y_values = seq(100, 900, length.out = 5),
               metrics = "attendance_pct", dates = d, climatology = TRUE)
  expect_no_error(ggplot2::ggplot_build(rh_plot_tradeoff(g)))
  expect_no_error(ggplot2::ggplot_build(rh_plot_levers(
    p, base = list(demand = 6.6, area = 4170, capacity = 400,
                   runoff = 0.85, efficiency = 1),
    dates = d, climatology = TRUE)))

  gs <- rh_grid(p, base = list(area = 4170, runoff = 0.85, efficiency = 1),
                x = "capacity", x_values = seq(100, 900, length.out = 5),
                y = "demand", y_values = c(4, 6), metrics = "reliability_pct",
                dates = d, climatology = TRUE)
  expect_no_error(ggplot2::ggplot_build(rh_plot_syr(gs)))

  n_years <- length(unique(format(d, "%Y")))
  inflow <- sum(rh_available_volume(p, 4170, 0.85, 1)) / n_years
  gd <- rh_grid(p, base = list(area = 4170, runoff = 0.85, efficiency = 1),
                x = "demand", x_values = seq(2, 10, length.out = 5),
                y = "capacity", y_values = seq(100, 1200, length.out = 5),
                metrics = "reliability_pct", dates = d, climatology = TRUE)
  expect_no_error(
    ggplot2::ggplot_build(rh_plot_design_curve(gd, annual_inflow = inflow))
  )

  sim <- rh_simulate(p, 6.6, 4170, 400, runoff = 0.85, efficiency = 1)
  expect_no_error(ggplot2::ggplot_build(rh_plot_behaviour(sim, dates = d)))
  expect_no_error(ggplot2::ggplot_build(rh_plot_monthly_balance(sim, dates = d)))
  expect_no_error(ggplot2::ggplot_build(rh_plot_failure_calendar(sim, dates = d)))
  expect_no_error(
    ggplot2::ggplot_build(rh_plot_spread(rh_series_spread(precip_pi, by = "year")))
  )
})

test_that("plot helpers validate their inputs", {
  skip_if_not_installed("ggplot2")
  sim <- rh_simulate(precip_pi$value, 6.6, 4170, 400, runoff = 0.85, efficiency = 1)
  expect_error(rh_plot_monthly_balance(sim, dates = precip_pi$date[1:10]), "match")
  expect_error(rh_plot_tradeoff(data.frame(a = 1)), "rh_grid")
})

test_that("rh_plot_monthly_balance handles partial-year simulations", {
  skip_if_not_installed("ggplot2")
  sim <- rh_simulate(precip_pi$value[1:100], 6.6, 4170, 400,
                     runoff = 0.85, efficiency = 1)
  p <- rh_plot_monthly_balance(sim, dates = precip_pi$date[1:100])
  expect_no_error(ggplot2::ggplot_build(p))
})
