

#' Convert an Image Into a Gradient Image
#'
#' Convert an image into a data frame of image gradients using Canny edge detection. Optionally display the gradient data frame as an image.
#'
#' @import grDevices
#' @import imager
#' @param cimage An image to be converted.
#' @param show A Boolean indicating if the gradient image should be displayed. Default is FALSE.
#' @return A data frame of image gradients with a column containing a unique identifier for each pixel in the image.
#' @export


ct_im_to_grad <- function(cimage, show = FALSE)

{

  if (is.cimg(cimage) == FALSE) {
    stop("Input must be a cimg object") }

  im_bw <- imager::grayscale(cimage) %>%
    imager::imgradient("xy") %>%
    enorm()

  if (show == TRUE) {

    ct_display(im_bw)

  }

  im_bw <- as.data.frame(im_bw)
  im_bw$id <- 1:(dim(cimage)[1]*dim(cimage)[2])
  return(im_bw)

}

