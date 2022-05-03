edger_use
================
Kaitlyn Strickfaden
2022-05-03

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

-   `edger_single`: find and recolor outlines in just one image, with
    the option to save the output image. Useful for tinkering with
    threshold values until you find the right one for your image.
-   `edger_testr`: an interactive function to extract coordinates for
    the region(s) of interest (ROI) and find appropriate threshold
    values. The coordinates and values are output in a format that can
    be used by `edger_single` and `edger_multi`.
-   `edger_multi`: find and recolor outlines in one image, then
    superimpose those outlines onto a set of other images.

<br>

------------------------------------------------------------------------

<br>

## edger_single

The `edger_single` function takes the file path to an image as an input,
asks the user to either draw or input a region of interest (**ROI**),
and outputs a new image with the edges in that ROI recolored. There are
a few other arguments to allow for more customization though. These are:

<br>

-   `th`: a numeric input between 1-100 that sets the threshold value
    for determining edges. Lower values capture weaker edges, and higher
    values capture stronger edges. The default is 20. This value is
    usually between 10-40.
-   `roi`: an argument for supplying the coordinates of ROIs without
    having to draw them each time. The default is NULL and will cause
    the function to launch the user interface for drawing a ROI on the
    image. If the user decides to input the ROI, it must be input as a
    list containing a data frame, and the data frame must contain the
    minimum x, minimum y, maximum x, and maximum y coordinate of the
    ROI. Each ROI must be in its own row of the data frame. It may seem
    weird that `roi` has to be a list of a single data frame, but this
    is just so the object type of `roi` is the same whether you have one
    ROI or several (as is possible with `edger_multi`).
-   `regions`: a numeric input for setting the number of ROIs to draw.
    The default is 1. If a user has multiple objects in an image but
    does not want to capture the area between the objects, he or she can
    increase the value of `regions` to capture each object separately.
-   `shift`: a vector of length 2 for the number of pixels the drawn
    object should be moved left, right, up, or down. The first value in
    the pair will be the left-right shift, and the second value will be
    the up-down shift. The default is no shift (`c(0,0)`).
-   `rotate`: a numeric indicating how many degrees to rotate the
    recolored pixels. Negative values rotate the pixels
    counter-clockwise, and positive values rotate the pixels clockwise.
    The default is 0.
-   `color`: a character string for the desired color of the recolored
    pixels. The default is red, but that may not be a preferred color in
    all contexts.
-   `save`: a Boolean (T/F) indicating if the recolored image should be
    saved. The default is False, but if it is set to True, the recolored
    image will be saved to the working directory with “\_edger” appended
    to the original file name.

<br>

Let’s see the `edger_single` function in action. First we’ll load in a
file path to a raw image:

<br>

``` r
im1 <- "../images/image03.jpg"
par(mar = c(0,0,0,0))
plot(imager::load.image(im1), axes = F)
```

![](edger_use_files/figure-gfm/load%20image%201-1.png)<!-- -->

<br>

If we provide this file path to the `edger_single` function, this is the
result:

<br>

``` r
edger::edger_single(im1)
```

![](edger_use_files/figure-gfm/edger_single%201-1.png)<!-- -->

    #> Time difference of 4.37 secs

<br>

Note also that the `edger_single` function outputs the amount of time it
took for the function to run.

<br>

