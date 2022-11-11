

#' Extract and Reattribute Metadata
#'
#' Attribute metadata from original image to recolored image. Requires that ExifTool is installed on your machine and is in your environmental variables.
#'
#' @importFrom stringr str_glue
#' @param imagepath The file path to the original image. Original and recolored image must be in the same directory.
#' @return Recolored image with metadata tags from original image
#' @export


edger_meta <- function(imagepath) {

  # Check if ExifTool is installed
  if (invisible(system2("where", "exiftool", stdout = NULL, stderr = NULL)) == 1) {
    stop("Could not find installation of ExifTool.")
  }

  # Check if file path is valid
  if (file.exists(imagepath) == FALSE) {
    stop(str_glue("{imagepath} is not a valid path.", sep = "")) }

  invisible(system2("exiftool", str_glue("-exif:all= -tagsfromfile {imagepath} -all:all -overwrite_original {edger_name(imagepath)}"), stdout = NULL, stderr = NULL))
  invisible(system2("exiftool", str_glue("-delete_original! {edger_name(imagepath)}"),
                    stdout = NULL, stderr = NULL))

} # End of function
