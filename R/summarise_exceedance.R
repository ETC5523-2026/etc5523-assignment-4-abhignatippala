#' Summarise how often water samples exceed a bacteria threshold after rain
#'
#' Groups water samples by the rain that fell in the 72 hours before each
#' sample, then reports the share of samples in each rainfall band whose
#' enterococci count was above `threshold`. This is the calculation behind
#' the main chart in [run_app()].
#'
#' @param samples A data frame of water samples with the columns
#'   `enterococci` and `rain_72h_mm`, such as [beach_samples] or a subset
#'   of it.
#' @param threshold Enterococci count (cfu per 100 mL) above which a sample
#'   counts as unsafe. Defaults to 40, the strictest NHMRC category limit.
#' @param min_samples Bands with fewer samples than this are flagged in the
#'   `few_samples` column, because their percentages are unreliable.
#' @return A data frame with one row per rainfall band (Dry, Light,
#'   Moderate, Heavy) and the columns `rain_band`, `n_samples`, `n_exceed`,
#'   `prop_exceed` (share of samples above `threshold`, `NA` for an empty
#'   band) and `few_samples`.
#' @examples
#' bondi <- beach_samples[beach_samples$swim_site == "Bondi Beach", ]
#' summarise_exceedance(bondi)
#' # Compare prop_exceed in the Dry and Heavy rows: a large gap means
#' # rain strongly raises the chance of poor water quality at Bondi.
#'
#' summarise_exceedance(bondi, threshold = 200)
#' # A more lenient threshold gives lower percentages in every band
#' @importFrom dplyr mutate group_by summarise n
#' @export
summarise_exceedance <- function(samples, threshold = 40, min_samples = 10) {
  samples |>
    mutate(
      # right = FALSE: each band includes its lower limit, e.g. exactly
      # 10 mm counts as Moderate, not Light
      rain_band = cut(
        rain_72h_mm,
        breaks = c(0, 1, 10, 25, Inf),
        labels = c("Dry\n(under 1 mm)", "Light\n(1 to 10 mm)",
                   "Moderate\n(10 to 25 mm)", "Heavy\n(25 mm or more)"),
        right = FALSE
      )
    ) |>
    # .drop = FALSE keeps empty bands, so the chart shows a gap rather
    # than silently dropping a band
    group_by(rain_band, .drop = FALSE) |>
    summarise(
      n_samples = n(),
      n_exceed = sum(enterococci > threshold),
      .groups = "drop"
    ) |>
    mutate(
      prop_exceed = ifelse(n_samples > 0, n_exceed / n_samples, NA),
      few_samples = n_samples < min_samples
    )
}
