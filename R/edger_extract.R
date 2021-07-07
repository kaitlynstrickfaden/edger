

#' Extract Edge Pixels
#'
#' Find pixel coordinates of edges in defined regions of a reference image.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_flatten str_glue str_split
#' @import dplyr
#' @import grDevices
#' @import imager
#' @param imagepath The file path to the image to be analyzed.
#' @param roi_in An argument for delineating the region(s) of interest outside of the main function. Default is NULL and will launch a user interface so the user can draw a region(s) of interest on the image. If "roi_in" is not NULL input should be a list containing a 4-column data frame with a number of rows equal to regions. The data frame needs to contain coordinates to the region(s) of interest in the following order: top-left x, top-left y, bottom-right x, bottom-right y. Note that plotting of images by "imager" starts in the top-left corner.
#' @param th A vector of numeric values between 0-1 for the lowest threshold value you want to recolor in each image(a low threshold value captures weaker contrasts). Default is 0.1.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param shift A vector of length 2 containing numerics indicating the amount of shift along the x axis first and the y axis second. Positive values indicate shifts right or up, while negative values indicate shifts left or down. Default is c(0,0).
#' @param rotate A numeric indicating the number of degrees to rotate the recolored pixels. Pixels are rotated around the center of the edge pixels. Default is 0.
#' @param color A character string for the color of the superimposed object. Default is red. Only needs to be set if show_image == TRUE.
#' @param show_image Logical. Plot the image with the extracted pixels recolored. Default is TRUE.
#' @return A data frame containing the x and y coordinates and the unique pixel identifiers for each edge pixel.
#' @export




edger_extract <- function(imagepath,
                       roi_in = NULL,
                       th = 0.1,
                       regions = 1,
                       shift = c(0,0),
                       rotate = 0,
                       color = "red",
                       show_image = TRUE)

{

  if (is.null(roi_in) == FALSE & is.list(roi_in) == FALSE) {
    stop("roi_in must be a list object.")
  }

  if (th <= 0) {
    stop("th must be a positive non-zero number.")
  }

  if (is.character(color) == FALSE) {
    stop("color must be a character string.")
  }

  rgbcolor <- as.vector(grDevices::col2rgb(color)/255)

  roi <- edger_identify(ref_ims = imagepath,
                        roi_in = roi_in,
                        th = th,
                        regions = regions)

  im <- imager::load.image(imagepath)
  im_df <- edger_im_to_df(im)

  m <- edger_match(imdf = im_df,
                   roi = roi,
                   shift = shift,
                   rotate = rotate)

  if (show_image == TRUE) {

    edger_recolor(imdf = im_df,
                  m = m,
                  rgbcolor = rgbcolor,
                  show = TRUE)

  }

  return(distinct(im_df[im_df$id %in% m,c("x", "y", "id")]))

}
