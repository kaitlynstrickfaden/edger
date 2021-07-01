

#' Display an Image
#'
#' Display an image in the plot pane.
#'
#' @import grDevices
#' @import imager
#' @param cimage An image to display.
#' @return An image.
#' @export


edger_display <- function(cimage)

{

  par(mar = c(0,0,0,0))
  plot(cimage)

}
