edger\_use
================
Kaitlyn Strickfaden
2021-07-07

<br>

<br>

# Using the *edger* Package

The `edger` package provides a simple method for extracting the outlines
of an object of interest in one image and superimposing the same
outlines onto new images. This vignette describes the various functions
and how to use them. For a detailed description of the methodology
behind the functions, refer to the `edger` methodology
[vignette](https://github.com/kaitlynstrickfaden/edger/blob/master/vignettes/edger_methodology.md).

<br>

It’s really important that the object you want to extract contrasts with
the background. If the image is overexposed or underexposed, or if the
object is a similar color to the background, the methods described below
won’t work quite as well.

## Functions

<br>

Right now, this package includes three functions:

  - `edger_roi`: an interactive function to extract coordinates for the
    region(s) of interest (ROI) and find appropriate threshold values.
    The coordinates and values are output in a format that can be used
    by `edger_find` and `edger_apply`.
  - `edger_find`: find and recolor outlines in just one image, with the
    option to save the output image. Useful for tinkering with threshold
    values until you find the right one for your image.
  - `edger_apply`: find and recolor outlines in one image, then
    superimpose those outlines onto a set of other images.

<br>

-----

<br>

## edger\_find

At its very simplest, the `edger_find` function takes the file path to
an image as an input, asks the user to either draw or input a region of
interest (**ROI**), and outputs a new image with the edges in that ROI
recolored. There are a few other arguments to allow for more
customization though. These are:

<br>

  - `th`: a numeric input setting the threshold value for determining
    edges. Generally, this is a value greater than 0 and less than 0.20.
    Lower values capture weaker edges, and higher values capture
    stronger edges. The default is 0.10.
  - `roi_in`: an argument for supplying the coordinates of ROIs without
    having to draw them each time. The default is NULL and will cause
    the function to launch the user interface for drawing a ROI on the
    image. If the user decides to input the ROI, it must be input as a
    list containing a data frame, and the data frame must contain the
    minimum x, minimum y, maximum x, and maximum y coordinate of the
    ROI. Each ROI must be in its own row of the data frame.
  - `color`: a character string for the desired color of the recolored
    pixels. The default is red, but that may not be a preferred color in
    all contexts.
  - `regions`: a numeric input for setting the number of ROIs to draw.
    The default is 1. If a user has multiple objects in an image but
    does not want to capture the area between the objects, he or she can
    increase the value of `regions` to capture each object separately.
  - `save`: a Boolean (T/F) indicating if the recolored image should be
    saved. The default is False, but if it is set to True, the recolored
    image will be saved to the working directory with "\_edger" appended
    to the original file name.

<br>

Let’s see the `edger_find` function in action. First we’ll load in a
file path to a raw image:

<br>

``` r
im1 <- "../images/image03.jpg"
par(mar = c(0,0,0,0))
plot(imager::load.image(im1), axes = F)
```

![](edger_use_files/figure-gfm/load%20image%201-1.png)<!-- -->

<br>

If we provide this file path to the `edger_find` function, this is the
result:

<br>

``` r
edger::edger_find(im1)
```

![](edger_use_files/figure-gfm/edger_find%201-1.png)<!-- -->

    #> Time difference of 4.45 secs

<br>

Note also that the `edger_find` function outputs the amount of time it
took for the function to run.

<br>

A threshold value of 0.10 looks pretty good for this image, but let’s
adjust some of the inputs and try again just to see what happens. We’ll
also set the ROI externally. When `imager` plots an image, it starts by
plotting the top-left corner and then working its way right and then
*down*, so it’s a bit different from normal plotting convention. But if
you use `imager`’s `grabRect` function, it will output those coordinates
correctly.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
edger::edger_find(im1, roi_in = list(roi1), th = 0.07, color = "cyan1")
```

    #> Time difference of 4.58 secs

![](edger_use_files/figure-gfm/edger_find%202-1.png)<!-- -->

<br>

Notice that by decreasing the `th` input, we picked up some weaker edges
around the measuring stake.

<br>

If we wanted to recolor the edges of that second measuring stake too, we
can do that by increasing the `regions` input and adding another row to
our `roi_in` data frame.

<br>

``` r
roi2 <- data.frame(x1 = 457, y1 = 501, x2 = 526, y2 = 1105)
edger::edger_find(im1, roi_in = list(rbind(roi1, roi2)), regions = 2, color = "purple")
```

![](edger_use_files/figure-gfm/edger_find%203-1.png)<!-- -->

    #> Time difference of 4.34 secs

<br>

-----

<br>

## edger\_roi

The `edger_roi` (“region of interest”) function is an extension of the
`edger_find` function. Rather than input just a single file path, the
user can input a vector containing paths to multiple images to the
`imagepaths` argument. The `edger_roi` function launches an interactive
interface to the `edger_find` function. It will use the default `th`
from the `edger_find` function (0.10) to recolor edges on the first
instance; then, the function will ask the user if the `th` used was a
good value. If the user inputs “Y”, the function will save the ROI
coordinates and `th` to a list of data frames and then move on to the
next imagepath in the vector. If the user inputs “N” (or any other
value), the interface will ask for a new `th` and rerun the `edger_find`
function. Once the function has gotten through all of the images in
`imagepaths`, the `edger_cvdf` function will output a list of data
frames containing coordinates to ROIs and threshold values.

<br>

-----

<br>

## edger\_apply

<br>

The final function, the `edger_apply` function, is the workhorse of the
`edger` package. It allows the user to take the edges he or she found in
one image and recolor those same (or similar) pixels in a new set of
images. It will save the recolored images with "\_edger" appended to the
original file name, so you won’t lose any of your raw images. These are
the arguments for the `edger_apply` function:

  - `images`: a vector containing file paths to images. The first image
    is referred to as the “reference” image; this is the image in which
    edges will be found that will then be drawn on to the rest of the
    images. If `ref_images` is greater than 1, then the function will
    use *n* images as the reference images.
  - `ref_images`: a numeric input for the number of reference images to
    be used. The default is one.
  - `roi_in`: an argument for supplying the coordinates of ROIs without
    having to draw them each time. The default is NULL and will cause
    the function to launch the user interface for drawing a ROI on the
    image. If the user decides to input the ROI, it must be input as a
    list containing a data frame for each reference image, and each data
    frame must contain the minimum x, minimum y, maximum x, and maximum
    y coordinate of the ROI. Each ROI must be in its own row of the data
    frame.
  - `th`: a numeric input setting the threshold value for determining
    edges. Generally, this is a value greater than 0 and less than 0.20.
    Lower values capture weaker edges, and higher values capture
    stronger edges. The default is 0.10.
  - `color`: a character string for the desired color of the recolored
    pixels. The default is red, but that may not be a preferred color in
    all contexts.
  - `regions`: a numeric input for setting the number of ROIs to draw.
    The default is 1. If a user has multiple objects in an image but
    does not want to capture the area between the objects, he or she can
    increase the value of `regions` to capture each object separately.
  - `shift`: a vector of length 2 for the number of pixels the drawn
    object should be moved left, right, up, or down. The first value in
    the pair will be the left-right shift, and the second value will be
    the up-down shift. The default is no shift (`c(0,0)`).
  - `show_image`: a Boolean (T/F) indicating if the images should be
    plotted after being recolored. The default is True. The function
    takes longer to run if `show_image` is True, but plotting images
    allows the user to diagnose issues with the recoloring.
  - `process`: a character input of either “sequential” or “parallel”
    indicating if the images should be processed on one core or many.
    The number of cores used is determined by the “cores” argument. The
    default is “sequential”.
  - `cores`: a numeric indicating how many cores on which to process
    images. The default is 1 (i.e. sequential).

<br>

It looks like a lot of inputs, but most of them are the same as the
arguments for `edger_find`.

<br>

Let’s load in a few more images:

<br>

``` r
im2 <- "../images/image04.jpg"
im3 <- "../images/image05.jpg"
```

<br>

First, we’ll just run the bare-bones `edger_apply` function.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
edger::edger_apply(c(im1, im2), roi_in = list(roi1), color = "green1")
```

![](edger_use_files/figure-gfm/edger_apply%201-1.png)<!-- -->![](edger_use_files/figure-gfm/edger_apply%201-2.png)<!-- -->

<br>

This function comes with a progress bar, courtesy of the `progressr`
package. The progress bar tells the user the percent of images it has
finished recoloring.

<br>

Now let’s shift the recolored pixels. The `shift` input acts like a
coordinate pair where the first value is for the x shift and the second
value is for the y shift. Positive values are for shifts right or up,
and negative values are for shifts left or down. Let’s shift the
recolored pixels 200 to the right and 200 down.

<br>

``` r
edger::edger_apply(c(im1, im2), roi_in = list(roi1), 
                     shift = c(200, -200), color = "orangered2")
```

![](edger_use_files/figure-gfm/edger_apply%202-1.png)<!-- -->![](edger_use_files/figure-gfm/edger_apply%202-2.png)<!-- -->

<br>

Hopefully you can see how this functionality will be very useful if the
camera viewshed changes partway through the camera’s deployment, though
it might take a little trial and error to figure out by how many pixels
to shift.

<br>

Now let’s use two reference images. Externally setting the ROI’s is a
bit more complicated when there is more than one reference image, but
the basic idea is that each image needs its own data frame of
coordinates to the ROI. Then each separate data frame gets added to a
list.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
roi3 <- data.frame(x1 = 633, y1 = 638, x2 = 874, y2 = 799)

edger::edger_apply(c(im1, im2), th = c(.1,.05),
                     ref_images = 2, roi_in = list(roi1, roi3), 
                     color = "deeppink1")
```

![](edger_use_files/figure-gfm/edger_apply%203-1.png)<!-- -->![](edger_use_files/figure-gfm/edger_apply%203-2.png)<!-- -->

<br>

Cool\! Now we’ve drawn the measuring stake from the first image onto the
second image, and we’ve drawn the outlines of that bent-down tree in the
second image onto the first image. This functionality is useful if you
have multiple objects of interest but they don’t all appear in the same
image.

<br>

### Parallel Processing

<br>

Most cameras are collecting a lot more than 2 images that you’ll have to
recolor. That can be a lot of processing time. You can speed things up
by setting the `process` argument of the `edger_apply` function to
“parallel.” This will call the `parallel` and `furrr` packages and
allow your computer to process the images across several cores. You’ll
also have to set the “cores” argument to the number of cores you want it
to use. You’ll want to use at least one less than the total number of
cores on your computer, which you can find out using
`parallel::detectCores()`.

<br>

<br>

A couple of other tips:

  - Base R’s `list.files` function is very handy for creating a vector
    of file paths to set as the `images` argument.
  - Unfortunately, this recoloring process does **not** retain the
    images’ metadata. Future iterations of this package may extract
    metadata from the raw image and attribute it to the recolored one
    during recoloring. For now, please refer to the `exiftoolr`
    [package](https://github.com/JoshOBrien/exiftoolr%5D) for extracting
    metadata from your raw images.

<br>