# Rain Check
#
# Intended user: a regular Sydney swimmer deciding whether to swim at their
# usual beach in the days after rain.
# Question: How much more often is the water at my beach above safe
# bacteria levels after rain, and how does it compare with nearby beaches?

library(shiny)
library(bslib)
library(dplyr)
library(beachrain)

samples <- beach_samples
sites <- distinct(samples, region, swim_site) |> arrange(region, swim_site)
site_choices <- split(sites$swim_site, sites$region)

# UI -----------------------------------------------------------------------
ui <- page_sidebar(
  title = "Rain Check: water quality at Sydney beaches after rain",
  window_title = "Rain Check",
  fillable = FALSE,
  theme = bs_theme(primary = "#2C4B8E", bg = "#EDE0CC", fg = "#1A1A1A"),
  tags$head(tags$link(rel = "stylesheet", href = "styles.css")),
  
  sidebar = sidebar(
    width = 320,
    div(
      class = "purpose",
      p(strong("For: "), "Sydney swimmers deciding whether to swim at their ",
        "beach in the days after rain."),
      p(strong("Question: "), "How much more often is the water unsafe ",
        "after rain, and is my beach better or worse than others nearby?")
    ),
    selectInput("site", "Choose your beach",
                choices = site_choices, selected = "Bondi Beach"),
    selectInput("threshold", "Count a sample as unsafe above",
                choices = c("40 cfu/100 mL (strictest)" = 40,
                            "200 cfu/100 mL (moderate)" = 200,
                            "500 cfu/100 mL (most lenient)" = 500)),
    sliderInput("years", "Years to include", min = 2015, max = 2025,
                value = c(2015, 2025), step = 1, sep = ""),
    checkboxInput("season_only", "Swimming season only (October to April)",
                  value = TRUE),
    p(class = "help",
      "Blue bars show your beach. Beige bars show every beach in the same ",
      "region, so you can tell whether yours is unusual.")
  ),
  
  navset_card_tab(
    nav_panel(
      "Does rain matter at my beach?",
      layout_columns(
        fill = FALSE,
        value_box(title = "Unsafe after dry weather",
                  value = textOutput("dry_pct"),
                  p("Samples above the threshold after under 1 mm of rain ",
                    "in the previous 3 days.")),
        value_box(title = "Unsafe after heavy rain",
                  value = textOutput("wet_pct"),
                  p("Samples above the threshold after 25 mm or more of ",
                    "rain in the previous 3 days.")),
        value_box(title = "Samples at this beach",
                  value = textOutput("n_samples"),
                  p("Water samples in the chosen years and season. More ",
                    "samples give more reliable percentages."))
      ),
      uiOutput("few_samples_warning"),
      card(
        card_header(textOutput("plot_title")),
        p(class = "help",
          "Each rainfall band has two bars. Taller bars mean more samples were ",
          "above the unsafe level. If the blue bars climb from left to right, ",
          "rain makes your beach riskier. Faded bars are based on fewer than ",
          "10 samples, so treat them with caution."),
        plotOutput("exceed_plot", height = "380px"),
        card_footer("Source: Beachwatch NSW (2015 to 2025) and Open-Meteo ",
                    "rainfall, via the beachrain R package.")
      ),
      div(class = "interpretation", textOutput("interpretation"))
    ),
    
    nav_panel(
      "Compare beaches after rain",
      layout_columns(
        fill = FALSE,
        col_widths = c(6, 6),
        card(
          card_header("How to read this table"),
          p(class = "help",
            "Every beach in your beach's region, sorted by rain effect. Dry ",
            "means under 1 mm of rain in the previous 72 hours; wet means ",
            "10 mm or more. Rain effect is the wet percentage minus the dry ",
            "percentage. A large rain effect means that beach needs extra ",
            "care after rain. Reliability shows whether a beach has at ",
            "least 10 dry and 10 wet samples; fewer than that makes its ",
            "percentages unreliable.")
        ),
        card(
          card_header("What stands out"),
          textOutput("compare_summary")
        )
      ),
      card(tableOutput("site_table"))
    ),
    
    nav_panel(
      "How to use this app",
      layout_columns(
        col_widths = c(6, 6, 6, 6),
        card(
          class = "guide",
          card_header("The controls"),
          p(strong("Choose your beach: "), "beaches are grouped by Beachwatch ",
            "region. The beige bars summarise every beach in that region."),
          p(strong("Count a sample as unsafe above: "), "enterococci are gut ",
            "bacteria that signal sewage or stormwater pollution. The NHMRC ",
            "guidelines grade sites using 40, 200 and 500 cfu per 100 mL. A ",
            "lower number is more cautious."),
          p(strong("Years and swimming season: "), "narrow the period to see ",
            "whether recent years look different, or include winter samples.")
        ),
        card(
          class = "guide",
          card_header("The fields"),
          p(strong("Rain in the 72 hours before the sample: "), "total rain on ",
            "the three days before the sample date. Stormwater can take a day ",
            "or more to clear."),
          p(strong("Samples above the threshold: "), "of all samples in a ",
            "rainfall band, the percentage above your chosen level."),
          p(strong("Rain effect: "), "on the Compare tab, the percentage of ",
            "unsafe samples after 10 mm or more of rain minus the percentage ",
            "after under 1 mm.")
        ),
        card(
          class = "guide",
          card_header("Reading the results"),
          p(strong("Blue bars climbing left to right: "), "rain makes your beach ",
            "riskier. The steeper the climb, the longer it is worth waiting ",
            "after rain."),
          p(strong("Blue bars below the beige bars: "), "your beach is cleaner ",
            "than its region in that weather."),
          p(strong("Faded bars or a yellow warning: "), "fewer than 10 samples, ",
            "so the percentage could easily change. Rely on the regional bars ",
            "or widen the years.")
        ),
        card(
          class = "guide",
          card_header("Limitations"),
          p("Rainfall comes from one location near Sydney Observatory Hill, so ",
            "a local storm at your beach may be missed."),
          p("The NHMRC levels are designed for long-run percentiles, not single ",
            "samples, so they are used here as simple reference levels."),
          p("These are past patterns, not today's water: check the Beachwatch ",
            "daily forecast before swimming.")
        )
      )
    )
  )
)

