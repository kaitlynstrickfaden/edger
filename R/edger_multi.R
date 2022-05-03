

#' Apply Edges to Images
#'
#' Find pixel coordinates of edges in defined regions of a reference image. Then, find and recolor the same pixels in new images.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_flatten str_glue str_split
#' @import dplyr
#' @import furrr
#' @import future
#' @import grDevices
#' @import imager
#' @import progressr
#' @import purrr
#' @param images A vector containing file paths of images to be analyzed. The first image will be the reference image, and edges from the first image will be superimposed onto the other images.
#' @param ref_images A numeric indicating in how many reference images you want to search for edges. Default is 1. When greater than 1, the first n images will be used.
#' @param roi An argument for delineating the region(s) of interest outside of the main function. Default is NULL and will launch a user interface so the user can draw a region(s) of interest on the image. If "roi" is not NULL, input should be a list containing 4-column data frames with a number of rows equal to regions, with one data frame per ref_images. The data frame needs to contain coordinates to the region(s) of interest in the following order: top-left x, top-left y, bottom-right x, bottom-right y. Note that plotting of images by "imager" starts in the top-left corner.
#' @param th A vector of numeric values between 1-100 for the lowest threshold value you want to recolor in each image(a low threshold value captures weaker contrasts). Default is 20.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param shift A vector of length 2 containing numerics indicating the amount of shift along the x axis first and the y axis second. Positive values indicate shifts right or up, while negative values indicate shifts left or down. Default is c(0,0).
#' @param rotate A numeric indicating the number of degrees to rotate the recolored pixels. Pixels are rotated around the center of the edge pixels. Default is 0.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @param show_image Logical. Plot images as they are recolored. Default is TRUE.
#' @param process One of "sequential" or "parallel" to indicate how images should be processed. Default is sequential. If "parallel", cores will also have to be set.
#' @param cores A numeric indicating how many cores to use in parallel processing. Safest is availableCores() - 1. Default is 1.
#' @return Recolored images. Saves recolored images to working directory with "_edger" appended to the original name.
#' @export




edger_multi <- function(images,
                        ref_images = 1,
                        roi = NULL,
                        th = 20,
                        regions = 1,
                        shift = c(0,0),
                        rotate = 0,
                        color = "red",
                        show_image = TRUE,
                        process = "sequential",
                        cores = 1)
{

  st <- Sys.time()


  # Check if ExifTool is installed
  if (invisible(system2("where", "exiftool")) == 1) {
    stop("Could not find installation of ExifTool.")
  }

  # Check if file paths are valid
  for (i in seq_along(images)) {
    if (file.exists(images[i]) == FALSE) {
      stop(str_glue("images[", i, "] is not a valid path.", sep = "")) }
  }

  # Check if ref_images matches with roi
  if (is.null(roi) == FALSE) {
    if (ref_images != length(roi)) {
      stop(str_glue("ref_images {ref_images} and length of roi {length(roi)} do not match."))
    }
  }

  # Check if color is a character
  if (is.character(color) == FALSE) {
    stop("color must be a character string.")
  }

  # Check if shift is a coordinate pair
  if (is.numeric(shift) == FALSE | length(shift) != 2) {
    stop("shift must be a numeric vector of length 2.")
  }

  # Check if threshold value is valid
  if (any(th <= 0)) {
    stop("th must be a vector of positive non-zero numbers.")
  }


  rgbcolor <- as.vector(grDevices::col2rgb(color)/255)

  ref_ims <- images[1:ref_images]

  ROI <- edger_identify(ref_ims = ref_ims,
                        roi = roi,
                        th = th,
                        regions = regions)


  im1 <- imager::load.image(images[1])
  im1_df <- edger_im_to_df(im1)

  m <- edger_match(imdf = im1_df,
                   roi = ROI,
                   shift = shift,
                   rotate = rotate)

  im1_new <- edger_recolor(imdf = im1_df,
                           m = m,
                           rgbcolor = rgbcolor,
                           show = TRUE)

  im1_newname <- edger_name(images[1])

  edger_save(im1_new, im1_newname)



  if (process == "sequential") {

    message("Recoloring images...")

    with_progress({
      p <- progressor(steps = length(images[-1]))

      purrr::map_chr(images[-1], ~{
        p()
        edger_overlay(.,
                      m = m,
                      rgbcolor = rgbcolor,
                      show_image = show_image)
      })

    })

  }

  if (process == "parallel") {

    plan(multisession, workers = cores)
    options(future.rng.onMisuse = "ignore")

    message("Recoloring images...")

    with_progress({
      p <- progressor(steps = length(images[-1]))

      furrr::future_map_chr(images[-1], ~{
        p()
        edger_overlay(.,
                      m = m,
                      rgbcolor = rgbcolor,
                      show_image = show_image)
      })

    })

  }

  message("Attributing metadata...")

  with_progress({
    p <- progressor(steps = length(images))

    purrr::map_chr(images, ~{
      p()
      edger_meta(.)
    })
  })

  Sys.time() - st

}
