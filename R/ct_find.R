

#' Find and Highlight Contours
#'
#' Define a rectangular region and locate pixels with contour value greater than the one defined within the function. Then, recolor pixels and display recolored image.
#'
#' @importFrom graphics par plot
#' @import grDevices
#' @import imager
#' @param ref_image The name of the input image.
#' @param contourvalue The minimum pixel value you want to keep (a low contour value captures weaker contrasts). Default is 0.1.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param save Logical. Save the output image. Default is FALSE.
#' @param output_ref_image If save == TRUE, the name you want to give the output image. Must end in .jpg or .jpeg.
#' @return A recolored image. If save == TRUE, saves the recolored image to your working directory.
#' @export


ct_find <- function(ref_image,
                    contourvalue = 0.1,
                    color = "red",
                    regions = 1,
                    save = FALSE,
                    output_ref_image = NA)
{

  if (save == TRUE){
    if (is.na(output_ref_image)){
      stop("must supply output_ref_image if save == TRUE")
    }
  }
  if (is.character(color) == FALSE) {
    stop("color must be of type character")}


  ## Load in the image

  im <- imager::load.image(ref_image)
  im_df <- as.data.frame(im)

  ## Manipulate image for finding contours & make into df

  im_bw <- as.data.frame(enorm(imgradient(grayscale(im),"xy")))

  ## Assign unique pixel values for indexing

  im_df$id <- rep(1:length(im_bw$x), times = 3)
  im_bw$id <- 1:length(im_bw$x)

  ## Find RGB value of selected color

  rgbcolor <- as.vector(col2rgb(color)/255)

  ## Define region of interest

  im_roi <- grabRect(im, output = "coord")

  roi <- NULL

  for (i in 1:regions){

    im_roi <- grabRect(im, output = "coord")

    roi2 <- filter(im_bw,
                   x >= im_roi[1] & x <= im_roi[3] &
                     y >= im_roi[2] & y <= im_roi[4])

    roi <- rbind(roi, roi2)

  } # End of regions

  roi <- distinct(roi)



  ## Find contours in region of interest

  roi_c <- roi[roi$value >= contourvalue,]

  ## Find contour pixels in full image

  m <- im_df$id[match(roi_c$id, im_df$id)]

  ## Recolor contour pixels in full image

  im_df$value[im_df$id %in% m] <- rep(rgbcolor, each = length(m))



  ## Display the new image

  im <- as.cimg(im_df, dim = dim(im))

  par(mar = c(0,0,0,0))
  plot(im)



  ## Save new image if save == TRUE

  if (save == TRUE){

    # Save new photo
    jpeg(output_ref_image, width = dim(im)[1], height = dim(im)[2]) # begin creation of an image file
    par(mar = c(0,0,0,0)) # remove axes and margins
    plot(im) # plot new image
    dev.off() # stop and save image file with contours drawn on it

  } # End of save == TRUE


} # End of function


