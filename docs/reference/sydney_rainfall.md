# Daily rainfall and temperature in Sydney

Daily weather for one location near Sydney Observatory Hill, used to
calculate the 72-hour rainfall in
[beach_samples](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/beach_samples.md).

## Usage

``` r
sydney_rainfall
```

## Format

A tibble with 3,772 rows and 4 columns:

- date:

  Calendar date.

- rainfall_mm:

  Total rainfall on that date (mm).

- max_temp_c:

  Maximum air temperature (degrees Celsius).

- rain_72h_mm:

  Total rainfall on the three days before `date` (mm), excluding `date`
  itself.

## Source

Open-Meteo historical weather API (CC BY 4.0),
<https://open-meteo.com/>, as curated for TidyTuesday (2025-05-20).

## Details

These are modelled historical weather values, not rain-gauge readings at
each beach.
