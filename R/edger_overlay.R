

#' Apply Contours to an Image
#'
#' After finding contours in image(s), apply those contours to a new image.
#'
#' @import grDevices
#' @import imager
#' @param imagepath The file path to the image to be recolored.
#' @param m A vector of unique identifiers to pixels that were contours in a different image.
#' @param rgbcolor A vector of new values for each of the color channels.
#' @param show_image A Boolean indicating if the image should be displayed. Default is FALSE.
#' @return Recolors and saves image.
#' @export


edger_overlay <- function(imagepath,
                       m,
                       rgbcolor,
                       show_image = FALSE) {

  im <- imager::load.image(imagepath)
  im_df <- edger_im_to_df(im)

  im_new <- edger_recolor(im_df, m, rgbcolor, show = show_image)
  im_newname <- edger_name(imagepath)

  edger_save(im_new, im_newname)

  #return(im_newname)

}

