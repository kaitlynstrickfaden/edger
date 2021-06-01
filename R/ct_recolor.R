

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


ct_recolor <- function(imdf, m, rgbcolor, show = TRUE) {

  imdf$value[imdf$id %in% m] <- rep(rgbcolor, each = length(m))

  newim <- imager::as.cimg(imdf,
                        dim = c(max(imdf$x), max(imdf$y), 1, max(imdf$cc))
  )

  if (show == TRUE) {

    ct_display(newim)

  }

  return(newim)

}
