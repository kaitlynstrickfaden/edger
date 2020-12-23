
#' Find Contour Values for Several Images
#'
#' A user interface for locating pixels corresponding to edges in multiple photos. If the default contour value (0.1) is not satisfactory, input "N" when prompted to input a new contour value and redisplay. Repeat as necessary until it is satisfactory, then input "Y". The selected contour value will be saved to a data frame.
#'
#' @importFrom graphics par plot
#' @import dplyr
#' @import grDevices
#' @import imager
#' @param imagepaths A vector or data frame object containing the file paths to the images for analysis. If inputting a data frame, the data frame can have other columns if desired, but the file paths must be in a column called "File".
#' @return A data frame containing the file paths and selected contour values.
#' @export




ct_cvdf <- function(imagepaths) {


  if (is.vector(imagepaths)) {
    d <- data.frame(File = imagepaths, CV = 0)
  }

  if (is.data.frame(imagepaths)) {
    d <- imagepaths
    d$CV <- 0
  }

  if (is.vector(imagepaths) == FALSE & is.data.frame(imagepaths) == FALSE) {
    stop("'images' must be a vector or data frame object")
  }

  if ("File" %in% colnames(d) == F) {
    stop("input data frame must contain a column called 'File'")
  }


  for (i in seq_along(d$File)) {

    done <- FALSE
    refimage <- d$File[i]
    cv <- .1

    ct_find(refimage, contourvalue = cv)

    while (done == FALSE) {

      interactive()

      x <- readline(prompt = "Done? Input Y for yes or N for no: ")

      if (x == "Y") {
        d[i,"CV"] <- cv
        done <- TRUE
      }

      if (x != "Y") {
        cv <- as.numeric(readline(prompt = "Input new contour value: "))
        ct_find(refimage, contourvalue = cv)
        done <- FALSE
      }

    } # end of while loop

  } # end of for loop

  return(d)

} # end of function





