The Virtual Snow Stake Idea
===========================

<br>

In many natural resource fields, and particularly in wildlife studies, R
is the prevailing coding language. In the Python coding language, lots
of packages exist that allow a user to creatively manipulate and analyze
images to answer questions. Comparatively few packages exist to process
images in R; a quick search for “image processing” in Github turns up
6,766 repositories written in Python and a measly 97 written in R. Even
fewer take advantage of the properties of images to solve problems. This
code is my attempt to translate a common Python methodology into the R
language.

<br>

Wildlife biologists are moving towards using non-invasive methods to
study wildlife populations. Remote cameras are one such method that can
be placed almost anywhere, require little upkeep beyond the set-up and
take-down, and, when deployed without bias, allow biologists to estimate
wildlife population sizes in a study area. They are an increasingly
common and very powerful tool for informing wildlife management
decisions. But are there other questions, particularly habitat-related
questions, that researchers can begin to answer with cameras while they
are estimating population sizes? My current research interest is in
snow; specifically, I’m interested in whether cameras can be used to
measure snow depth. Cameras can be programmed to take pictures at time
intervals, giving me a snapshot of snow conditions at a camera site
every hour. They also record temperatures, an obviously useful metric
when thinking about snow.

<br>

Currently, snow researchers using cameras leave measuring stakes at the
camera site to measure snow. This is fine for snow research, but if the
hope is to measure snow and simultaneously collect images of animals, we
worry that leaving equipment in front of a camera will affect animal
movement, weakening our population inferences. We also worry that the
equipment will be tilted or knocked over, giving us no way to reliably
measure the snow. Finally, in some places, the extra field effort to
deploy snow-measuring equipment is just not cost-effective or feasible.

<br>

I set out to create what my research team and I have coined the *virtual
snow stake*. Since cameras are in a fixed location, I can take a single
picture of a measuring stake in a photo and then take advantage of some
of the properties of images to overlay the outline of the snow stake
onto subsequent photos. This allows me to measure snow in photos without
leaving any equipment at the camera site. In the following code, I will
describe the methodology in more detail and show it in action.

<br>

------------------------------------------------------------------------

<br>

Methodology
-----------

<br>

This code uses package “imager”, which is one of few image processing
packages in R. This particular package has some handy built-in functions
that we will be using to save a little time and computing power.

<br>

Let’s take a look at an image using imager’s “load.image” function.

<br>

    im1 <- load.image("../images/image01.jpg")
    plot(im1)

![](contourr_files/figure-markdown_strict/load%20image%201-1.png)

<br>

A color image is the combined result of three layers of pixels, one
layer each for red, green, and blue shades, which are plotted below for
reference. R “plots” an image by assigning a combination of red, green,
and blue values to each pixel coordinate, with indexing starting in the
upper left-hand corner. This image is 768 pixels wide and 512 pixels
high.

<br>

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

![](contourr_files/figure-markdown_strict/rgb%20image-1.png) <br>

Color images can be converted to grayscale. There are about a million
ways to convert a color image to grayscale, but imager converts the
luminance (brightness) of a pixel into a shade of gray. Let’s see what
that looks like for our image:

<br>

    plot(grayscale(im1), axes = F)

![](contourr_files/figure-markdown_strict/grayscale%20image%201-1.png)

<br>

Now we have a black and white version of our image. This is the image
from which we will extract contours.

<br>

A contour is just an edge in an image; the “imgradient” function in
imager compares the value of one pixel to the values of the pixels
immediately around it. Greater differences between neighboring pixels
will give a pixel a larger contour value, while weaker differences will
give a smaller contour value. Images have x contours and y contours,
which look like this:

<br>

    par(mar = c(.1,.1,.1,.1))
    im1xy <- imgradient(grayscale(im1), "xy")
    plot(im1xy, layout = "row", axes = F)

![](contourr_files/figure-markdown_strict/xy%20contours-1.png)

<br>

Next, we’ll find the Euclydian distance between the values in the x
contour plot and the values in the y contour plot. When either x or y
are a contour, there is a greater distance between the two values.
Normalizing these distances lets us give greater weight to places in the
image where there are contours. imager has a function called “enorm”
which does these calculations for us. When we find the x and y contours
in an image and then perform Euclydian normalization, the result is a
single image which looks like this:

<br>

    im1gr <- enorm(imgradient(grayscale(im1),"xy"))
    im1cont <- as.data.frame(im1gr)
    plot(im1gr)

