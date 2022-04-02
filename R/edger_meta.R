

#' Extract and Reattribute Metadata
#'
#' Attribute metadata from original image to recolored image. Requires that exiftool is installed on your machine and is in your environmental variables.
#'
#' @import exiftoolr
#' @importFrom stringr str_glue
#' @param imagepath The file path to the original image
#' @return Recolored image with metadata tags from original image
#' @export


edger_meta <- function(imagepath) {

  # Check if file path is valid
  if (file.exists(imagepath) == FALSE) {
    stop(str_glue("{imagepath} is not a valid path.", sep = "")) }

  system2("exiftool", str_glue("-exif:all= -tagsfromfile {imagepath} -all:all {edger_name(imagepath)}"), stdout = TRUE)

} # End of function
