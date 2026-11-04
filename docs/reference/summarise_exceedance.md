# Summarise how often water samples exceed a bacteria threshold after rain

Groups water samples by the rain that fell in the 72 hours before each
sample, then reports the share of samples in each rainfall band whose
enterococci count was above `threshold`. This is the calculation behind
the main chart in
[`run_app()`](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/run_app.md).

## Usage

``` r
summarise_exceedance(samples, threshold = 40, min_samples = 10)
```

## Arguments

- samples:

  A data frame of water samples with the columns `enterococci` and
  `rain_72h_mm`, such as
  [beach_samples](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/beach_samples.md)
  or a subset of it.

- threshold:

  Enterococci count (cfu per 100 mL) above which a sample counts as
  unsafe. Defaults to 40, the strictest NHMRC category limit.

- min_samples:

  Bands with fewer samples than this are flagged in the `few_samples`
  column, because their percentages are unreliable.

## Value

A data frame with one row per rainfall band (Dry, Light, Moderate,
Heavy) and the columns `rain_band`, `n_samples`, `n_exceed`,
`prop_exceed` (share of samples above `threshold`, `NA` for an empty
band) and `few_samples`.

## Examples

``` r
bondi <- beach_samples[beach_samples$swim_site == "Bondi Beach", ]
summarise_exceedance(bondi)
#> # A tibble: 4 × 5
#>   rain_band                 n_samples n_exceed prop_exceed few_samples
#>   <fct>                         <int>    <int>       <dbl> <lgl>      
#> 1 "Dry\n(under 1 mm)"             215        8      0.0372 FALSE      
#> 2 "Light\n(1 to 10 mm)"           238       26      0.109  FALSE      
#> 3 "Moderate\n(10 to 25 mm)"        89       15      0.169  FALSE      
#> 4 "Heavy\n(25 mm or more)"         52       15      0.288  FALSE      
# Compare prop_exceed in the Dry and Heavy rows: a large gap means
# rain strongly raises the chance of poor water quality at Bondi.

summarise_exceedance(bondi, threshold = 200)
#> # A tibble: 4 × 5
#>   rain_band                 n_samples n_exceed prop_exceed few_samples
#>   <fct>                         <int>    <int>       <dbl> <lgl>      
#> 1 "Dry\n(under 1 mm)"             215        2     0.00930 FALSE      
#> 2 "Light\n(1 to 10 mm)"           238        6     0.0252  FALSE      
#> 3 "Moderate\n(10 to 25 mm)"        89        3     0.0337  FALSE      
#> 4 "Heavy\n(25 mm or more)"         52        2     0.0385  FALSE      
# A more lenient threshold gives lower percentages in every band
```
