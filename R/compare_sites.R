#' Compare swim sites by how much rain changes their water quality
#'
#' For each swim site, calculates the percentage of samples above
#' `threshold` after dry weather (under 1 mm of rain in the previous 72
#' hours) and after wet weather (10 mm or more), and the difference between
#' them. Sites most affected by rain come first. This powers the "Compare
#' beaches" tab of [run_app()].
#'
#' @param samples A data frame of water samples with the columns
#'   `swim_site`, `enterococci` and `rain_72h_mm`, such as [beach_samples].
#' @inheritParams summarise_exceedance
#' @return A data frame with one row per swim site and the columns
#'   `swim_site`, `n_dry`, `n_wet`, `pct_dry`, `pct_wet` (percentages from 0
#'   to 100), `rain_effect` (`pct_wet - pct_dry`, in percentage points) and
#'   `few_samples`.
#' @examples
#' harbour <- beach_samples[beach_samples$region == "Sydney Harbour", ]
#' head(compare_sites(harbour))
#' # Sites at the top have the largest jump in unsafe samples after rain
#' @importFrom dplyr group_by summarise mutate arrange desc
#' @export
compare_sites <- function(samples, threshold = 40, min_samples = 10) {
  samples |>
    mutate(
      dry = rain_72h_mm < 1,
      wet = rain_72h_mm >= 10,
      unsafe = enterococci > threshold
    ) |>
    group_by(swim_site) |>
    summarise(
      n_dry = sum(dry),
      n_wet = sum(wet),
      # Samples between 1 and 10 mm are left out of both groups so that
      # "dry" and "wet" are clearly different conditions
      pct_dry = 100 * sum(unsafe & dry) / n_dry,
      pct_wet = 100 * sum(unsafe & wet) / n_wet,
      .groups = "drop"
    ) |>
    mutate(
      rain_effect = pct_wet - pct_dry,
      few_samples = n_dry < min_samples | n_wet < min_samples
    ) |>
    arrange(desc(rain_effect))
}
