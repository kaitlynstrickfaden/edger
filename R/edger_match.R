

#' Find the Pixels to be Recolored in a Raw Image
#'
#' Identify pixels that are contour pixels in the raw image to be recolored later. Optionally shift and/or rotate the pixels that are recolored.
#'
#' @importFrom dplyr distinct filter mutate rename
#' @import grDevices
#' @import imager
#' @importFrom rlang .data
#' @param imdf A data frame of the raw image. The data frame must contain a column with unique identifiers for each pixel. See edger_im_to_df.
#' @param roi A data frame containing the locations of the contour pixels in the region of interest. See edger_define_roi.
#' @param shift A vector of length 2 containing numerics indicating the amount to shift the recolored pixels along the x axis first and the y axis second. Positive values indicate shifts right or up, while negative values indicate shifts left or down. Default is no shift.
#' @param rotate A numeric indicating the number of degrees to rotate the recolored pixels. Pixels are rotated around the center of the contour pixels.
#' @return The input data frame as an image.
#' @export


edger_match <- function(imdf,
                     roi,
                     shift = c(0,0),
                     rotate = 0
                     )
  {

  x_shift <- shift[1]
  y_shift <- -shift[2]
  dim_x <- max(imdf$x)
  dim_y <- max(imdf$y)

  m_df <- imdf[match(roi$id, imdf$id),]

  theta <- rotate * (pi/180)
  x_aor <- round(mean(c(max(m_df$x),min(m_df$x))),0)
  #x_aor <- round(dim_x/2,0)
  y_aor <- round(mean(c(max(m_df$y),min(m_df$y))),0)
  #y_aor <- round(dim_y/2,0)

  colnames(m_df) <- paste0(colnames(m_df), "old")

  m_df1 <- m_df %>%
    mutate(xorigin = .data$xold - x_aor,
           yorigin = .data$yold - y_aor,
           xprime = round((.data$xorigin*cos(theta)) - (.data$yorigin*sin(theta)), 0),
           yprime = round((.data$yorigin*cos(theta)) + (.data$xorigin*sin(theta)), 0),
           x = .data$xprime + x_aor,
           y = .data$yprime + y_aor,
           id = .data$x + ((.data$y - 1) * dim_x)
           )

  m_df2 <- m_df1 %>%
    mutate(keep = case_when(.data$x + x_shift > dim_x ~ "N",
                            .data$x + x_shift < 0 ~ "N",
                            .data$y + y_shift > dim_y ~ "N",
                            .data$y + y_shift < 0 ~ "N",
                            T ~ "Y") ) %>%
    filter(keep == "Y")

  m <- m_df2$id + x_shift + (y_shift * dim_x)

  return(m)

}
