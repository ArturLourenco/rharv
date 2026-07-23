# rharv explorer (interactive Shiny app). Launch with rharv::rh_explore().
library(shiny)
library(bslib)
library(ggplot2)
library(rharv)

ui <- page_sidebar(
  title = "rharv explorer",
  sidebar = sidebar(
    width = 330,
    sliderInput("area", "Catchment area (m2)", min = 100, max = 8000,
                value = 4170, step = 50),
    sliderInput("capacity", "Reservoir capacity (m3)", min = 10, max = 2000,
                value = 400, step = 10),
    sliderInput("demand", "Demand (m3/day)", min = 0, max = 15,
                value = 6.6, step = 0.1),
    sliderInput("runoff", "Runoff coefficient C", min = 0, max = 1,
                value = 0.85, step = 0.01),
    sliderInput("efficiency", "Efficiency eta", min = 0, max = 1,
                value = 1, step = 0.01),
    sliderInput("initial", "Initial storage (m3)", min = 0, max = 2000,
                value = 400, step = 10),
    selectInput("timing", "Overflow timing",
                c("after_demand", "before_demand")),
    radioButtons("metric", "Metric",
                 c("Volumetric (attendance %)" = "attendance_pct",
                   "Temporal (reliability %)" = "reliability_pct")),
    checkboxInput("fast", "Fast mode (day-of-year climatology)", TRUE)
  ),
  layout_columns(
    col_widths = c(7, 5),
    card(card_header("Reservoir behaviour (first 5 years)"),
         plotOutput("behaviour", height = "300px")),
    card(card_header("Guarantee values"), verbatimTextOutput("guarantee")),
    card(card_header("Trade-off: area x capacity (reservoir starts full in each cell)"),
         plotOutput("tradeoff", height = "340px")),
    card(card_header("Metrics"), tableOutput("metrics"))
  )
)

server <- function(input, output, session) {
  precip <- reactive(precip_pi$value)
  dates  <- reactive(precip_pi$date)
  # Day-of-year climatology, computed once, for the fast mode.
  clim <- as.numeric(tapply(precip_pi$value,
                            format(precip_pi$date, "%m-%d"), mean))
  init <- reactive(min(input$initial, input$capacity))

  # Keep the initial-storage slider consistent with the capacity slider, so the
  # value displayed always matches what is simulated.
  observeEvent(input$capacity, {
    updateSliderInput(session, "initial", max = input$capacity,
                      value = min(input$initial, input$capacity))
  })

  sim <- reactive({
    rh_simulate(precip(), demand = input$demand, area = input$area,
                capacity = input$capacity, runoff = input$runoff,
                efficiency = input$efficiency, initial = init(),
                overflow_timing = input$timing)
  })

  output$behaviour <- renderPlot({
    n <- min(length(precip()), 5L * 365L)
    s <- rh_simulate(precip()[seq_len(n)], demand = input$demand, area = input$area,
                     capacity = input$capacity, runoff = input$runoff,
                     efficiency = input$efficiency, initial = init(),
                     overflow_timing = input$timing)
    rh_plot_behaviour(s, dates = dates()[seq_len(n)])
  })

  output$metrics <- renderTable({
    m <- rh_metrics(sim())
    data.frame(metric = names(m), value = as.numeric(m[1, ]))
  }, digits = 2)

  # The expensive outputs only recompute after the sliders settle (debounce).
  grid_inputs <- debounce(reactive(list(
    area = input$area, capacity = input$capacity, demand = input$demand,
    runoff = input$runoff, efficiency = input$efficiency,
    timing = input$timing, metric = input$metric, fast = input$fast
  )), 600)

  output$tradeoff <- renderPlot({
    v <- grid_inputs()
    g <- rh_grid(
      precip(),
      base = list(demand = v$demand, runoff = v$runoff,
                  efficiency = v$efficiency, overflow_timing = v$timing),
      x = "area", x_values = seq(max(100, v$area * 0.25), v$area * 2,
                                 length.out = 18),
      y = "capacity", y_values = seq(max(10, v$capacity * 0.25),
                                     v$capacity * 2, length.out = 18),
      metrics = v$metric, dates = dates(), climatology = v$fast
    )
    rh_plot_tradeoff(g, metric = v$metric, breaks = c(50, 70, 90, 100)) +
      annotate("point", x = v$area, y = v$capacity, colour = "red", size = 3)
  })

  guar_inputs <- debounce(reactive(list(
    area = input$area, capacity = input$capacity, demand = input$demand,
    runoff = input$runoff, efficiency = input$efficiency,
    timing = input$timing, fast = input$fast, init = init()
  )), 800)

  output$guarantee <- renderText({
    v <- guar_inputs()
    serie <- if (isTRUE(v$fast)) clim else precip()
    dg <- rh_guaranteed_demand(serie, area = v$area, capacity = v$capacity,
                               runoff = v$runoff, efficiency = v$efficiency,
                               initial = v$init,
                               overflow_timing = v$timing)
    cg <- tryCatch(
      rh_guaranteed_capacity(serie, demand = v$demand, area = v$area,
                             runoff = v$runoff, efficiency = v$efficiency,
                             overflow_timing = v$timing, tol = 1,
                             max_capacity = max(v$demand * length(serie), 1)),
      error = function(e) NA_real_
    )
    paste0(
      "Guaranteed demand (zero deficit): ", round(dg, 3), " m3/day\n",
      "Guaranteed capacity (current demand): ",
      if (is.na(cg)) "not reachable" else paste0(round(cg, 1), " m3"),
      if (isTRUE(v$fast)) "\n[fast mode: day-of-year climatology]" else ""
    )
  })
}

shinyApp(ui, server)
