% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/edger_im_to_grad.R
\name{edger_im_to_grad}
\alias{edger_im_to_grad}
\title{Convert an Image Into a Gradient Image}
\usage{
edger_im_to_grad(cimage, show = FALSE)
}
\arguments{
\item{cimage}{An image to be converted.}

\item{show}{A Boolean indicating if the gradient image should be displayed. Default is FALSE.}
}
\value{
A data frame of image gradients with a column containing a unique identifier for each pixel in the image.
}
\description{
Convert an image into a data frame of image gradients using Canny edge detection. Optionally display the gradient data frame as an image.
}
