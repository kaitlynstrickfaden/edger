edger\_methodology
================
Kaitlyn Strickfaden
2021-11-18

<br>

<br>

# The Virtual Snow Stake

The `edger` package provides a simple method for extracting the outlines
of an object of interest in one image and overlaying the same outlines
onto new images. This vignette is a step-by-step description of the
methodology. For a detailed description of the functions available in
the package right now, refer to the `edger` use
[vignette](https://github.com/kaitlynstrickfaden/edger/blob/master/vignettes/edger_use.md).

<br>

It’s really important that the object you want to extract contrasts with
the background. If the image is overexposed or underexposed, or if the
object is a similar color to the background, the method described below
won’t work quite as well.

<br>

------------------------------------------------------------------------

<br>

## Methodology

<br>

This code uses the package `imager`, which is one of few image
processing packages in R. This particular package has some handy
built-in functions that we will be using to save a little time and
computing power.

<br>

Let’s take a look at an image using `imager`’s “load.image” function.
I’ll also convert it into a data frame and give each pixel a unique
index to make it easier to manipulate later.

<br>

``` r
im1 <- load.image("../images/image01.jpg")
im1_df <- as.data.frame(im1)
im1_df$id <- rep(1:(dim(im1)[1] * dim(im1)[2]), times = 3)
plot(im1)
```

![](edger_methodology_files/figure-gfm/load%20image%201-1.png)<!-- -->

<br>

A color image is the combined result of three layers of pixels, one
layer each for red, green, and blue shades, which are plotted below for
reference. R “plots” an image by assigning a combination of red, green,
and blue values to each pixel coordinate, with indexing starting in the
upper left-hand corner. This image is 1040 pixels wide and 790 pixels
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

![](edger_methodology_files/figure-gfm/rgb%20image-1.png)<!-- --> <br>

Color images can be converted to grayscale. There are many ways to
convert a color image to grayscale, but `imager` converts the luminance
(brightness) of a pixel into a shade of gray. Let’s see what that looks
like for our image:

<br>

``` r
plot(grayscale(im1), axes = F)
```

![](edger_methodology_files/figure-gfm/grayscale%20image%201-1.png)<!-- -->

<br>

Now we have a black and white version of our image. This is the image
from which we will extract edges.

<br>

The `imgradient` function in `imager` compares the value of one pixel to
the values of the pixels immediately around it. Greater differences
between neighboring pixels will give a pixel a larger gradient value,
while weaker differences will give a smaller gradient value. Images have
x gradients and y gradients, which, separately, look like this:

<br>

``` r
par(mar = c(1,.1,1,.1))
im1_xy <- imgradient(grayscale(im1), "xy")
plot(im1_xy, layout = "row", axes = F)
```

![](edger_methodology_files/figure-gfm/xy%20edges-1.png)<!-- -->

<br>

Next, we’ll find the distance between the values in the x gradient plot
and the values in the y gradient plot at each pixel coordinate. When a
pixel is an edge, there is a greater distance between the x and y
gradient values. Normalizing these distances lets us give greater weight
to places in the image where there are edges. `imager` has a function
called `enorm` which does these calculations for us. When we find the
distances between the pixels in the x and y gradient plots, the result
is a single image which looks like this:

<br>

``` r
im1_gr <- enorm(imgradient(grayscale(im1),"xy"))
im1_bw <- as.data.frame(im1_gr)
im1_bw$id <- 1:length(im1_bw$x) 
plot(im1_gr, axes = F)
```

![](edger_methodology_files/figure-gfm/edge%20image-1.png)<!-- -->

<br>

This is the image upon which this methodology stands. Love it, respect
it, cherish it.

<br>

We’ll also save it as a data frame, because we’ll need it later.

<br>

------------------------------------------------------------------------

<br>

## Define a Region of Interest

<br>

We don’t necessarily want to find *every* edge in an image; in my case,
I only want the edges of the measuring stake. Fortunately, `imager` has
functions that allow you to output the coordinates of particular points,
lines, or rectangles that you draw on an image. This lets us limit our
search for edges to just a region we care about.

<br>

The package will allow you to either draw in a region of interest using
the “grabRect” function or define a region of interest in th call to the
functions. I define my region of interest…

<br>

``` r
#im_c <- grabRect(im1, output = "coord") # draw a box around the object of interest
im_c <- c(316,47,389,713)
plot(im1, axes = F)
rect(im_c[1], im_c[2], im_c[3], im_c[4], border = "cyan1")
```

![](edger_methodology_files/figure-gfm/rectangle%20grab-1.png)<!-- -->

<br>

And then filter out the pixels outside of this box so R isn’t dealing
with so much data.

``` r
roi <- filter(im1_bw,
              im1_bw$x >= im_c[1] & im1_bw$x <= im_c[3] &
              im1_bw$y >= im_c[2] & im1_bw$y <= im_c[4])
```

<br>

`edger_single` and `edger_multi` both allow you to set the number of
regions so you can define several regions of interest if you need.
`edger_multi` even lets you define regions in multiple images!

<br>

------------------------------------------------------------------------

<br>

## Highlight the Edges in an Image

<br>

This next code chunk will find the coordinates of the edges in the edge
image and recolor them in the original image. You must specify some edge
value as the minimum threshold to keep. By trial and error, I found that
0.1 was a good `th` for this image.

<br>

``` r
## Find edges in region of interest

roi_cv <- roi[roi$value >= .1,]

## Find edge pixels in full image

m1 <- im1_df$id[match(roi_cv$id, im1_df$id)]

## Recolor edge pixels in full image

rgbcolor <- col2rgb("cyan1")/255

im1_df$value[im1_df$id %in% m1] <- rep(rgbcolor, each = length(m1))
```

<br>

What’s the result?

<br>

``` r
im1_new <- as.cimg(im1_df, dim = dim(im1)) 
plot(im1_new, axes = F)
```

![](edger_methodology_files/figure-gfm/plot%20recolored%20image%201-1.png)<!-- -->

<br>

Cool! Now we have the original image with the edges of the measuring
stake highlighted. We also know the coordinates of those pixels. Of
course, this in itself isn’t all that useful; we already know where the
measuring stake is in this image. But by extracting edges from this
image and then saving the coordinates, we can now recolor those same
pixels in new images.

<br>

So what happens if the image you have doesn’t have ideal lighting
conditions?

<br>

![](edger_methodology_files/figure-gfm/load%20image%202-1.png)<!-- -->

![](edger_methodology_files/figure-gfm/edge%20image%202-1.png)<!-- -->
<br>

When the image is over- or under-exposed, you’ll probably have a much
harder time finding a threshold value that gives you good results.

<br>

If we instead use the edges from the first image, then we get much
better results:

<br>

![](edger_methodology_files/figure-gfm/recolor%20image%202-1.png)<!-- -->

------------------------------------------------------------------------

<br>

## Other Applications

<br>

This package, or at least this methodology, will likely be useful for
many camera applications which require some reference object. For
instance, someone who was interested in being able to measure how far
away animals are from cameras might be able to overlay a grid onto
images. Or, someone who was interested in measuring the animals
themselves might be able to use a similar method to mine.

<br>
