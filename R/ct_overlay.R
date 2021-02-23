

#' Overlay Contours Onto Images
#'
#' Find pixel coordinates of contours in defined regions of a reference image. Then, find and recolor the same pixels in new images.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_flatten str_glue str_split
#' @import dplyr
#' @import grDevices
#' @import imager
#' @import progress
#' @param images A vector containing file paths of images to be analyzed. The first image will be the reference image, and contours from the first image will be superimposed onto the other images.
#' @param ref_images A numeric indicating in how many reference images you want to search for contours. Default is 1. When greater than 1, the first n images will be used.
#' @param roi_in An argument for delineating the region(s) of interest outside of the main function. Default is NULL and will launch a user interface so the user can draw a region(s) of interest on the image. If "roi_in" is not NULL and ref_images = 1, input should be a 4-column data frame with a number of rows equal to regions. The data frame needs to contain coordinates to the region(s) of interest in the following order: top-left x, top-left y, bottom-right x, bottom-right y. If "roi_in" is not NULL and ref_images > 1, input should be a list of length ref_images, and each item of the list should be a separate 4-column data frame for the region(s) of interest in each image. Note that plotting of images by "imager" starts in the top-left corner.
#' @param contour_value A numeric between 0-1 for the lowest contour value you want to recolor (a low contour value captures weaker contrasts). Default is 0.1.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param shift A vector of length 2 containing numerics indicating the amount of shift along the x axis first and the y axis second. Positive values indicate shifts right or up, while negative values indicate shifts left or down.
#' @param show_image Logical. Plot images as they are recolored. Default is TRUE.
#' @return Recolored images. Saves recolored images to working directory with "_contourr" appended to the original name.
#' @export




ct_overlay <- function(images,
                       ref_images = 1,
                       roi_in = NULL,
                       contour_value = .1,
                       color = "red",
                       regions = 1,
                       shift = c(0,0),
                       show_image = TRUE)

