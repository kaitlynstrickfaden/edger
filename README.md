# contourr
This package contains a few simple functions for finding an object in one image using its contours and overlaying its outline onto other images. 

### Prerequisites

This package relies on the package "imager". The webpage for imager can be viewed [here](http://dahtah.github.io/imager/), and the GitHub page can be viewed [here](https://github.com/dahtah/imager).

```
install.packages("imager")
```

### Installing

Install **contourr** via Github using standard operating procedure.

```
devtools::install_github("kaitlynstrickfaden/contourr")
library(contourr)
```

## Functions

For now, this package contains just two functions:

* **contourfinder:** a function for finding and highlighting contours in a single image, with the option to save the recolored image. The main purpose of this function is for the user to tinker with contour values to find the one best suited to their reference image.
* **overlay:** a function for applying contour lines to a new set of images. This function builds on the contourfinder function by applying the same recolored pixels to a new set of images. It also saves the recolored images.

## Important Notes

* **The bigger your images are, the longer these functions will take to run.** If you are using these functions on a lot of images, it will probably be in your best interest to resize them first. 
* For the functions to work as intended, all of your images must be the same size. For now, your newly-saved files will be the same size as the original files, but I will make this more flexible if there is interest.
* Your outputs will all be .jpg files, but again, if there is interest, I will make this more flexible.

## Contributing

This package is still in very early development, so I'd love to hear from folks what other things they'd like to see this package do.

## Authors

* **Kaitlyn Strickfaden** - *Initial work* - [kaitlynstrickfaden](https://github.com/kaitlynstrickfaden)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Huge thanks to the developers of imager, Simon Barthelme [aut, cre], David Tschumperle [ctb], Jan Wijffels [ctb], and Haz Edine [ctb].
