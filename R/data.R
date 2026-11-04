#' Bacteria samples from Sydney swim sites, with recent rainfall
#'
#' Water samples collected by Beachwatch NSW at 77 swim sites across Sydney
#' between January 2015 and April 2025. Each sample is matched to the
#' rainfall recorded in the 72 hours (three calendar days) before the
#' sample date.
#'
#' @format A tibble with 36,062 rows and 9 columns:
#' \describe{
#'   \item{region}{Beachwatch region: Northern Sydney, Southern Sydney,
#'     Sydney City, Sydney Harbour or Western Sydney.}
#'   \item{council}{Local council responsible for the site.}
#'   \item{swim_site}{Name of the beach, baths or swim site.}
#'   \item{date}{Date the sample was taken.}
#'   \item{enterococci}{Enterococci bacteria count, in colony-forming units
#'     (cfu) per 100 mL of water. Higher counts indicate more faecal
#'     contamination and a higher risk of illness from swimming.}
#'   \item{water_temp_c}{Water temperature (degrees Celsius); may be `NA`.}
#'   \item{rain_72h_mm}{Total rainfall (mm) on the three days before the
#'     sample date, from [sydney_rainfall].}
#'   \item{latitude, longitude}{Location of the swim site.}
#' }
#'
#' @details Samples without an enterococci result and exact duplicate
#'   records were removed. Rainfall comes from a single modelled location
#'   near Sydney Observatory Hill, so it will not capture local storms at
#'   every beach. The preparation script is `data-raw/beach_samples.R` in
#'   the package source.
#'
#' @source Beachwatch NSW, NSW Government,
#'   <https://www.beachwatch.nsw.gov.au/waterMonitoring/waterQualityData>,
#'   as curated for TidyTuesday (2025-05-20) by Jen Richmond,
#'   <https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-05-20>.
"beach_samples"

#' Daily rainfall and temperature in Sydney
#'
#' Daily weather for one location near Sydney Observatory Hill, used to
#' calculate the 72-hour rainfall in [beach_samples].
#'
#' @format A tibble with 3,772 rows and 4 columns:
#' \describe{
#'   \item{date}{Calendar date.}
#'   \item{rainfall_mm}{Total rainfall on that date (mm).}
#'   \item{max_temp_c}{Maximum air temperature (degrees Celsius).}
#'   \item{rain_72h_mm}{Total rainfall on the three days before `date`
#'     (mm), excluding `date` itself.}
#' }
#'
#' @details These are modelled historical weather values, not rain-gauge
#'   readings at each beach.
#'
#' @source Open-Meteo historical weather API (CC BY 4.0),
#'   <https://open-meteo.com/>, as curated for TidyTuesday (2025-05-20).
"sydney_rainfall"
