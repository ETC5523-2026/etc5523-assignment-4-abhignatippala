# Bacteria samples from Sydney swim sites, with recent rainfall

Water samples collected by Beachwatch NSW at 77 swim sites across Sydney
between January 2015 and April 2025. Each sample is matched to the
rainfall recorded in the 72 hours (three calendar days) before the
sample date.

## Usage

``` r
beach_samples
```

## Format

A tibble with 36,062 rows and 9 columns:

- region:

  Beachwatch region: Northern Sydney, Southern Sydney, Sydney City,
  Sydney Harbour or Western Sydney.

- council:

  Local council responsible for the site.

- swim_site:

  Name of the beach, baths or swim site.

- date:

  Date the sample was taken.

- enterococci:

  Enterococci bacteria count, in colony-forming units (cfu) per 100 mL
  of water. Higher counts indicate more faecal contamination and a
  higher risk of illness from swimming.

- water_temp_c:

  Water temperature (degrees Celsius); may be `NA`.

- rain_72h_mm:

  Total rainfall (mm) on the three days before the sample date, from
  [sydney_rainfall](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/sydney_rainfall.md).

- latitude, longitude:

  Location of the swim site.

## Source

Beachwatch NSW, NSW Government,
<https://www.beachwatch.nsw.gov.au/waterMonitoring/waterQualityData>, as
curated for TidyTuesday (2025-05-20) by Jen Richmond,
<https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-05-20>.

## Details

Samples without an enterococci result and exact duplicate records were
removed. Rainfall comes from a single modelled location near Sydney
Observatory Hill, so it will not capture local storms at every beach.
The preparation script is `data-raw/beach_samples.R` in the package
source.
