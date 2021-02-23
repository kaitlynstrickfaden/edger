contourr\_use
================
Kaitlyn Strickfaden
2021-02-23

<br>

<br>

# Using the *contourr* Package

The `contourr` package provides a simple method for extracting the
outlines of an object of interest in one image and overlaying the same
outlines onto new images. This vignette describes the various functions
and how to use them. For a detailed description of the methodology
behind the functions, refer to the `contourr` methodology
[vignette](https://github.com/kaitlynstrickfaden/contourr/blob/master/vignettes/contourr_methodology.md).

<br>

It’s really important that the object you want to extract contrasts with
the background. If the image is overexposed or underexposed, or if the
object is a similar color to the background, the methods described below
won’t work quite as well.

## Functions

<br>

Right now, this package includes three functions:

  - `ct_find`: find and recolor outlines in just one image, with the
    option to save the output image. Useful for tinkering with contour
    values until you find the right one for your image.
  - `ct_cvdf`: an interactive function to help you find the right
    contour values for multiple images and then save those contour
    values in a data frame.
  - `ct_overlay`: find and recolor outlines in one image, then overlay
    those outlines onto a set of other images.

<br>

-----

<br>

## ct\_find

At its very simplest, the `ct_find` function takes the file path to an
image as an input, asks the user to either draw or input a region of
interest (**ROI**), and outputs a new image with the contours in that
ROI recolored. There are a few other arguments to allow for more
customization though. These are:

<br>

  - `contour_value`: a numeric input setting the threshold value for
    determining contours. Generally, this is a value greater than 0 and
    less than 0.20. Lower values capture weaker contours, and higher
    values capture stronger contours. The default is 0.10.
  - `roi_in`: an argument for supplying the coordinates of ROI’s without
    having to draw them each time. The default is NULL and will cause
    the function to launch the user interface for drawing a ROI on the
    image. If the user decides to input a ROI, it must be input as a
    data frame with 4 columns containing the coordinates to the top-left
    corner and the bottom-right corner of the ROI. Each ROI will be in
    its own row of the data frame.
  - `color`: a character string for the desired color of the recolored
    pixels. The default is red, but that may not be a preferred color in
    all contexts.
  - `regions`: a numeric input for setting the number of ROI’s to draw.
    The default is 1. If a user has multiple objects in an image but
    does not want to capture the area between the objects, he or she can
    increase the value of `regions` to capture each object separately.
  - `save`: a Boolean (T/F) indicating if the recolored image should be
    saved. The default is False, but if it is set to True, the recolored
    image will be saved to the working directory with "\_contourr"
    appended to the original file name.

<br>

Let’s see the `ct_find` function in action. First we’ll load in a file
path to a raw image:

<br>

``` r
im1 <- "../images/image03.jpg"
par(mar = c(0,0,0,0))
plot(imager::load.image(im1), axes = F)
```

![](contourr_use_files/figure-gfm/load%20image%201-1.png)<!-- -->

<br>

If we provide this file path to the `ct_find` function, this is the
result:

<br>

``` r
contourr::ct_find(im1)
```

![](contourr_use_files/figure-gfm/ct_find%20function%20edited%20for%20Markdown%201-1.png)<!-- -->

    #> Time difference of 2.86 secs

<br>

Note also that the `ct_find` function outputs the amount of time it took
for the function to run.

<br>

A contour value of 0.10 looks pretty good for this image, but let’s
adjust some of the inputs and try again just to see what happens. We’ll
also set the ROI externally. When `imager` plots an image, it starts by
plotting the top-left corner and then working its way right and then
*down*, so it’s a bit different from normal plotting convention. But if
you use `imager`’s `grabRect` function, it will output those coordinates
correctly.

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
contourr::ct_find(im1, roi_in = roi1, contour_value = 0.07, color = "cyan1")
```

    #> Time difference of 2.36 secs

![](contourr_use_files/figure-gfm/ct_find%20function%20edited%20for%20Markdown%202-1.png)<!-- -->

<br>

Notice that by decreasing the `contour_value` input, we picked up some
weaker contours around the measuring stake.

<br>

If we wanted to recolor the contours of that second measuring stake too,
we can do that by increasing the `regions` input and adding another row
to our `roi_in` data frame.

<br>

``` r
roi2 <- data.frame(x1 = 457, y1 = 501, x2 = 526, y2 = 1105)
contourr::ct_find(im1, roi_in = rbind(roi1, roi2), regions = 2, color = "purple")
```

![](contourr_use_files/figure-gfm/ct_find%20function%20edited%20for%20Markdown%203-1.png)<!-- -->

    #> Time difference of 2.69 secs

<br>

-----

<br>

## ct\_cvdf

The `ct_cvdf` (“contour value data frame”) function is an extension of
the `ct_find` function. Rather than input just a single file path, the
user can input a vector containing paths to multiple images to the
`imagepaths` argument. Just like the `ct_find` function, the `ct_cvdf`
function also takes a `color` argument. The `ct_cvdf` function launches
an interactive interface to the `ct_find` function. It will use the
default `contour_value` from the `ct_find` function (0.10) to recolor
contours on the first instance; then, the function will ask the user if
the `contour_value` used was a good value. If the user inputs “Y”, the
function will save that `contour_value` to a data frame and then move on
to the next imagepath in the vector. If the user inputs “N” (or any
other value), the interface will ask for a new `contour_value` and rerun
the `ct_find` function. Once the function has gotten through all of the
images in `imagepaths`, the `ct_cvdf` function will output the data
frame of contour values chosen by the user.

<br>

Eventually, I hope to integrate the `ct_cvdf` function with the
`ct_overlay` function described below so that `ct_overlay` can be
automated even more. I haven’t quite gotten around to that yet though.
Stay tuned\!

<br>

-----

<br>

## ct\_overlay

<br>

The final function, the `ct_overlay` function, is the workhorse of the
`contourr` package. It allows the user to take the contours he or she
found in one image and recolor those same (or similar) pixels in a new
set of images. It will save the recolored images with "\_contourr"
appended to the original file name, so you won’t lose any of your raw
images. These are the arguments for the `ct_overlay` function:

  - `images`: a vector containing file paths to images. The default is
    1. The first image is referred to as the “reference” image; this is
    the image in which contours will be found that will then be drawn on
    to the rest of the images. If `ref_images` is greater than 1, then
    the function will use *n* images as the reference images.
  - `ref_images`: a numeric input for the number of reference images to
    be used.
  - `roi_in`: an argument for supplying the coordinates of ROI’s without
    having to draw them each time. There are three possible types of
    inputs depending on other inputs to the function. These are:
      - `NULL` (default): will launch the user interface for drawing a
        ROI on the image.
      - `ref_images` = 1: a data frame with 4 columns containing the
        coordinates to the top-left corner and the bottom-right corner
        of the ROI. Each ROI should be in its own row of the data frame.
      - `ref_images` \> 1: a list of data frames, and the number of
        items in the list should be equal to the value of `ref_images`.
        Each item in the list should be a data frame with 4 columns
        containing the coordinates to the top-left corner and the
        bottom-right corner of the ROI for each reference image. Each
        ROI should be in its own row of the data frame.
  - `contour_value`: a numeric input setting the threshold value for
    determining contours. Generally, this is a value greater than 0 and
    less than 0.20. Lower values capture weaker contours, and higher
    values capture stronger contours. The default is 0.10.
  - `color`: a character string for the desired color of the recolored
    pixels. The default is red, but that may not be a preferred color in
    all contexts.
  - `regions`: a numeric input for setting the number of ROI’s to draw.
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

<br>

It looks like a lot of inputs, but most of them are the same as the
arguments for `ct_find`.

<br>

Let’s load in a few more images:

<br>

``` r
im2 <- "../images/image04.jpg"
im3 <- "../images/image05.jpg"
```

<br>

First, we’ll just run the `ct_overlay` function without setting any of
the new arguments (`shift` or `ref_images`).

<br>

``` r
roi1 <- data.frame(x1 = 894, y1 = 538, x2 = 974, y2 = 1219)
contourr::ct_overlay(c(im1, im2), roi_in = roi1, color = "green1")
```

![](contourr_use_files/figure-gfm/ct_overlay%20function%20edited%20for%20Markdown%201-1.png)<!-- -->

    #>  recoloring image 2 of 2  [===========================]  100%  elapsed: 00:00:03

![](contourr_use_files/figure-gfm/ct_overlay%20function%20edited%20for%20Markdown%201-2.png)<!-- -->

<br>

This function comes with a progress bar, courtesy of the `progress`
package. The progress bar tells the user which image the function is
currently recoloring, how many total images it has to recolor, a percent
completion, and an elapsed time.

<br>

Now let’s shift the recolored pixels. The `shift` input acts like a
coordinate pair where the first value is for the x shift and the second
value is for the y shift. Positive values are for shift right or up, and
negative values are for shifts left or down. Let’s shift the recolored
pixels 200 to the right and 200 down.

<br>

``` r
contourr::ct_overlay(c(im1, im2), roi_in = roi1, 
                     shift = c(200, -200), color = "orangered2")
```

![](contourr_use_files/figure-gfm/ct_overlay%20function%20edited%20for%20Markdown%202-1.png)<!-- -->

    #>  recoloring image 2 of 2  [===========================]  100%  elapsed: 00:00:03

![](contourr_use_files/figure-gfm/ct_overlay%20function%20edited%20for%20Markdown%202-2.png)<!-- -->

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
roi3 <- data.frame(x1 = 1687, y1 = 66, x2 = 1761, y2 = 1219)

contourr::ct_overlay(c(im1, im2), 
                     ref_images = 2, roi_in = list(roi1, roi3), 
                     color = "deeppink1")
```

![](contourr_use_files/figure-gfm/ct_overlay%20function%20edited%20for%20Markdown%203-1.png)<!-- -->

    #>  recoloring image 2 of 2  [===========================]  100%  elapsed: 00:00:03

![](contourr_use_files/figure-gfm/ct_overlay%20function%20edited%20for%20Markdown%203-2.png)<!-- -->

<br>

Cool\! Now we’ve drawn the measuring stake from the second image onto
the first image, and we’ve drawn the measuring stake from the first
image onto the second image. This functionality is useful if you have
multiple objects of interest but they don’t all appear in the same
image.

<br>

A couple of other tips:

  - Base R’s `list.files` function is very handy for creating a vector
    of file paths to set as the `images` argument.
  - It’s best to change your working directory to the directory
    containing your image files since the `ct_overlay` function just
    places the recolored images in your working directory. If you have
    images spread across multiple cameras, but the image names repeat,
    then you’ll end up overwriting recolored images.
  - Unfortunately, this recoloring process does **not** retain the
    images’ metadata. Future iterations of this package may extract
    metadata from the raw image and attribute it to the recolored one
    during recoloring. For now, please refer to the `exiftoolr`
    [package](https://github.com/JoshOBrien/exiftoolr%5D) for extracting
    metadata from your raw images.

<br>
