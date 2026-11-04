#' Launch the "Rain Check" Shiny app
#'
#' Opens an app that helps Sydney swimmers see how much recent rain raises
#' the chance that the water at their beach has high bacteria levels. The
#' app uses [beach_samples] from this package, so no data files are read.
#'
#' @return No return value; called to launch the app.
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @export
run_app <- function() {
  # system.file() finds inst/app wherever the package is installed
  app_dir <- system.file("app", package = "beachrain")
  shiny::runApp(app_dir)
}
