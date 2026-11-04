## Prepare the `beach_samples` and `sydney_rainfall` datasets
##
## Source: TidyTuesday 2025-05-20 "Water Quality at Sydney Beaches",
## curated by Jen Richmond (R-Ladies Sydney) from
##   * Beachwatch NSW water quality data
##     <https://www.beachwatch.nsw.gov.au/waterMonitoring/waterQualityData>
##   * Open-Meteo historical weather <https://open-meteo.com/> (CC BY 4.0)
##
## Run this whole script from the package root to rebuild data/*.rda.

library(dplyr)
library(readr)

base_url <- paste0(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
  "main/data/2025/2025-05-20/"
)

# 1. Import ---------------------------------------------------------------
water_quality_raw <- read_csv(
  paste0(base_url, "water_quality.csv"),
  col_types = cols(
    region = col_character(),
    council = col_character(),
    swim_site = col_character(),
    date = col_date(),
    time = col_character(),
    enterococci_cfu_100ml = col_double(),
    water_temperature_c = col_double(),
    conductivity_ms_cm = col_double(),
    latitude = col_double(),
    longitude = col_double()
  )
)

weather_raw <- read_csv(
  paste0(base_url, "weather.csv"),
  col_types = cols(
    date = col_date(),
    max_temp_C = col_double(),
    min_temp_C = col_double(),
    precipitation_mm = col_double(),
    latitude = col_double(),
    longitude = col_double()
  )
)

# 2. Daily rainfall and the 72-hour total ----------------------------------
# The weather file is one location (near Sydney Observatory Hill) with one
# row per day. Check that no days are missing before using lag(): a gap
# would silently shift the rolling total.
stopifnot(
  !anyNA(weather_raw$precipitation_mm),
  all(diff(sort(weather_raw$date)) == 1)
)

sydney_rainfall <- weather_raw |>
  arrange(date) |>
  transmute(
    date,
    rainfall_mm = precipitation_mm,
    max_temp_c = max_temp_C,
    # Rain on the three days BEFORE a sample. The sample day itself is
    # excluded because samples are usually taken in the morning, so most of
    # that day's rain falls after the water was collected.
    rain_72h_mm = lag(rainfall_mm, 1) + lag(rainfall_mm, 2) +
      lag(rainfall_mm, 3)
  ) |>
  filter(date >= as.Date("2015-01-01"))

# 3. Water samples ---------------------------------------------------------
beach_samples <- water_quality_raw |>
  # Ten-plus years keeps the package small while covering many wet and
  # dry periods.
  filter(date >= as.Date("2015-01-01")) |>
  # A sample without a bacteria count cannot answer the app's question.
  filter(!is.na(enterococci_cfu_100ml)) |>
  # Remove exact duplicate records (same site, date, time and result).
  distinct(swim_site, date, time, enterococci_cfu_100ml, .keep_all = TRUE) |>
  left_join(select(sydney_rainfall, date, rain_72h_mm), by = "date") |>
  filter(!is.na(rain_72h_mm)) |>
  transmute(
    region,
    council,
    swim_site,
    date,
    enterococci = enterococci_cfu_100ml,
    water_temp_c = water_temperature_c,
    rain_72h_mm = round(rain_72h_mm, 1),
    latitude,
    longitude
  ) |>
  arrange(region, swim_site, date)

# 4. Save -----------------------------------------------------------------
usethis::use_data(beach_samples, sydney_rainfall, overwrite = TRUE)
