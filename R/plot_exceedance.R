#' Plot the share of unsafe samples in each rainfall band
#'
#' Draws the output of [summarise_exceedance()] as a bar chart. A second
#' summary, such as every beach in the same region, can be drawn in a muted
#' beige-grey as context so the user can see whether their beach is better or
#' worse than its surroundings. Bands with too few samples are drawn faded.
#'
#' @param selection Output of [summarise_exceedance()] for the beach of
#'   interest, drawn in blue.
#' @param context Output of [summarise_exceedance()] for a comparison group,
#'   drawn in a muted beige-grey.
#' @param selection_label,context_label Legend labels for the two groups.
#' @param threshold The threshold used in the summaries, shown on the
#'   y-axis label.
#' @return A ggplot object.
#' @examples
#' bondi <- beach_samples[beach_samples$swim_site == "Bondi Beach", ]
#' city <- beach_samples[beach_samples$region == "Sydney City", ]
#' plot_exceedance(
#'   summarise_exceedance(bondi),
#'   summarise_exceedance(city),
#'   selection_label = "Bondi Beach",
#'   context_label = "All Sydney City sites"
#' )
#' @importFrom dplyr bind_rows mutate
#' @importFrom ggplot2 ggplot aes geom_col geom_text position_dodge
#'   scale_fill_manual scale_alpha_manual scale_y_continuous labs
#'   theme_minimal theme element_blank element_rect element_text margin
#'   expansion
#' @export
plot_exceedance <- function(selection, context,
                            selection_label = "Your beach",
                            context_label = "All beaches in region",
                            threshold = 40) {
  plot_data <- bind_rows(
    mutate(context, group = context_label),
    mutate(selection, group = selection_label)
  ) |>
    mutate(
      # Context first in the factor so the context bar sits on the left
      group = factor(group, levels = c(context_label, selection_label)),
      label = ifelse(n_samples == 0, "none",
                     paste0(round(100 * prop_exceed), "%")),
      prop_exceed = ifelse(is.na(prop_exceed), 0, prop_exceed)
    )
  
  # Named vector: colours stay attached to their meaning (Week 7, recipe 1)
  group_colours <- c("#C9BFAF", "#2C4B8E")
  names(group_colours) <- c(context_label, selection_label)
  
  ggplot(plot_data, aes(x = rain_band, y = prop_exceed, fill = group)) +
    # Narrower bars than the dodge width leave a small gap inside each pair
    geom_col(aes(alpha = few_samples),
             position = position_dodge(width = 0.8), width = 0.7) +
    geom_text(aes(label = label), position = position_dodge(width = 0.8),
              vjust = -0.5, size = 3.6, colour = "#1A1A1A") +
    scale_fill_manual(values = group_colours, name = NULL) +
    scale_alpha_manual(values = c("FALSE" = 1, "TRUE" = 0.35),
                       guide = "none") +
    # Extra space above the tallest bar so its percentage label isn't cut off
    scale_y_continuous(labels = function(x) paste0(round(100 * x), "%"),
                       expand = expansion(mult = c(0, 0.18))) +
    labs(
      x = "How much it rained in the 3 days before the sample was taken",
      y = paste0("Samples above ", threshold, " cfu/100 mL")
    ) +
    theme_minimal(base_size = 13) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      # Legend at the top left, where reading starts, with space below it
      legend.position = "top",
      legend.justification = "left",
      legend.margin = margin(b = 8),
      # Breathing room between axis labels and axis titles
      axis.text.x = element_text(margin = margin(t = 6), lineheight = 1.1,
                                 colour = "#1A1A1A"),
      axis.title.x = element_text(margin = margin(t = 14), size = 12,
                                  colour = "#6B5D52"),
      axis.title.y = element_text(margin = margin(r = 12), size = 12,
                                  colour = "#6B5D52"),
      plot.margin = margin(t = 10, r = 20, b = 10, l = 10),
      # Light paper background to match the app and website
      plot.background = element_rect(fill = "#F7F0E4", colour = NA)
    )
}