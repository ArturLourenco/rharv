# Synthetic precipitation fixtures used across tests.
# A repeating weekly pattern with two rainy days (30 mm and 50 mm).
fx_precip <- function(weeks = 6) {
  rep(c(0, 0, 30, 0, 0, 0, 50), weeks)
}
