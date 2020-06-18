<br>

<br>

The Virtual Snow Stake
======================

The `contourr` package provides a simple method for extracting the
outlines of an object of interest in one image and overlaying the same
outlines onto new images. This vignette is a step-by-step decription of
the methodology.

<br>

Right now, this package includes two functions:

-   `ct_find`: find and recolor outlines in just one image, with the
    option to save the output image. Useful for tinkering with contour
    values until you find the right one for your image.
-   `ct_overlay`: find and recolor outlines in one image, then overlay
    those outlines onto a set of other images.

<br>

It’s really important that the object you want to extract contrasts with
the background. If the image is overexposed or underexposed, or if the
object is a similar color to the background, the method described below
won’t work.

<br>

------------------------------------------------------------------------

<br>

Methodology
-----------

<br>

This code uses the package `imager`, which is one of few image
processing packages in R. This particular package has some handy
built-in functions that we will be using to save a little time and
computing power.

<br>

Let’s take a look at an image using `imager`’s “load.image” function.
I’ll also convert it into a dataframe and give each pixel a unique index
to make it easier to manipulate later.

<br>

``` r
im1 <- load.image("../images/image01.jpg")
im1_df <- as.data.frame(im1)
im1_df$id <- rep(1:(dim(im1)[1] * dim(im1)[2]), times = 3)
plot(im1)
```

![](contourr_files/figure-markdown_github/load%20image%201-1.png)

<br>

A color image is the combined result of three layers of pixels, one
layer each for red, green, and blue shades, which are plotted below for
reference. R “plots” an image by assigning a combination of red, green,
and blue values to each pixel coordinate, with indexing starting in the
upper left-hand corner. This image is 384 pixels wide and 256 pixels
high.

<br>

``` r
red <- im1
red[,,,c(2:3)] <- c(0,0)

green <- im1
green[,,,c(1,3)] <- c(0,0)

blue <- im1
blue[,,,1:2] <- c(0,0)

par(mfrow = c(1,3), mar = c(.1,.1,.1,.1))
plot(red, axes = F)
plot(green, axes = F)
plot(blue, axes = F)
```

![](contourr_files/figure-markdown_github/rgb%20image-1.png) <br>

Color images can be converted to grayscale. There are about a million
ways to convert a color image to grayscale, but `imager` converts the
luminance (brightness) of a pixel into a shade of gray. Let’s see what
that looks like for our image:

<br>

``` r
plot(grayscale(im1), axes = F)
```

![](contourr_files/figure-markdown_github/grayscale%20image%201-1.png)

<br>

Now we have a black and white version of our image. This is the image
from which we will extract contours.

<br>

A contour is just an edge in an image; the `imgradient` function in
`imager` compares the value of one pixel to the values of the pixels
immediately around it. Greater differences between neighboring pixels
will give a pixel a larger contour value, while weaker differences will
give a smaller contour value. Images have x contours and y contours,
which look like this:

<br>

``` r
par(mar = c(.1,.1,.1,.1))
im1_xy <- imgradient(grayscale(im1), "xy")
plot(im1_xy, layout = "row", axes = F)
```

![](contourr_files/figure-markdown_github/xy%20contours-1.png)

<br>

Next, we’ll find the distance between the values in the x contour plot
and the values in the y contour plot at each pixel coordinate. When
either x or y are a contour, there is a greater distance between the two
values. Normalizing these distances lets us give greater weight to
places in the image where there are contours. `imager` has a function
called `enorm` which does these calculations for us. When we find the
distances between the pixels in the x and y contour plots, the result is
a single image which looks like this:

<br>

``` r
im1_gr <- enorm(imgradient(grayscale(im1),"xy"))
im1_bw <- as.data.frame(im1_gr)
im1_bw$id <- 1:length(im1_bw$x) 
plot(im1_gr, axes = F)
```

![](contourr_files/figure-markdown_github/contour%20image-1.png)

<br>

