

#' Convert an Image Into a Data Frame
#'
#' Convert an image into a data frame with a new unique identifier column to be used in the contourr workflow.
#'
#' @import grDevices
#' @import imager
#' @param cimage The image to be converted.
#' @return The input image as a data frame, with a new column for the unique identifier of each pixel.
#' @export


ct_im_to_df <- function(cimage)

{

  # Check if file path is valid
  if (is.cimg(cimage) == FALSE) {
    stop("Input must be a cimg object") }

  im_df <- as.data.frame(cimage)
  im_df$id <- rep(1:(dim(cimage)[1] * dim(cimage)[2]), times = 3)

  return(im_df)

}