# Server -------------------------------------------------------------------
server <- function(input, output, session) {
  region_samples <- reactive({
    chosen_region <- sites$region[sites$swim_site == input$site]
    df <- samples |>
      filter(
        region == chosen_region,
        as.numeric(format(date, "%Y")) >= input$years[1],
        as.numeric(format(date, "%Y")) <= input$years[2]
      )
    if (input$season_only) {
      df <- filter(df, as.numeric(format(date, "%m")) %in% c(10:12, 1:4))
    }
    df
  }, label = "region_samples")
  
  beach_data <- reactive({
    df <- filter(region_samples(), swim_site == input$site)
    validate(need(nrow(df) > 0, paste(
      "No samples were taken at this beach in the chosen years and season.",
      "Try a wider range of years or untick 'Swimming season only'."
    )))
    df
  }, label = "beach_data")
  
  beach_summary <- reactive({
    summarise_exceedance(beach_data(), threshold = as.numeric(input$threshold))
  }, label = "beach_summary")
  
  region_summary <- reactive({
    summarise_exceedance(region_samples(),
                         threshold = as.numeric(input$threshold))
  }, label = "region_summary")
  
  # Value boxes
  output$dry_pct <- renderText({
    dry <- beach_summary()$prop_exceed[1]
    if (is.na(dry)) "no samples" else paste0(round(100 * dry), "%")
  })
  output$wet_pct <- renderText({
    wet <- beach_summary()$prop_exceed[4]
    if (is.na(wet)) "no samples" else paste0(round(100 * wet), "%")
  })
  output$n_samples <- renderText({
    nrow(beach_data())
  })
  
  output$few_samples_warning <- renderUI({
    if (any(beach_summary()$few_samples)) {
      div(class = "alert alert-warning",
          strong("Not much evidence here. "),
          "Some rainfall bands have fewer than 10 samples at this beach, so ",
          "their percentages are unreliable. Rely more on the beige regional ",
          "bars, or widen the years.")
    }
  })
  
  output$plot_title <- renderText({
    paste0("How often was the water at ", input$site, " above ",
           input$threshold, " cfu/100 mL?")
  })
  
  output$exceed_plot <- renderPlot({
    plot_exceedance(
      beach_summary(),
      region_summary(),
      selection_label = input$site,
      context_label = "All beaches in the region",
      threshold = input$threshold
    )
  }, res = 96)
  
  output$interpretation <- renderText({
    dry <- beach_summary()$prop_exceed[1]
    wet <- beach_summary()$prop_exceed[4]
    if (is.na(dry) || is.na(wet)) {
      return("There are not enough samples to compare dry and heavy-rain days. Try a wider range of years.")
    }
    paste0(
      "At ", input$site, ", ", round(100 * dry), "% of samples taken after ",
      "dry weather were above ", input$threshold, " cfu/100 mL, compared with ",
      round(100 * wet), "% after 25 mm or more of rain in the previous three ",
      "days. These are past patterns, not a forecast for today."
    )
  })
  
  # One comparison feeds both the summary text and the table
  site_comparison <- reactive({
    compare_sites(region_samples(), threshold = as.numeric(input$threshold))
  }, label = "site_comparison")
  
  output$compare_summary <- renderText({
    tab <- site_comparison()
    tab <- tab[!is.na(tab$rain_effect), ]
    validate(need(nrow(tab) > 0,
                  "No beaches in this region have both dry and wet samples."))
    rank <- which(tab$swim_site == input$site)
    paste0(
      "Most affected by rain: ", tab$swim_site[1], " (",
      sprintf("%+.0f", tab$rain_effect[1]), " points). Least affected: ",
      tab$swim_site[nrow(tab)], " (",
      sprintf("%+.0f", tab$rain_effect[nrow(tab)]), " points). ",
      if (length(rank) == 1) {
        paste0(input$site, " ranks ", rank, " of ", nrow(tab),
               " beaches in its region.")
      } else {
        paste0(input$site, " lacks dry or wet samples to rank.")
      }
    )
  })
  
  output$site_table <- renderTable({
    site_comparison() |>
      transmute(
        Beach = swim_site,
        `Unsafe when dry (%)` = round(pct_dry),
        `Unsafe when wet (%)` = round(pct_wet),
        `Rain effect (points)` = round(rain_effect),
        `Samples (dry / wet)` = paste(n_dry, "/", n_wet),
        # Every row gets a label, so an empty cell never looks like missing data
        Reliability = ifelse(few_samples,  "Under 10 samples: use caution",
                             "10+ samples in each group")
      )
  }, striped = TRUE, hover = TRUE, digits = 0, width = "100%")
}

shinyApp(ui, server)


