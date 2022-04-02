

#' Find New Name to be Given to Recolored Image
#'
#' Append "_edger" to the given filename
#'
#' @import grDevices
#' @import imager
#' @importFrom stringr str_flatten str_split
#' @param imagepath The raw image name as a character.
#' @return The new edger image name (the raw file name with "_edger" appended before the filename extension).
#' @export


edger_name <- function(imagepath) {

  image_split <- str_split(imagepath, "\\.")[[1]]
  image_start <- str_flatten(image_split[c(1:length(image_split) - 1)], collapse = ".")
  image_end <- image_split[length(image_split)]
  image_name <- paste0(image_start, "_edger.", image_end)

  return(image_name)

}
