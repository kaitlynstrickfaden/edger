

#' Find Edges in the Region of Interest
#'
#' Define the region(s) of interest (ROI) in which edges will be found. Then, threshold pixels in ROI based on value to find strong edges. Regions can either be drawn on by the user in a GUI or pre-defined. Several regions can be drawn per photo, and regions can be drawn across several photos.
#'
#' @importFrom dplyr distinct filter
#' @import grDevices
#' @import imager
#' @importFrom rlang .data
#' @param ref_ims A vector containing file paths of images in which the region(s) of interest will be defined.
#' @param roi An argument for delineating the region(s) of interest outside of the main function. Default is NULL and will launch a user interface so the user can draw a region(s) of interest on the image. If "roi" is not NULL and ref_images = 1, input should be a 4-column data frame with a number of rows equal to regions. The data frame needs to contain coordinates to the region(s) of interest in the following order: top-left x, top-left y, bottom-right x, bottom-right y. If "roi" is not NULL and ref_images > 1, input should be a list of length ref_images, and each item of the list should be a separate 4-column data frame for the region(s) of interest in each image. Note that plotting of images by "imager" starts in the top-left corner.
#' @param th A vector of numeric values between 1-100 for the lowest threshold value you want to recolor in each image(a low edge value captures weaker contrasts). Default is 20.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @return The input data frame as an image.
#' @export


edger_identify <- function(ref_ims,
                        roi = NULL,
                        th = 20,
                        regions = 1
                        )

  {


  if (length(ref_ims) != length(th)) {
    stop("Number of threshold values must equal number of reference images")
  }

  roi1 <- NULL


  for (j in 1:length(ref_ims)) {

    im <- imager::load.image(ref_ims[j])
    im_bw <- edger_im_to_grad(im)


    ## Define region of interest if "roi" is not set:

    if (is.null(roi) == TRUE) {

      for (i in 1:regions) {

        im_roi <- imager::grabRect(im, output = "coord")

        roi2 <- dplyr::filter(im_bw,
                              im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                                im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4] &
                                im_bw$value >= (th[j]/200))

        roi1 <- rbind(roi1, roi2)

      } # End of regions

    }


    if (is.null(roi) == FALSE) {

      for (i in 1:regions) {

        im_roi <- as.numeric(roi[[j]][i,])

        roi2 <- dplyr::filter(im_bw,
                              im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                                im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4] &
                                im_bw$value >= (th[j]/200))

        roi1 <- rbind(roi1, roi2)

      } # End of regions

    }

  } # End of photos


  return(distinct(roi1))


}
