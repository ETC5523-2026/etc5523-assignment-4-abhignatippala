#' @keywords internal
"_PACKAGE"

# bslib is used by the app in inst/app. Importing one function records
# the dependency so R CMD check knows the package is needed.
#' @importFrom bslib page_sidebar
NULL

# dplyr code refers to columns by bare name (e.g. rain_72h_mm). R CMD check
# cannot tell these are columns and gives a "no visible binding" NOTE.
# Declaring them here tells check they are intentional.
utils::globalVariables(c(
  "rain_72h_mm", "enterococci", "swim_site", "rain_band", "n_samples",
  "n_exceed", "prop_exceed", "few_samples", "group", "label",
  "dry", "wet", "unsafe", "n_dry", "n_wet", "pct_dry", "pct_wet",
  "rain_effect"
))
