# contourr
This package contains a few simple functions for finding an object in one image using its contours and overlaying its outline onto other images. 

### Prerequisites

This package relies heavily on the package `imager`. The webpage for `imager` can be viewed [here](http://dahtah.github.io/imager/), and the GitHub page can be viewed [here](https://github.com/dahtah/imager). You also need `dplyr`  and `stringr`. 

```

install_packages(c("devtools", "dplyr", "imager", "stringr"))

```

### Installing

When installing `contourr`, specify `build_vignettes = TRUE`.

```
devtools::install_github("kaitlynstrickfaden/contourr", build_vignettes = TRUE)
library(contourr)
```

## Functions

For now, this package contains just two functions:

* `ct_find`: a function for finding and highlighting contours in a single image, with the option to save the recolored image. The main purpose of this function is for the user to tinker with contour values to find the one best suited to their image.
* `ct_overlay`: a function for applying contour lines to a new set of images. This function builds on the `ct_find` function by applying the same recolored pixels to a new set of images. It also saves the recolored images.

For a detailed description of the methodology behind the functions, refer to the `contourr` [vignette](https://github.com/kaitlynstrickfaden/contourr/blob/master/vignettes/contourr.md).

## Important Notes

* The method behind these functions relies on good contrast between the object you want to extract and the background. If your images are overexposed or underexposed, or if the object is the same color as the background, then the functions might not work.
* For the functions to work as intended, all of your images must be the same size. Your newly-saved files will be the same size as the original files.
* Recolored images will have "contourr" added at the end of the file name.

## Contributing

This package is still in early development, so I'd love to hear from folks what other things they'd like to see this package do.

## Authors

* **Kaitlyn Strickfaden** - *Initial work* - [kaitlynstrickfaden](https://github.com/kaitlynstrickfaden)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Huge thanks to the developers of `imager`, Simon Barthelme, David Tschumperle, Jan Wijffels, and Haz Edine.
