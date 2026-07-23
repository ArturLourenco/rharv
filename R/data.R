#' Daily precipitation at Princesa Isabel (1912-2019)
#'
#' Daily precipitation depths for the ANA/AESA rain gauge 738013 at Princesa
#' Isabel, Paraiba, Brazil. This is the cleaned series used in the IFPB-PI case
#' study: remaining gaps were filled as dry days and the fully-missing years
#' 1911, 1992 and 1993 were removed.
#'
#' @format A data frame with two columns:
#' \describe{
#'   \item{date}{Date of observation (class `Date`).}
#'   \item{value}{Daily precipitation depth, in millimetres (mm).}
#' }
#' @source Agencia Nacional de Aguas (ANA) and Agencia Executiva de Gestao das
#'   Aguas da Paraiba (AESA-PB), rain gauge 738013.
"precip_pi"

#' Catchment (roof) areas of the IFPB-PI campus
#'
#' Projected roof areas of the four buildings of the IFPB, Campus Princesa
#' Isabel, that can serve as rainwater catchment surfaces.
#'
#' @format A data frame with one row per building:
#' \describe{
#'   \item{block}{Building name.}
#'   \item{area_m2}{Projected roof area, in square metres (m2).}
#' }
#' @source Vectorised aerial imagery of the IFPB, Campus Princesa Isabel.
"areas_pi"
