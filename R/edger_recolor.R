

#' Find and Recolor Pixels in an Image
#'
#' Recolor pixels contained in m. Optionally display recolored image.
#'
#' @importFrom dplyr distinct filter
#' @import grDevices
#' @import imager
#' @param imdf A color image as a data frame.
#' @param m A vector containing unique identifiers of pixels to be recolored.
#' @param rgbcolor A vector of the new values for each color channel.
#' @param show A Boolean indicating if the new image should be shown. Default is TRUE.
#' @return A new image with pixels in m recolored.
#' @export


edger_recolor <- function(imdf, m, rgbcolor, show = TRUE) {

  imdf$value[imdf$id %in% m & imdf$cc == 1] <- rgbcolor[1]
  imdf$value[imdf$id %in% m & imdf$cc == 2] <- rgbcolor[2]
  imdf$value[imdf$id %in% m & imdf$cc == 3] <- rgbcolor[3]

  newim <- imager::as.cimg(imdf,
                           dim = c(max(imdf$x), max(imdf$y), 1, max(imdf$cc))
  )

  if (show == TRUE) {

    edger_display(newim)

  }

  return(newim)

}