{

  # Check if file paths are valid
  for (i in seq_along(images)) {
    if (file.exists(images[i]) == FALSE) {
      stop(str_glue("images[", i, "] is not a valid path.", sep = "")) }
  }

  # Check if ref_images matches with roi_in
  if (is.list(roi_in) == TRUE) {
    if (is.data.frame(roi_in) == TRUE) {
      if (ref_images != 1) {
        stop("If roi_in is a data frame object, then ref_images must equal 1.")
      }
    }
    if (is.data.frame(roi_in) == FALSE) {
      if (ref_images != length(roi_in)) {
        stop(str_glue("ref_images {ref_images} and length of roi_in {length(roi_in)} do not match."))
        }
      }
  }

  # Check if color is a character
  if (is.character(color) == FALSE) {
    stop("color must be a character string.")
  }

  # Check if shift is a coordinate pair
  if (is.numeric(shift) == FALSE | length(shift) != 2) {
    stop("shift must be a numeric vector of length 2.")
  }

  # Check if contour_value is valid
  if (contour_value <= 0) {
    stop("contour_value must be a positive non-zero number.")
  }



  rgbcolor <- as.vector(grDevices::col2rgb(color)/255)

  roi <- NULL

  x_shift <- shift[1]
  y_shift <- -shift[2]

  ## Load in reference image(s)

  for (j in 1:ref_images) {

    im <- imager::load.image(images[j])
    im_df <- as.data.frame(im)

    ## Manipulate image for finding contours & make into df

    im_bw <- as.data.frame(imager::enorm(imager::imgradient(imager::grayscale(im),"xy")))

    ## Assign unique pixel values for indexing

    im_bw$id <- 1:length(im_bw$x)


    ## Define region of interest if "roi_in" is not set:

    if (is.null(roi_in) == TRUE) {

      for (i in 1:regions) {

        im_roi <- imager::grabRect(im, output = "coord")

        roi2 <- dplyr::filter(im_bw,
                              im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                                im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4])

        roi <- rbind(roi, roi2)

      } # End of regions

    }


    ## Define region of interest if "roi_in" is set and ref_images == 1:

    if (is.null(roi_in) == FALSE & ref_images == 1) {

      for (i in 1:regions) {

        im_roi <- as.numeric(roi_in[i,])

        roi2 <- dplyr::filter(im_bw,
                              im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                                im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4])

        roi <- rbind(roi, roi2)

      } # End of regions

    }

    ## Define region of interest if "roi_in" is set and ref_images > 1:

    if (is.null(roi_in) == FALSE & ref_images > 1) {

      for (i in 1:regions) {

        im_roi <- as.numeric(roi_in[[j]][i,])

        roi2 <- dplyr::filter(im_bw,
                              im_bw$x >= im_roi[1] & im_bw$x <= im_roi[3] &
                                im_bw$y >= im_roi[2] & im_bw$y <= im_roi[4])

        roi <- rbind(roi, roi2)

      } # End of regions

    }

  } # End of photos


  roi <- dplyr::distinct(roi)


  ## Progress Bar

  pb <- progress_bar$new(
    format = " recoloring image :current of :total  [:bar]  :percent  elapsed: :elapsedfull",
    total = length(images), clear = FALSE, width = 80)



  im <- imager::load.image(images[1])
  im_df <- as.data.frame(im)
  im_df$id <- rep(1:length(im_bw$x), times = 3)


  ## Find contours in region of interest

  roi_cv <- roi[roi$value >= contour_value,]

  ## Find pixels to recolor in full image (accounting for shifting)

  m_df <- im_df[match(roi_cv$id, im_df$id),]
  m_df$keep <- "Y"

  for (i in seq_along(m_df$id)) {

    if (m_df$x[i] + x_shift > dim(im)[1]) {
      m_df$keep[i] <- "N" }
    if (m_df$x[i] + x_shift < 0) {
      m_df$keep[i] <- "N" }
    if (m_df$y[i] + y_shift > dim(im)[2]) {
      m_df$keep[i] <- "N" }
    if (m_df$y[i] + y_shift < 0) {
      m_df$keep[i] <- "N" }

  }

  m <- m_df$id[m_df$keep == "Y"] + x_shift + (y_shift * dim(im)[2])


  ## Recolor contour pixels in full image

  im_df$value[im_df$id %in% m] <- rep(rgbcolor, each = length(m))

  ## Display the new image

  im <- imager::as.cimg(im_df, dim = dim(im))

  par(mar = c(0,0,0,0))
  plot(im)

  pb$tick()

  # Save new photo

  image_split1 <- stringr::str_split(images[1], "\\.")[[1]]
  image_start1 <- str_flatten(image_split1[c(1:length(image_split1) - 1)], collapse = ".")
  image_end1 <- image_split1[length(image_split1)]
  image_name1 <- paste(image_start1, "_contourr.", image_end1, sep = "")

  grDevices::jpeg(image_name1, width = dim(im)[1], height = dim(im)[2])
  par(mar = c(0,0,0,0))
  plot(im)
  dev.off()


  ## Recolor other images

  for (i in 2:length(images)) {

    ## Load in new image

    im2 <- imager::load.image(images[i])
    im2_df <- as.data.frame(im2)
    im2_df$id <- im_df$id


    ## Recolor contour pixels in full image

    im2_df$value[im2_df$id %in% m] <- rep(rgbcolor, each = length(m))

    im2 <- imager::as.cimg(im2_df, dim = dim(im2))


    ## (Optionally) display the new image

    if (show_image == TRUE) {
      par(mar = c(0,0,0,0))
      plot(im2)
    }

    ## Save the new image

    image_split <- stringr::str_split(images[i], "\\.")[[1]]
    image_start <- str_flatten(image_split[c(1:length(image_split) - 1)], collapse = ".")
    image_end <- image_split[length(image_split)]
    image_name <- paste(image_start, "_contourr.", image_end, sep = "")

    grDevices::jpeg(image_name, width = dim(im2)[1], height = dim(im2)[2])
    par(mar = c(0,0,0,0))
    plot(im2)
    dev.off()

    pb$tick()

  } # End of recolor new images


} # End of function


