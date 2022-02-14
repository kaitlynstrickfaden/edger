
#' Interactively Choose Thresholds, Shift, and Rotation
#'
#' An interactive function for locating pixels corresponding to edges in multiple regions and multiple photos. If the default threshold value (0.1) does not display desired contours, input "N" when prompted to input a new threshold value and redisplay. Repeat as necessary until it is satisfactory, then input "Y". Do the same procedure for shift and rotation. The drawn region(s) of interest, threshold values, shifts, and rotations will be output as a list.
#'
#' @importFrom graphics par plot
#' @importFrom stringr str_glue
#' @import dplyr
#' @import grDevices
#' @import imager
#' @param imagepaths A vector containing file paths of images to be analyzed.
#' @param regions A numeric indicating how many regions to draw. Default is 1.
#' @param color A character string for the color of the superimposed object. Default is red.
#' @return A list of coordinates to region(s) of interest, edge values, shifts, and rotations for each image. The roi and shift list items are output as lists, while th and rotate are output as vectors.
#' @export



edger_testr <- function(imagepaths, regions = 1, color = "red") {


  if (is.vector(imagepaths) == FALSE | is.character(imagepaths) == FALSE) {
    stop("'imagepaths' must be a character vector")
  }


  roi <- list()
  th <- c()
  sh <- list()
  ro <- c()


  for (j in seq_along(imagepaths)) {

    refimage <- imagepaths[j]

    if (file.exists(refimage) == FALSE) {
      stop(str_glue("imagepaths[", j, "] is not a valid path.", sep = "")) }


    roi_d <- data.frame()

    for (i in 1:regions) {

      thdone <- FALSE
      tv <- .1

      shdone <- FALSE
      shf <- c(0,0)

      rodone <- FALSE
      rot <- 0

      roi_in <- grabRect(imager::load.image(refimage), output = "coord")
      roi_in <- data.frame(x0 = roi_in[1], y0 = roi_in[2],
                           x1 = roi_in[3], y1 = roi_in[4])

      edger_single(refimage,
              roi = list(roi_in),
              th = tv,
              shift = shf,
              rotate = rot,
              regions = regions,
              color = color)

      while (thdone == FALSE) {

        interactive()

        x <- readline(prompt = "Is this a good threshold value? Input Y for yes or N for no: ")

        if (x == "Y") {
          roi_d <- rbind(roi_d, roi_in)
          th <- c(th, tv)
          thdone <- TRUE
        }

        if (x != "Y") {

          tvnew <- readline(prompt = str_glue("Current threshold value: {tv}  Input new threshold value: "))

          while (suppressWarnings(is.na(as.numeric(tvnew))) == TRUE |
                 suppressWarnings(as.numeric(tvnew)) <= 0) {
            tvnew <- readline(prompt = str_glue("Not a valid input. Please input a non-zero number.  Current threshold value: {tv}  Input new threshold value: "))

          }

          tv <- as.numeric(tvnew)

          edger_single(refimage, roi = list(roi_in),
                  th = tv, color = color)
          thdone <- FALSE
        }

        } # end of th while loop



      while (rodone == FALSE) {

        interactive()

        x <- readline(prompt = "Is this a good rotation value? Input Y for yes or N for no: ")

        if (x == "Y") {
          ro <- c(ro, rot)
          rodone <- TRUE
        }

        if (x != "Y") {

          ronew <- readline(prompt = str_glue("Current rotation value: {rot}  Input new threshold value: "))

          while (suppressWarnings(is.na(as.numeric(ronew))) == TRUE) {
            ronew <- readline(prompt = str_glue("Not a valid input. Please input a number.  Current threshold value: {rot}  Input new threshold value: "))

          }

          rot <- as.numeric(ronew)

          edger_single(refimage, roi = list(roi_in),
                     th = tv, shift = shf, rotate = rot, color = color)
          rodone <- FALSE
        }

      } # end of ro while loop


      while (shdone == FALSE) {

        interactive()

        x <- readline(prompt = "Is this a good shift value? Input Y for yes or N for no: ")

        if (x == "Y") {
          shdone <- TRUE
        }

        if (x != "Y") {

          # x shift

          xnew <- readline(prompt = str_glue("Current x shift: {shf[1]}  Input new x shift: "))

          while (suppressWarnings(is.na(as.numeric(xnew))) == TRUE) {
            xnew <- readline(prompt = str_glue("Not a valid input. Please input a number.  Current x shift: {shf[1]}  Input new x shift: "))

          }

          xsh <- round(as.numeric(xnew))
          shf[1] <- xsh

          # y shift

          ynew <- readline(prompt = str_glue("Current y shift: {shf[2]}  Input new y shift: "))

          while (suppressWarnings(is.na(as.numeric(ynew))) == TRUE) {
            ynew <- readline(prompt = str_glue("Not a valid input. Please input a number.  Current y shift: {shf[2]}  Input new y shift: "))

          }

          ysh <- round(as.numeric(ynew))
          shf[2] <- ysh

          edger_single(refimage, roi = list(roi_in),
                     th = tv, shift = shf, color = color)
          shdone <- FALSE
        }

      } # end of sh while loop



      } # end of regions loop

    roi[[j]] <- roi_d
    sh[[j]] <- shf
    ro[[j]] <- rot

  } # end of images loop

  return(list("roi" = roi,"th" = th, "shift" = sh, "rotate" = ro))

} # end of function


