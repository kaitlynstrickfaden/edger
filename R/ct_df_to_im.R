

#' Convert a Data Frame into an Image
#'
#' Convert a data frame into either a black and white or a color image. Optionally display the new image.
#'
#' @import grDevices
#' @import imager
#' @param imdf A data frame to be converted. Must contain at least 3 columns: x, y, and value. If a color image, must also contain a cc column.
#' @param show A Boolean indicating if the new image should be displayed. Default is FALSE.
#' @return The input data frame as an image.
#' @export


ct_df_to_im <- function(imdf, show = FALSE)

{

  if (is.data.frame(imdf) == FALSE) {
    stop("Input must be a data frame") }

  if ("x" %in% colnames(imdf) == FALSE |
      "y" %in% colnames(imdf) == FALSE |
      "value" %in% colnames(imdf) == FALSE) {
    stop("Input data frame must contain an x, y, and value column") }

  im <- imager::as.cimg(imdf,
                        dim = c(max(imdf$x), max(imdf$y), 1, 1)
  )

  if (show == TRUE) {

    ct_display(im)

  }

  return(im)

}
