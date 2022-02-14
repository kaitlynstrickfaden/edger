

#' Extract and Reattribute Metadata
#'
#' Attribute metadata from original images to recolored images. Doesn't work yet...
#'
#' @import exiftoolr
#' @import stringr
#' @param imagepaths The file path to the original image
#' @param tags The Exiftool tags for metadata to extract. The default is all tags.
#' @return Metadata attributed to the recolored images.
#' @export


edger_meta <- function(imagepaths, tags)

{

  st <- Sys.time()

  for (i in seq_along(imagepaths)) {

    # Check if file paths are valid
    if (file.exists(imagepaths[i]) == FALSE) {
      stop(str_glue("{imagepaths[i]} is not a valid path.", sep = "")) }

    meta <- exif_read(imagepaths[i])

    if ("DateTimeOriginal" %in% colnames(meta)) {
      meta$DateTimeOriginal <- str_replace_all(meta$DateTimeOriginal, " ", "_")
    }

    if ("CreateDate" %in% colnames(meta)) {
      meta$CreateDate <- str_replace_all(meta$CreateDate, " ", "_")
    }

    metavals <- str_c("-", colnames(meta), "=", meta[1,], sep = "")

    exif_call(args =  c("-n", "-j", "-q", metavals[-c(1:3)]),
                  path = edger_name(imagepaths[i]), quiet = F)

}

  round(Sys.time() - st, 2)

} # End of function
