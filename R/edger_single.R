

#' Find and Recolor Contours in a Single Image
#'
#' Define a rectangular region and locate pixels with contour value greater than the one defined within the function. Then, recolor pixels and display recolored image.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_split str_flatten
#' @import dplyr
#' @import grDevices
#' @import imager
#' @param imagepath The file path to the image to be analyzed.
#' @param roi An argument for delineating the region(s) of interest outside of the main function. Default is NULL and will launch a user interface so the user can draw a region(s) of interest on the image. If "roi" is not NULL, input should be a list containing a 4-column data frame with a number of rows equal to regions. The data frame needs to contain coordinates to the region(s) of interest in the following order: top-left x, top-left y, bottom-right x, bottom-right y. Note that plotting of images by "imager" starts in the top-left corner.
#' @param th A numeric between 1-100 for the lowest contour value you want to recolor (a low contour value captures weaker contrasts). Default is 20.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param shift A vector of length 2 containing numerics indicating the amount of shift along the x axis first and the y axis second. Positive values indicate shifts right or up, while negative values indicate shifts left or down. Default is c(0,0).
#' @param rotate A numeric indicating the number of degrees to rotate the recolored pixels. Pixels are rotated around the center of the edge pixels. Default is 0.
#' @return The input data frame as an image.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @param save Logical. Save the output image. Default is FALSE.
#' @return A recolored image. If save == TRUE, saves recolored image to working directory with "_contourr" appended to the original name.
#' @export


edger_single <- function(imagepath,
                         roi = NULL,
                         th = 20,
                         regions = 1,
                         shift = c(0,0),
                         rotate = 0,
                         color = "red",
                         save = FALSE)

{

  if (is.null(roi) == FALSE & is.list(roi) == FALSE) {
    stop("roi must be a list object.")
  }

  if (th <= 0) {
    stop("th must be a positive non-zero number.")
  }

  if (is.character(color) == FALSE) {
    stop("color must be a character string.")
  }

  rgbcolor <- as.vector(grDevices::col2rgb(color)/255)

  ROI <- edger_identify(ref_ims = imagepath,
                        roi = roi,
                        th = th,
                        regions = regions)

  st <- Sys.time()

  im <- imager::load.image(imagepath)
  im_df <- edger_im_to_df(im)

  m <- edger_match(imdf = im_df,
                   roi = ROI,
                   shift = shift,
                   rotate = rotate)

  im_new <- edger_recolor(imdf = im_df,
                          m = m,
                          rgbcolor = rgbcolor,
                          show = TRUE)


  ## Save new image if save == TRUE

  if (save == TRUE) {

    if (invisible(system2("where", "exiftool")) == 1) {
      stop("Could not find installation of ExifTool.")
    }

    im_newname <- edger_name(imagepath)
    edger_save(im_new, im_newname)
    edger_meta(imagepath)

  } # End of save == TRUE

  round(Sys.time() - st, 2)

} # End of function
