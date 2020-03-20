

#' Overlay Contours Onto Images
#'
#' Define a rectangular region and locate pixels with contour value greater than the one defined within the function. Then, recolor pixels and display recolored image.
#'
#' @importFrom graphics par plot
#' @import grDevices
#' @import imager
#' @import dplyr
#' @param ref_image The name of the reference image
#' @param contourvalue The minimum pixel value you want to keep (a low contour value captures weaker contrasts)
#' @param rgbcolor A vector containing the RGB values for the color mask on a 0-1 scale. Default is c(1,0,0), which is pure red
#' @param regions A numeric indicating how many regions to draw. Default is 1
#' @param output_ref_image The name you want to give the output reference image.
#' @param image_names a vector containing the names of the photos you want to recolor.
#' @param output_image_names a vector containing the names of the recolored images. Must be the same length as image_names.
#' @return Recolored images. Will save the recolored image to your working directory
#' @export


overlay <- function(ref_image, contourvalue, rgbcolor = c(1,0,0), regions = 1, output_ref_image, image_names, output_image_names){

  if (length(image_names) != length(output_image_names)){
    stop("image_names and output_image_names must be the same length")}
  if (is.vector(rgbcolor) == FALSE | length(rgbcolor) != 3){
    stop("rgbcolor must be a numeric vector with length 3")}

  st <- Sys.time()

  im <- load.image(ref_image)
  imcont <- as.data.frame(enorm(imgradient(grayscale(im),"xy")))

  maskx <- NULL
  masky <- NULL

  for (i in 1:regions){

    imc <- grabRect(im, output = "coord") # draw a box around the object of interest

    for (x in imc[1]:imc[3]){ # within the box drawn before...
      for (y in imc[2]:imc[4]){
        pix <- imcont[(imcont$x == x & imcont$y == y),]
        if (pix$value >= contourvalue) { # if the pixel is a contour...
          maskx <- append(maskx, x)
          masky <- append(masky, y)
        }
      }
    }
  }

  mask <- distinct(data.frame(x = maskx, y = masky))

  for (j in 1:length(mask$x)){
    im[mask$x[j], mask$y[j],1,] <- rgbcolor
  }

  # Save new photo
  jpeg(output_ref_image, width = dim(im)[1], height = dim(im)[2]) # begin creation of an image file
  par(mar = c(0,0,0,0)) # remove axes and margins
  plot(im) # plot new image
  dev.off() # save image file


  # Display the image
  par(mar = c(0,0,0,0))
  plot(im)

  # Apply the "mask" to new images

  for (i in 1:length(image_names)){
    im2 <- load.image(image_names[i])

    if (dim(im)[1] != dim(im2)[1] | dim(im)[2] != dim(im2)[2]){
      stop("input images must have the same dimensions as reference image")}

    # find the same pixels in the next image and recolor them
    for (j in 1:length(mask$x)){
      im2[mask$x[j], mask$y[j],1,] <- rgbcolor
    }

    plot(im2) # plot the new image

    jpeg(output_image_names[i], width = dim(im)[1], height = dim(im)[2]) # begin creation of an image file
    par(mar = c(0,0,0,0)) # remove axes and margins
    plot(im2) # plot new image
    dev.off() # save image file
  }

  Sys.time() - st

}


