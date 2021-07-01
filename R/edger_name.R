

#' Find New Name to be Given to Recolored Image
#'
#' Append "_edger" to the given filename
#'
#' @import grDevices
#' @import imager
#' @param imagepath The raw image name as a character.
#' @return The new edger image name (the raw file name with "_edger" appended before the filename extension).
#' @export


edger_name <- function(imagepath) {

  image_split <- stringr::str_split(imagepath, "\\.")[[1]]
  image_start <- str_flatten(image_split[c(1:length(image_split) - 1)], collapse = ".")
  image_end <- image_split[length(image_split)]
  image_name <- paste(image_start, "_edger.", image_end, sep = "")

  return(image_name)

}