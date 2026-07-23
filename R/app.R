#' Launch the rharv explorer (Shiny app)
#'
#' Opens an interactive Shiny app to explore a rainwater harvesting system: move
#' sliders for catchment area, reservoir capacity, demand, runoff, efficiency and
#' initial storage, pick the performance metric, and watch the reservoir
#' behaviour, the metrics, the area-capacity trade-off surface and the guarantee
#' values update live. A "fast mode" simulates on the day-of-year climatology so
#' the trade-off grid recomputes quickly.
#'
#' Requires the suggested packages \pkg{shiny}, \pkg{bslib} and \pkg{ggplot2}.
#'
#' @param ... Passed to [shiny::runApp()].
#' @return Invisibly `NULL`; called to launch the app.
#' @export
#' @examples
#' \dontrun{
#' rh_explore()
#' }
rh_explore <- function(...) {
  rlang::check_installed(c("shiny", "bslib", "ggplot2"),
                         reason = "to run the rharv explorer app.")
  app_dir <- system.file("shiny", "explore", package = "rharv")
  if (!nzchar(app_dir)) {
    rlang::abort("App directory not found; reinstall rharv.")
  }
  shiny::runApp(app_dir, ...)
}

#' @rdname rh_explore
#' @export
rh_app <- function(...) rh_explore(...)

#' Open the rharv demonstration notebook
#'
#' Opens the bundled R Markdown demo (`rharv-demo.Rmd`), which exercises every
#' function, plot and dataset of the package, in your editor (RStudio when run
#' from an RStudio session). Use Knit to render it to HTML.
#'
#' @return Invisibly, the path to the demo file.
#' @export
#' @examples
#' \dontrun{
#' rh_demo()
#' }
rh_demo <- function() {
  f <- system.file("examples", "rharv-demo.Rmd", package = "rharv")
  if (!nzchar(f)) rlang::abort("Demo not found; reinstall rharv.")
  utils::file.edit(f)
  invisible(f)
}
