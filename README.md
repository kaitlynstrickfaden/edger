# edger
This package allows the user to find the edges in one image and apply those edges to other images.

### Prerequisites

This package relies heavily on the package `imager`. The webpage for `imager` can be viewed [here](http://dahtah.github.io/imager/), and the GitHub page can be viewed [here](https://github.com/dahtah/imager). You also need `dplyr`, `progressr`, and`stringr`. 

```

install.packages(c("devtools", "dplyr", "imager", "progressr", "stringr"))

```

You also need to download ExifTool and list it in your environmental variables. You can download ExifTool for your system [here](https://exiftool.org/install.html). Check to see if your computer can navigate to it by running the command `exiftool` in the command prompt on your machine. 


### Installing

When installing `edger`, specify `build_vignettes = TRUE`.

```
devtools::install_github("kaitlynstrickfaden/edger", build_vignettes = TRUE)
library(edger)
```

## Functions

There are three main functions in the `edger` package. These are:

* `edger_single`: a function for finding and recoloring edges in a single image, with the option to save the recolored image. 
* `edger_multi`: a function for applying edges to multiple images. This function builds on the `edger_single` function by applying the edges found in the first image(s) to other images. It also saves the recolored images with "edger" appended to the original file name.
* `edger_testr`: an interactive function to help you find the right threshold, shift, and rotation values for a series of input images. The coordinates to the drawn region(s) of interest and values are compiled and output as a list to then be used as inputs to the `edger_multi` function.

The rest of the functions in the package are helper functions that feed into the main wrapper functions. 



For a detailed description of the methodology behind the functions, refer to the `edger_methodology` [vignette](https://github.com/kaitlynstrickfaden/edger/blob/master/vignettes/edger_methodology.md). For a detailed description of the functions in the package, refer to the `edger_use` [vignette](https://github.com/kaitlynstrickfaden/edger/blob/master/vignettes/edger_use.md). 

## Important Notes

* The method behind these functions relies on good contrast between the object you want to extract and the background. If your images are overexposed or underexposed, or if the object is the same color as the background, then the functions might not work.
* For the functions to work as intended, all of your images must be the same size. Your newly-saved files will be the same size as the original files.
* Recolored images will have "edger" added at the end of the file name - the package will not overwrite your raw images.
* The metadata from the original images is now attributed to the recolored images using ExifTool. 


## Contributing

This package is still in development, so I'd love to hear from folks what other things they'd like to see this package do.

## Authors

* **Kaitlyn Strickfaden** - *Initial work* - [kaitlynstrickfaden](https://github.com/kaitlynstrickfaden)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Huge thanks to the developers of `imager`, Simon Barthelme, David Tschumperle, Jan Wijffels, and Haz Edine.
