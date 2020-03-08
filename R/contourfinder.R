

#' Find and Highlight Contours
#'
#' Define a rectangular region and locate pixels with contour value greater than the one defined within the function. Then, recolor pixels and display recolored image.
#'
#' @importFrom graphics par plot
#' @import grDevices
#' @import imager
#' @param ref_image The name of the input image
#' @param contourvalue The minimum pixel value you want to keep (a low contour value captures weaker contrasts)
#' @param rgbcolor A vector containing the rgb values for the color mask on a 0-1 scale. Default is c(1,0,0), which is pure red.
#' @param save Logical. Save the image as a new file. Default is FALSE.
#' @param output_ref_image If save == TRUE, the name you want to give the output image.
#' @param imwidth If save == TRUE, the output image width, in pixels.
#' @param imht If save == TRUE, the output image height, in pixels .
#' @return A recolored image. If save == TRUE, will save the recolored image to your working directory
#' @export


contourfinder <- function(ref_image, contourvalue, rgbcolor = c(1,0,0), save = FALSE, output_ref_image = NA, imwidth = NA, imht = NA){

  if (is.vector(rgbcolor) == FALSE | length(rgbcolor) != 3){
    stop("rgbcolor must be a numeric vector with length 3")}
  if (!is.na(output_ref_image)){
    if (!endsWith(output_ref_image, ".jpeg")){
        stop("output_ref_image must be a .jpeg file")}
  }

  # Load in & prep the data
  im <- imager::load.image(ref_image)
  imnew <- im
  imcont <- as.data.frame(enorm(imgradient(grayscale(im),"xy")))
  imc <- grabRect(im, output = "coord") # draw a box around the object of interest

  # Change pixel color at contours
  for (x in imc[1]:imc[3]){ # within the box drawn before...
    for (y in imc[2]:imc[4]){
      pix <- data.frame(imcont[which(imcont$x == x & imcont$y == y),])
      if (pix$value > contourvalue) { # if the pixel is a contour...
        imnew[x,y,1,] <- rgbcolor
      } else {
        imnew[x,y,1,] <- im[x,y,1,] # or else keep it the original color
      }
    }
  }

  if (save == TRUE){

    # Save new photo
    jpeg(output_ref_image, width = imwidth, height = imht) # begin creation of an image file
    par(mar = c(0,0,0,0)) # remove axes and margins
    plot(imnew) # plot new image
    dev.off() # stop and save image file with contours drawn on it

  }

  # Display the image
  par(mar = c(0,0,0,0))
  plot(imnew)



}


