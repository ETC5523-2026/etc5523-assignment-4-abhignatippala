# Compare swim sites by how much rain changes their water quality

For each swim site, calculates the percentage of samples above
`threshold` after dry weather (under 1 mm of rain in the previous 72
hours) and after wet weather (10 mm or more), and the difference between
them. Sites most affected by rain come first. This powers the "Compare
beaches" tab of
[`run_app()`](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/run_app.md).

## Usage

``` r
compare_sites(samples, threshold = 40, min_samples = 10)
```

## Arguments

- samples:

  A data frame of water samples with the columns `swim_site`,
  `enterococci` and `rain_72h_mm`, such as
  [beach_samples](https://etc5523-2026.github.io/etc5523-assignment-4-abhignatippala/reference/beach_samples.md).

- threshold:

  Enterococci count (cfu per 100 mL) above which a sample counts as
  unsafe. Defaults to 40, the strictest NHMRC category limit.

- min_samples:

  Bands with fewer samples than this are flagged in the `few_samples`
  column, because their percentages are unreliable.

## Value

A data frame with one row per swim site and the columns `swim_site`,
`n_dry`, `n_wet`, `pct_dry`, `pct_wet` (percentages from 0 to 100),
`rain_effect` (`pct_wet - pct_dry`, in percentage points) and
`few_samples`.

## Examples

``` r
harbour <- beach_samples[beach_samples$region == "Sydney Harbour", ]
head(compare_sites(harbour))
#> # A tibble: 6 × 7
#>   swim_site             n_dry n_wet pct_dry pct_wet rain_effect few_samples
#>   <chr>                 <int> <int>   <dbl>   <dbl>       <dbl> <lgl>      
#> 1 Tambourine Bay          124    91    3.23    64.8        61.6 FALSE      
#> 2 Davidson Reserve        125    90    4       64.4        60.4 FALSE      
#> 3 Gurney Crescent Baths   124    91    2.42    50.5        48.1 FALSE      
#> 4 Woodford Bay            124    91    2.42    50.5        48.1 FALSE      
#> 5 Woolwich Baths          125    91    3.2     49.5        46.3 FALSE      
#> 6 Northbridge Baths       125    91    4.8     50.5        45.7 FALSE      
# Sites at the top have the largest jump in unsafe samples after rain
```
