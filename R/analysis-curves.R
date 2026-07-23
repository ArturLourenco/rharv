#' Zero-deficit guarantee frontier
#'
#' Traces, over a range of one design variable, the guaranteed value of another:
#' for each `vary` value it calls the matching sizing function ([rh_guaranteed_demand()],
#' [rh_guaranteed_capacity()] or [rh_required_area()]) to find the `target` that
#' yields zero deficit. For example, vary the capacity and read the guaranteed
#' demand for each, giving the demand-versus-capacity frontier.
#'
#' @inheritParams rh_sweep
#' @param base Named list of the fixed [rh_simulate()] arguments needed by the
#'   chosen sizing function (everything except `vary` and `target`).
#' @param vary Variable to range over: `"capacity"`, `"area"` or `"demand"`.
#' @param values Numeric values of `vary`.
#' @param target Variable to solve for (zero deficit): `"demand"`, `"capacity"`
#'   or `"area"`. Must differ from `vary`.
#' @param method,tol Passed to the sizing function (`"bisection"`/`"optimize"`/`"step"`).
#'
#' @return A data frame with two columns named after `vary` and `target`; the
#'   names are also stored in `attr(, "vary")` and `attr(, "target")`. Points
#'   where no feasible `target` exists are `NA`.
#' @export
#' @examples
#' rh_guarantee_curve(
#'   precip_pi$value, base = list(area = 4170, runoff = 0.85, efficiency = 1),
#'   vary = "capacity", values = seq(100, 1000, by = 100), target = "demand",
#'   dates = precip_pi$date, climatology = TRUE
#' )
rh_guarantee_curve <- function(precip, base = list(), vary, values, target,
                               method = "bisection", tol = 1e-3,
                               dates = NULL, climatology = FALSE) {
  vary <- match.arg(vary, c("capacity", "area", "demand"))
  target <- match.arg(target, c("demand", "capacity", "area"))
  if (vary == target) rlang::abort("`vary` and `target` must be different.")
  if (isTRUE(climatology)) precip <- .climatology(precip, dates)

  fn <- switch(target,
    demand = rh_guaranteed_demand,
    capacity = rh_guaranteed_capacity,
    area = rh_required_area
  )
  allowed <- names(formals(fn))
  res <- vapply(values, function(v) {
    args <- base
    args[[vary]] <- v
    a <- args[names(args) %in% allowed]
    a$precip <- precip
    if ("method" %in% allowed) a$method <- method
    if ("tol" %in% allowed) a$tol <- tol
    # Infeasible points (e.g. a demand no capacity can serve) become NA rather
    # than aborting the whole frontier; rh_plot_* tolerate NA.
    tryCatch(as.numeric(do.call(fn, a)), error = function(e) NA_real_)
  }, numeric(1))

  out <- stats::setNames(data.frame(values, res), c(vary, target))
  attr(out, "vary") <- vary
  attr(out, "target") <- target
  out
}
