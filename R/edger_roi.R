
#' Find Contour Values for Several Images
#'
#' An interactive function for locating pixels corresponding to edges in multiple regions and multiple photos. If the default contour value (0.1) does not display desired contours, input "N" when prompted to input a new contour value and redisplay. Repeat as necessary until it is satisfactory, then input "Y". The drawn region(s) of interest and contour values will be output as a list of lists, with one list per image.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_glue
#' @import dplyr
#' @import grDevices
#' @import imager
#' @param imagepaths A vector containing file paths of images to be analyzed.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @return A list of lists, with each list containing the image file path and a data frame of coordinates to region(s) of interest and contour values selected for that image.
#' @export



edger_roi <- function(imagepaths, regions = 1, color = "red") {


  if (is.vector(imagepaths) == FALSE | is.character(imagepaths) == FALSE) {
    stop("'imagepaths' must be a character vector")
  }


  roi <- list()
  th <- c()


  for (j in seq_along(imagepaths)) {

    refimage <- imagepaths[j]

    if (file.exists(refimage) == FALSE) {
      stop(str_glue("imagepaths[", j, "] is not a valid path.", sep = "")) }


    roi_d <- data.frame()

    for (i in 1:regions) {

      done <- FALSE
      tv <- .1

      roi_in <- grabRect(imager::load.image(refimage), output = "coord")
      roi_in <- data.frame(x0 = roi_in[1], y0 = roi_in[2],
                           x1 = roi_in[3], y1 = roi_in[4])

      edger_find(refimage,
              roi_in = list(roi_in),
              th = tv,
              regions = regions,
              color = color)

      while (done == FALSE) {

        interactive()

        x <- readline(prompt = "Is this a good threshold value? Input Y for yes or N for no: ")

        if (x == "Y") {
          roi_d <- rbind(roi_d, roi_in)
          th <- c(th, tv)
          done <- TRUE
        }

        if (x != "Y") {

          tvnew <- readline(prompt = str_glue("Current threshold value: {tv}  Input new threshold value: "))

          while (suppressWarnings(is.na(as.numeric(tvnew))) == TRUE |
                 suppressWarnings(as.numeric(tvnew)) <= 0) {
            tvnew <- readline(prompt = str_glue("Not a valid input. Please input a non-zero number.  Current threshold value: {tv}  Input new threshold value: "))

          }

          tv <- as.numeric(tvnew)

          edger_find(refimage, roi_in = list(roi_in),
                  th = tv, color = color)
          done <- FALSE
        }

        } # end of while loop

      } # end of regions loop

    roi[[j]] <- roi_d

  } # end of images loop

  return(list("roi" = roi,"th" = th))

} # end of function


