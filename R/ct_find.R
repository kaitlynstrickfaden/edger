

#' Find and Recolor Contours in a Single Image
#'
#' Define a rectangular region and locate pixels with contour value greater than the one defined within the function. Then, recolor pixels and display recolored image.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_split str_flatten
#' @import dplyr
#' @import grDevices
#' @import imager
#' @param image The file path to the image to be analyzed.
#' @param roi_in An argument for delineating the region(s) of interest outside of the main function. Default is NULL and will launch a user interface so the user can draw a region(s) of interest on the image. If "roi_in" is not NULL input should be a 4-column data frame with a number of rows equal to regions. The data frame needs to contain coordinates to the region(s) of interest in the following order: top-left x, top-left y, bottom-right x, bottom-right y. Note that plotting of images by "imager" starts in the top-left corner.
#' @param contour_value A numeric between 0-1 for the lowest contour value you want to recolor (a low contour value captures weaker contrasts). Default is 0.1.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param save Logical. Save the output image. Default is FALSE.
#' @return A recolored image. If save == TRUE, saves recolored image to working directory with "_contourr" appended to the original name.
#' @export


ct_find <- function(image,
                    roi_in = NULL,
                    contour_value = 0.1,
                    color = "red",
                    regions = 1,
                    save = FALSE)

{

  if (is.character(color) == FALSE) {
    stop("color must be a character string.")
  }

  if (contour_value <= 0) {
    stop("contour_value must be a positive non-zero number.")
  }

  ## Load in the image

  im <- imager::load.image(image)
  im_df <- as.data.frame(im)

  ## Manipulate image for finding contours & make into df

  im_bw <- as.data.frame(imager::enorm(imager::imgradient(imager::grayscale(im),"xy")))

  ## Assign unique pixel values for indexing

  im_df$id <- rep(1:length(im_bw$x), times = 3)
  im_bw$id <- 1:length(im_bw$x)

  ## Find RGB value of selected color

  rgbcolor <- as.vector(grDevices::col2rgb(color)/255)

  ## Define region of interest if "roi_in" is not set:

  if (is.null(roi_in) == TRUE) {

    roi <- NULL

    for (i in 1:regions) {

      im_roi <- imager::grabRect(im, output = "coord")

      roi2 <- dplyr::filter(im_bw,
                     im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                     im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4])

      roi <- rbind(roi, roi2)

    } # End of regions

  }


  ## Define region of interest if "roi_in" is set:

  if (is.null(roi_in) == FALSE) {

    roi <- NULL

    for (i in 1:regions) {

      im_roi <- as.numeric(roi_in[i,])

      roi2 <- dplyr::filter(im_bw,
                            im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                              im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4])

      roi <- rbind(roi, roi2)

    } # End of regions

  }

  roi <- dplyr::distinct(roi)


  ## Track time

  st <- Sys.time()

  ## Find contours in region of interest

  roi_c <- roi[roi$value >= contour_value,]

  ## Match contour pixels in full image

  m <- im_df$id[match(roi_c$id, im_df$id)]

  ## Recolor contour pixels in full image

  im_df$value[im_df$id %in% m] <- rep(rgbcolor, each = length(m))



  ## Display the new image

  im <- imager::as.cimg(im_df, dim = dim(im))
  par(mar = c(0,0,0,0))
  plot(im)


  ## Save new image if save == TRUE

  if (save == TRUE) {

    image_split <- stringr::str_split(image, "\\.")[[1]]
    image_start <- str_flatten(image_split[c(1:length(image_split) - 1)], collapse = ".")
    image_end <- image_split[length(image_split)]
    image_name <- paste(image_start, "_contourr.", image_end, sep = "")


    grDevices::jpeg(image_name, width = dim(im)[1], height = dim(im)[2])
    par(mar = c(0,0,0,0))
    plot(im)
    dev.off()

  } # End of save == TRUE

  round(Sys.time() - st, 2)

} # End of function