A threshold value of 20 looks pretty good for this image, but let’s
adjust some of the inputs and try again just to see what happens. We’ll
also set the ROI externally. When `imager` plots an image, it starts by
plotting the top-left corner and then working its way right and then
*down*, so it’s a bit different from normal plotting convention. But if
you use `imager`’s `grabRect` function, it will output those coordinates
correctly.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
edger::edger_single(im1, roi = list(roi1), th = 10, color = "cyan1")
```

    #> Time difference of 3.97 secs

![](edger_use_files/figure-gfm/edger_single%202-1.png)<!-- -->

<br>

Notice that by decreasing the `th` input, we picked up some weaker edges
around the measuring stake.

<br>

If we wanted to recolor the edges of that second measuring stake too, we
can do that by increasing the `regions` input and adding another row to
our `roi` data frame.

<br>

``` r
roi2 <- data.frame(x1 = 457, y1 = 501, x2 = 526, y2 = 1105)
edger::edger_single(im1, roi = list(rbind(roi1, roi2)), regions = 2, color = "purple")
```

![](edger_use_files/figure-gfm/edger_single%203-1.png)<!-- -->

    #> Time difference of 3.98 secs

<br>

------------------------------------------------------------------------

<br>

## edger_testr

The `edger_testr` function is an extension of the `edger_single`
function. Rather than input just a single file path, the user can input
a vector containing paths to multiple images to the `imagepaths`
argument. The `edger_testr` function launches an interactive interface
to the `edger_single` function. It will use the default `th` from the
`edger_single` function (20) to recolor edges on the first instance;
then, the function will ask the user if the `th` used was a good value.
If the user inputs “Y”, the function will save the ROI coordinates and
`th` to a list of data frames. If the user inputs “N” (or any other
value), the interface will ask for a new `th` and rerun the
`edger_single` function. It will run this same procedure on the rotate
and shift inputs (default is no rotation or shift). It will move on to a
new image once a threshold, rotate, and shift value have been selected
for the current image. Once the function has gotten through all of the
images in `imagepaths`, the `edger_testr` function will output a list
containing coordinates to ROIs, threshold values, shift values, and
rotate values.

<br>

------------------------------------------------------------------------

<br>

## edger_multi

<br>

The final function, the `edger_multi` function, is the workhorse of the
`edger` package. It allows the user to take the edges he or she found in
one image and recolor those pixels in a new set of images with any
shifting or rotation as desired. It will save the recolored images with
“\_edger” appended to the original file name, so you won’t lose any of
your raw images. These are the arguments for the `edger_multi` function:

-   `images`: a vector containing file paths to images. The first image
    is referred to as the “reference” image; this is the image in which
    edges will be found that will then be drawn on to the rest of the
    images. If `ref_images` is greater than 1, then the function will
    use *n* images as the reference images.
-   `ref_images`: a numeric input for the number of reference images to
    be used. The default is one.
-   `roi`: an argument for supplying the coordinates of ROIs without
    having to draw them each time. The default is NULL and will cause
    the function to launch the user interface for drawing a ROI on the
    image. If the user decides to input the ROI, it must be input as a
    list containing a data frame for each reference image, and each data
    frame must contain the minimum x, minimum y, maximum x, and maximum
    y coordinate of the ROI. Each ROI must be in its own row of the data
    frame.
-   `th`: a numeric input between 1-100 that sets the threshold value
    for determining edges. Lower values capture weaker edges, and higher
    values capture stronger edges. The default is 20. This value is
    usually between 10-40.
-   `regions`: a numeric input for setting the number of ROIs to draw.
    The default is 1. If a user has multiple objects in an image but
    does not want to capture the area between the objects, he or she can
    increase the value of `regions` to capture each object separately.
-   `shift`: a vector of length 2 for the number of pixels the drawn
    object should be moved left, right, up, or down. The first value in
    the pair will be the left-right shift, and the second value will be
    the up-down shift. The default is no shift (`c(0,0)`).
-   `rotate`: a numeric indicating how many degrees to rotate the
    recolored pixels. Negative values rotate the pixels
    counter-clockwise, and positive values rotate the pixels clockwise.
    The default is 0.
-   `color`: a character string for the desired color of the recolored
    pixels. The default is red, but that may not be a preferred color in
    all contexts.
-   `show_image`: a Boolean (T/F) indicating if the images should be
    plotted after being recolored. The default is True. The function
    takes longer to run if `show_image` is True, but plotting images
    allows the user to diagnose issues with the recoloring.
-   `process`: a character input of either “sequential” or “parallel”
    indicating if the images should be processed on one core or many.
    The number of cores used is determined by the “cores” argument. The
    default is “sequential”.
-   `cores`: a numeric indicating how many cores on which to process
    images. The default is 1 (i.e. sequential).

<br>

It looks like a lot of inputs, but most of them are the same as the
arguments for `edger_single`.

<br>

Let’s load in a few more images:

<br>

``` r
im2 <- "../images/image04.jpg"
im3 <- "../images/image05.jpg"
```

<br>

First, we’ll just run the bare-bones `edger_multi` function.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
edger::edger_multi(c(im1, im2), roi = list(roi1), color = "green1")
#> Recoloring images...
```

