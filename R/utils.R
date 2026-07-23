# Null-coalescing operator (base R gained `%||%` only in 4.4.0; define our own).
`%||%` <- function(x, y) if (is.null(x)) y else x

# Recycle a scalar to length `n`, or pass through a length-`n` vector.
.recycle <- function(x, n, arg) {
  if (length(x) == 1L) {
    return(rep(x, n))
  }
  if (length(x) == n) {
    return(x)
  }
  rlang::abort(
    sprintf("`%s` must have length 1 or %d, not %d.", arg, n, length(x))
  )
}

# Validate a numeric scalar/vector: finite and within [lower, upper].
.check_number <- function(x, arg, lower = -Inf, upper = Inf, allow_vector = FALSE) {
  if (!is.numeric(x)) {
    rlang::abort(sprintf("`%s` must be numeric.", arg))
  }
  if (!allow_vector && length(x) != 1L) {
    rlang::abort(sprintf("`%s` must be a single number.", arg))
  }
  if (length(x) == 0L || anyNA(x) || any(!is.finite(x))) {
    rlang::abort(sprintf("`%s` must be finite (no NA/NaN/Inf).", arg))
  }
  if (any(x < lower) || any(x > upper)) {
    rlang::abort(sprintf("`%s` must be within [%g, %g].", arg, lower, upper))
  }
  invisible(x)
}
