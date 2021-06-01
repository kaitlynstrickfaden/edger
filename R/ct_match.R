

#' Find the Pixels to be Recolored in a Raw Image
#'
#' Identify pixels that are contour pixels in the raw image to be recolored later. Optionally shift the pixels that are recolored.
#'
#' @importFrom dplyr distinct filter
#' @import grDevices
#' @import imager
#' @importFrom rlang .data
#' @param imdf A data frame of the raw image. The data frame must contain a column with unique identifiers for each pixels. See ct_im_to_df.
#' @param roi A data frame containing the locations of the region of interest. See ct_define_roi.
#' @param shift A vector of length 2 containing numerics indicating the amount of shift along the x axis first and the y axis second. Positive values indicate shifts right or up, while negative values indicate shifts left or down. Default is no shift.
#' @return The input data frame as an image.
#' @export


ct_match <- function(imdf,
                     roi,
                     shift = c(0,0)
                     )
  {

  x_shift <- shift[1]
  y_shift <- -shift[2]
  maxx <- max(imdf$x)
  maxy <- max(imdf$y)

  m_df <- imdf[match(roi$id, imdf$id),]
  m_df$keep <- "Y"

  m_df1 <- m_df %>%
    mutate(keep = case_when(x + x_shift > maxx ~ "N",
                            x + x_shift < 0 ~ "N",
                            y + y_shift > maxy ~ "N",
                            y + y_shift < 0 ~ "N",
                            T ~ "Y")
           ) %>%
    filter(.data$keep == "Y")

  m <- m_df1$id + x_shift + (y_shift * maxy)

  return(m)

}