![](edger_use_files/figure-gfm/edger_multi%201-1.png)<!-- -->

    #> Attributing metadata...

![](edger_use_files/figure-gfm/edger_multi%201-2.png)<!-- -->

    #> Time difference of 17.43226 secs

<br>

This function comes with a progress bar, courtesy of the `progressr`
package. The progress bar tells the user the percent of images it has
finished recoloring.

<br>

Now let’s shift and rotate the recolored pixels. The `shift` input acts
like a coordinate pair where the first value is for the x shift and the
second value is for the y shift. Positive values are for shifts right or
up, and negative values are for shifts left or down. The `rotate` input
is the number of degrees to rotate the pixels. Let’s shift the recolored
pixels 200 to the right and 200 down and then rotate them 30 degrees
clockwise.

<br>

``` r
edger::edger_multi(c(im1, im2), roi = list(roi1), 
                     shift = c(200, -200), rotate = 30, color = "yellow")
#> Recoloring images...
```

![](edger_use_files/figure-gfm/edger_multi%202-1.png)<!-- -->

    #> Attributing metadata...

![](edger_use_files/figure-gfm/edger_multi%202-2.png)<!-- -->

    #> Time difference of 17.41366 secs

<br>

Hopefully you can see how this functionality will be very useful if the
camera viewshed changes partway through the camera’s deployment. `edger`
won’t throw a fit if you shift or rotate any of the pixels outside of
the bounds of the image; it just won’t recolor them.

<br>

Now let’s use two reference images. Each reference image needs its own
data frame of coordinates to the ROI. Then each separate data frame gets
added to a list. If one reference images needs more regions drawn on it
than another, you can just set `regions` to the maximum number of
regions you want in any image. We’ll set `regions` to 2 and add a second
row to the data frame for the first image so we can capture both snow
stakes in the first image. But since we only have one row in the data
frame for the second image, there will only be one ROI in the second
image.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
roi2 <- data.frame(x1 = 457, y1 = 501, x2 = 526, y2 = 1105)
roi3 <- data.frame(x1 = 633, y1 = 638, x2 = 874, y2 = 799)

edger::edger_multi(c(im1, im2), th = c(20, 10),
                   ref_images = 2, regions = 2, 
                   roi = list(rbind(roi1, roi2),
                                 roi3), 
                   color = "deeppink1")
#> Recoloring images...
```

![](edger_use_files/figure-gfm/edger_multi%203-1.png)<!-- -->

    #> Attributing metadata...

![](edger_use_files/figure-gfm/edger_multi%203-2.png)<!-- -->

    #> Time difference of 22.86916 secs

<br>

Cool! Now we’ve drawn both snow stakes from the first image onto the
second image, and we’ve drawn the outlines of that bent-down tree in the
second image onto the first image. This functionality is useful if you
have multiple objects of interest but they don’t all appear in the same
image.

<br>

### Parallel Processing

<br>

Most cameras are collecting a lot more than 2 images that you’ll have to
recolor. That can be a lot of processing time. You can speed things up
by setting the `process` argument of the `edger_multi` function to
“parallel.” This will call the `parallel` and `furrr` packages and allow
your computer to process the images across several cores. You’ll also
have to set the `cores` argument to the number of cores you want it to
use. It’s generally safest to use at least one less than the total
number of cores on your computer, which you can find out using
`parallel::detectCores()`.

<br>
