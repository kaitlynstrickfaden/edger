

#' Save an Image
#'
#' Save an image with the given filename.
#'
#' @import grDevices
#' @import imager
#' @param cimage The image to be saved.
#' @param imagename A name to give the image.
#' @return Saves image
#' @export


edger_save <- function(cimage, imagename) {

  grDevices::jpeg(imagename, width = dim(cimage)[1], height = dim(cimage)[2])
  edger_display(cimage)
  dev.off()

}