This is the image upon which this methodology stands. Love it, respect
it, cherish it. Also, save it as a data frame, because we’ll need it
later.

<br>

------------------------------------------------------------------------

<br>

Define a Region of Interest
---------------------------

<br>

We don’t necessarily want to find *every* contour in an image; in my
case, I only want the contours of the measuring stake. Fortunately,
`imager` has functions that allow you to output the coordinates of
particular points, lines, or rectangles that you draw on an image. This
lets us limit our search for contours to just a region we care about.

<br>

The package will allow you to draw in a region of interest using the
“grabRect” function. I define my region of interest…

<br>

``` r
#im_c <- grabRect(im1, output = "coord") # draw a box around the object of interest
im_c <- c(187,30,202,229)
plot(im1, axes = F)
rect(im_c[1], im_c[2], im_c[3], im_c[4], border = "red")
```

![](contourr_files/figure-markdown_github/rectangle%20grab-1.png)

<br>

And then filter out the pixels outside of this box so R isn’t dealing
with so much data.

``` r
roi <- filter(im1_bw,
                   x >= im_c[1] & x <= im_c[3] &
                     y >= im_c[2] & y <= im_c[4])
```

<br>

`ct_find` and `ct_overlay` both allow you to set the number of regions
so you can define several regions of interest if you need.

<br>

------------------------------------------------------------------------

<br>

Highlight the Contours in An Image
----------------------------------

<br>

This next code chunk will find the coordinates of the contours in the
contour image and recolor them in the original image. You must specify
some contour value as the minimum threshold to keep. By trial and error,
I found that 0.1 was a good `contourvalue` for this image.

<br>

``` r
## Find contours in region of interest

roi_c <- roi[roi$value >= .1,]

## Find contour pixels in full image

m <- im1_df$id[match(roi_c$id, im1_df$id)]

## Recolor contour pixels in full image

rgbcolor <- col2rgb("red")/255

im1_df$value[im1_df$id %in% m] <- rep(rgbcolor, each = length(m))
```

<br>

What’s the result?

<br>

``` r
im1_new <- as.cimg(im1_df, dim = dim(im1)) 
plot(im1_new, axes = F)
```

![](contourr_files/figure-markdown_github/plot%20recolored%20image%201-1.png)

<br>

Now we have the original image with the contours of the snowstake
highlighted. We also know the coordinates of those pixels. But this
itself is not that useful; we already know where the stake is in this
photo. Let’s apply this to a new photo.

<br>

We’ll load in a second image:

<br>

``` r
im2 <- load.image("../images/image02.jpg")
im2_df <-as.data.frame(im2) 
im2_df$id <- 1:length(im1_bw$x)
plot(im2, axes = F)
```

![](contourr_files/figure-markdown_github/load%20image%202-1.png)

<br>

Then we’ll ask R to find the pixel coordinates in the second photo and
change them to red as well.

<br>

``` r
## Recolor contour pixels in full image

im2_df$value[im2_df$id %in% m] <- rep(rgbcolor, each = length(m))

im2_new <- as.cimg(im2_df, dim = dim(im2))
plot(im2_new)
```

![](contourr_files/figure-markdown_github/recolor%20image%202-1.png)

<br>

Hooray! We’ve successfully found the stake in one image and overlaid it
onto a new image. Notice that the stake is now inside the door rather
than on the floor. All the code does is remember the contour coordinates
from the reference image and recolor them in the new image. It’s not
smart enough (yet) to adjust the location of the stake if the camera
viewshed changes. Camera movement and tilting are issues I plan on
tackling eventually.

<br>

------------------------------------------------------------------------

<br>

Other Applications
------------------

<br>

This package, or at least this methodology, will likely be useful for
many camera applications which require some reference object. For
instance, someone who was interested in being able to measure how far
away animals are from cameras might be able to overlay a grid onto
images. Or, someone who was interested in measuring the animals
themselves might be able to use a similar method to mine, given that
they know where the measurements will be valid.

<br>

Happy overlaying!

<br>
