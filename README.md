# contourr
This package allows the user to find the contours (edges) in one image and apply those contours to other images.

### Prerequisites

This package relies heavily on the package `imager`. The webpage for `imager` can be viewed [here](http://dahtah.github.io/imager/), and the GitHub page can be viewed [here](https://github.com/dahtah/imager). You also need `dplyr`, `progressr`, and`stringr`. 

```

install.packages(c("devtools", "dplyr", "imager", "progressr", "stringr"))

```

### Installing

When installing `contourr`, specify `build_vignettes = TRUE`.

```
devtools::install_github("kaitlynstrickfaden/contourr", build_vignettes = TRUE)
library(contourr)
```

## Functions

There are three main functions in the `contourr` package. These are:

* `ct_find`: a function for finding and recoloring contours in a single image, with the option to save the recolored image. 
* `ct_apply`: a function for applying contours to a new set of images. This function builds on the `ct_find` function by applying the contours found in one image to a new set of images. It also saves the recolored images with "contourr" appended to the original file name.
* `ct_roi`: an interactive function to help you find the right contour values for a series of input images. The drawn region(s) of interest and contour values are compiled and output as a list to then be used as inputs to the `ct_apply` function.

The rest of the functions in the package are helper functions that feed into the main wrapper functions.



For a detailed description of the methodology behind the functions, refer to the `contourr_methodology` [vignette](https://github.com/kaitlynstrickfaden/contourr/blob/master/vignettes/contourr_methodology.md). For a detailed description of the functions in the package, refer to the `contourr_use` [vignette](https://github.com/kaitlynstrickfaden/contourr/blob/master/vignettes/contourr_use.md). 

## Important Notes

* The method behind these functions relies on good contrast between the object you want to extract and the background. If your images are overexposed or underexposed, or if the object is the same color as the background, then the functions might not work.
* For the functions to work as intended, all of your images must be the same size. Your newly-saved files will be the same size as the original files.
* Recolored images will have "contourr" added at the end of the file name - the package will not overwrite your raw images.
* When the images are recolored, they no longer have their metadata. I personally used the `exiftoolr` package to extract the metadata I needed from the raw images. Then you can use one of `dplyr`'s `join` functions to associate the metadata with the correct image. I'm hoping to integrate `exiftoolr` into the `contourr` package to cut this step out for the user.

## Contributing

This package is still in development, so I'd love to hear from folks what other things they'd like to see this package do.

## Authors

* **Kaitlyn Strickfaden** - *Initial work* - [kaitlynstrickfaden](https://github.com/kaitlynstrickfaden)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Huge thanks to the developers of `imager`, Simon Barthelme, David Tschumperle, Jan Wijffels, and Haz Edine.