![](contourr_files/figure-markdown_strict/contour%20image-1.png) <br>

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
case, I only want the contours of the snowstake. Fortunately, imager has
functions that allow you to output the coordinates of particular points,
lines, or rectangles that you draw on an image. This lets us limit our
search for contours to just a region we care about.

<br>

The package will allow you to draw your own region using the “grabRect”
function. However, this feature doesn’t play nicely with vignettes, so
I’ve defined a rectangle below. But if you’re viewing this code in
rMarkdown and are running it chunk-by-chunk, the grabRect function will
work.

<br>

    #imc <- grabRect(im1, output = "coord") # draw a box around the object of interest
    imc <- c(375,65,402,458)
    plot(im1, axes = F)
    rect(imc[1], imc[2], imc[3], imc[4], border = "red")

![](contourr_files/figure-markdown_strict/rectangle%20grab-1.png)

<br>

Later, we will want to know which particular pixels in the box are the
contours, so we’ll create variables to store that information.

<br>

    maskx <- NULL
    masky <- NULL

<br>

------------------------------------------------------------------------

<br>

Highlight the Contours in An Image
----------------------------------

<br>

This next code chunk will find the coordinates of the contours in the
contour image and recolor them in the original image. I went with red,
but you can pick any color you like by entering new RGB values on a
scale from 0-1 (red, for instance, is \[1,0,0\]). You must specify some
contour value as the minimum threshold to keep. By trial and error, I
found that 0.08 was a good threshold for this image.

<br>

    imnew <- im1

    for (x in imc[1]:imc[3]){ # within the box drawn before...
      for (y in imc[2]:imc[4]){
        pix <- data.frame(im1cont[which(im1cont$x == x & im1cont$y == y),])
        if (pix$value > .08) { # if the pixel is a contour... 
          imnew[x,y,1,] <- c(1,0,0) # change the pixel color to red
          maskx <- append(maskx, x) 
          masky <- append(masky, y) # and save the coordinates of that pixel
      } else {
          imnew[x,y,1,] <- im1[x,y,1,] # or else keep it the original color
          }
        }
    }

<br>

What’s the result?

<br>

    plot(imnew, axes = F)

![](contourr_files/figure-markdown_strict/plot%20recolored%20image%201-1.png)

<br>

Now we have the original image with the contours of the snowstake
highlighted. We also know the coordinates of those pixels. But this
itself is not that useful; we already know where the snowstake is in
this photo. Let’s apply this to a new photo.

<br>

We’ll load in a second image:

<br>

    im2 <- load.image("../images/image02.jpg")
    plot(im2, axes = F)

![](contourr_files/figure-markdown_strict/load%20image%202-1.png)

<br>

Then we’ll ask R to find the pixel coordinates in the second photo and
change them to red as well.

<br>

      for (j in 1:length(maskx)){
            im2[maskx[j], masky[j],1,] <- c(1,0,0)
      }
    plot(im2, axes = F)

![](contourr_files/figure-markdown_strict/recolor%20image%202-1.png)

<br>

Hooray! We’ve successfully found the snowstake in one image and overlaid
it onto a new image.

<br>

------------------------------------------------------------------------

<br>

Caveats
-------

<br>

Here’s one more example image:

![](contourr_files/figure-markdown_strict/image%203-1.png)

<br>

We know that the snow stake is here:

![](contourr_files/figure-markdown_strict/image%203%20snowstake-1.png)

<br>

However, since the photo is overexposed, the edges of the snow stake are
blurred and a lot of the contours are lost.

<br>

![](contourr_files/figure-markdown_strict/image%203%20contours-1.png)

<br>

When you run the contourfinder function on this image, this is the
result:

<br>

![](contourr_files/figure-markdown_strict/contourfinder%20image%203-1.png)

<br>

If I didn’t have those strips of bright tape at the 10 cm marks, then my
snow stake would be completely useless. So it is important than you have
at least one good image of the reference object in order for contourr to
be useful.

<br>

I can also imagine that vegetation, camera movement, and camera tilting
will be issues. However, this package is still in very early method
development, so I have no clue how big of an issue these problems will
be, nor do I know how I would go about fixing them. I will continue to
update this package and improve functionality as new issues arise.

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
they know where the measurements will be valid (e.g. we can accurately
measure a fisher that is within a meter of this particular tree, but if
it is more than a meter from this tree, the measurement may not be
valid).

<br>

Happy overlaying!

<br>
