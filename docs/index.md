# beachrain

**Does rain affect my beach?** `beachrain` helps Sydney swimmers see
whether bacteria levels at their beach tend to rise after rain and how
their beach compares with other nearby beaches.

**Documentation website:**
<https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/>

## What’s in the package

| Component | What it does |
|----|----|
| `beach_samples` | 36,062 enterococci samples from 77 Sydney swim sites (2015 to 2025), each matched to the rain that fell in the previous 72 hours |
| `sydney_rainfall` | Daily Sydney rainfall and temperature used to build the 72-hour totals |
| [`summarise_exceedance()`](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/summarise_exceedance.md) | Share of samples above a bacteria threshold in each rainfall band |
| [`compare_sites()`](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/compare_sites.md) | Ranks swim sites by how much rain changes their water quality |
| [`plot_exceedance()`](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/plot_exceedance.md) | Bar chart of a beach’s summary beside its region |
| [`run_app()`](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/run_app.md) | Launches the *Rain Check* Shiny app |

## Installation

``` r
# install.packages("remotes")
remotes::install_github("ETC5523-2026/YOUR-REPO-NAME")
```

## Launch the app

``` r
library(beachrain)
run_app()
```

The app is designed for Sydney swimmers who want to know how rain might
affect their usual beach. Choose your beach and the bacteria level you
want to check. The chart then shows how your beach (blue) compares with
other beaches in the same region (beige) across four different levels of
rainfall.

## A quick example

``` r
library(beachrain)

bondi <- beach_samples[beach_samples$swim_site == "Bondi Beach", ]
summarise_exceedance(bondi, threshold = 40)
#> # A tibble: 4 × 5
#>   rain_band                 n_samples n_exceed prop_exceed few_samples
#>   <fct>                         <int>    <int>       <dbl> <lgl>      
#> 1 "Dry\n(under 1 mm)"             215        8      0.0372 FALSE      
#> 2 "Light\n(1 to 10 mm)"           238       26      0.109  FALSE      
#> 3 "Moderate\n(10 to 25 mm)"        89       15      0.169  FALSE      
#> 4 "Heavy\n(25 mm or more)"         52       15      0.288  FALSE
```

Compare `prop_exceed` in the Dry row with the Heavy row: the gap shows
how much heavy rain raises the chance of poor water quality at Bondi.

## Data

- **Water quality:** Beachwatch NSW, NSW Government,
  <https://www.beachwatch.nsw.gov.au/waterMonitoring/waterQualityData>
- **Weather:** Open-Meteo historical weather API, licensed under CC BY
  4.0, <https://open-meteo.com/>

Both datasets were curated for [TidyTuesday (20 May
2025)](https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-05-20)
by Jen Richmond (R-Ladies Sydney). The script `data-raw/beach_samples.R`
downloads the raw files and reproduces the package data.

## Generative AI declaration

**Generative AI declaration:** I used Claude (Anthropic) for some parts
of the package development, mainly to get help with the Shiny app, CSS
styling, package configuration and a few technical aspects of the
documentation. I used its suggestions as a starting point and made my
own changes to the code, app layout, title, wording and colour theme. I
also rewrote the vignette and README, tested the package and reviewed
the final work to make sure I understood how everything worked.
