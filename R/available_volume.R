#' Available rainwater volume (ABNT NBR 15527:2019)
#'
#' Computes the theoretical volume of rainwater available for capture, using the
#' equation given in ABNT NBR 15527:2019, item 4.1.6:
#'
#' \deqn{V_{disp} = P \times A \times C \times \eta}
#'
#' The result is converted from litres to cubic metres (division by 1000).
#'
#' @param precip Numeric vector of precipitation depths, in millimetres (mm).
#'   Each element is one time step (typically a day).
#' @param area Catchment area in square metres (m2). May be a vector of
#'   per-block areas, in which case the total `sum(area)` is used.
#' @param runoff Runoff coefficient `C` (the *coeficiente de escoamento
#'   superficial*), dimensionless in `[0, 1]`. Scalar or vector recycled to
#'   `length(precip)`. Default `0.8`.
#' @param efficiency System efficiency `eta` (dimensionless, `[0, 1]`),
#'   accounting for the first-flush diverter/solids-discard device. Scalar or
#'   vector recycled to `length(precip)`. ABNT NBR 15527:2019 recommends `0.85`
#'   when no data are available (the default).
#'
#' @return A numeric vector, the same length as `precip`, of available volumes
#'   in cubic metres (m3).
#' @export
#' @examples
#' # Daily available volume for a 775.53 m2 roof over three days
#' rh_available_volume(precip = c(0, 12, 30), area = 775.53)
rh_available_volume <- function(precip, area, runoff = 0.8, efficiency = 0.85) {
  .check_number(precip, "precip", lower = 0, allow_vector = TRUE)
  .check_number(area, "area", lower = 0, allow_vector = TRUE)
  n <- length(precip)
  runoff <- .recycle(runoff, n, "runoff")
  efficiency <- .recycle(efficiency, n, "efficiency")
  .check_number(runoff, "runoff", lower = 0, upper = 1, allow_vector = TRUE)
  .check_number(efficiency, "efficiency", lower = 0, upper = 1, allow_vector = TRUE)
  precip * sum(area) * runoff * efficiency / 1000
}
