

#' Overlay Contours Onto Images
#'
#' Define a rectangular region and locate pixels with contour value greater than the one defined within the function. Then, recolor pixels and display recolored image.
#'
#' @importFrom graphics par plot
#' @import grDevices
#' @import imager
#' @param ref_image The name of the input reference image
#' @param contourvalue The minimum pixel value you want to keep (a low contour value captures weaker contrasts)
#' @param rgbcolor A vector containing the RGB values for the color mask on a 0-1 scale. Default is c(1,0,0), which is pure red.
#' @param output_ref_image The name you want to give the output reference image.
#' @param image_names a vector containing the names of the photos you want to recolor.
#' @param output_image_names a vector containing the names for the new images with recolored pixels. Must be the same length as image_names.
#' @param imwidth Image width, in pixels.
#' @param imht Image height, in pixels .
#' @return Recolored images. Will save the recolored image to your working directory
#' @export


overlay <- function(ref_image, contourvalue, rgbcolor = c(1,0,0), output_ref_image, image_names, output_image_names, imwidth, imht){

  if (length(image_names) != length(output_image_names)){
    stop("image_names and output_image_names must be the same length")
  }

  st <- Sys.time()

  im <- load.image(ref_image)
  imnew <- im
  imcont <- as.data.frame(enorm(imgradient(grayscale(im),"xy")))
  imc <- grabRect(im, output = "coord") # draw a box around the object of interest

  maskx <- NULL
  masky <- NULL

  # Change pixel color at contours
  for (x in imc[1]:imc[3]){ # within the box drawn before...
    for (y in imc[2]:imc[4]){
      pix <- data.frame(imcont[which(imcont$x == x & imcont$y == y),])
      if (pix$value > contourvalue) { # if the pixel is a contour...
        imnew[x,y,1,] <- rgbcolor
        maskx <- append(maskx, x)
        masky <- append(masky, y)
      } else {
        imnew[x,y,1,] <- im[x,y,1,] # or else keep it the original color
      }
    }
  }


  # Save new photo
  jpeg(output_ref_image, width = imwidth, height = imht) # begin creation of an image file
  par(mar = c(0,0,0,0)) # remove axes and margins
  plot(imnew) # plot new image
  dev.off() # save image file


  # Display the image
  par(mar = c(0,0,0,0))
  plot(imnew)

  # Create the object "mask"

  for (i in 1:length(image_names)){
    im2 <- load.image(image_names[i])


    # find the same pixels in the next image and recolor them
    for (j in 1:length(maskx)){
      im2[maskx[j], masky[j],1,] <- rgbcolor
    }

    plot(im2) # plot the new image

    jpeg(output_image_names[i], width = imwidth, height = imht) # begin creation of an image file
    par(mar = c(0,0,0,0)) # remove axes and margins
    plot(im2) # plot new image
    dev.off() # save image file
  }

  Sys.time() - st

}


