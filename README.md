[![DOI](https://zenodo.org/badge/60594305.svg)](https://zenodo.org/badge/latestdoi/60594305)

# AutoRef
The source code for the prototype developed as part of my Master's thesis "Automatic georeferencing of Orthophotographs and Aerial Images".
The goal is to develop a program that can georeference an arbitrary orthophoto (or any other aerial image for that matter) by finding marked ground control points in the image, and then matching these with a set of measured-in ground control points.
For now it does work, however it is not entierly stable.
Consequently it is not ready for production, but is useful for research purposes.

It is lisensed under the Mozilla Public Lisence 2.0.

The thesis assosiated with this program will be available after it as been greaded.

## Requirements
The project requires MathWork Matlab in order to run.
Three toolboxes are also required: Image Processing Toolbox, Statistics and Machine Learning Toolbox, and [JSONlab](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files).
It has only been tested on Matlab R2016a, but should work on sufficiently new versions.

## Citation
As this was created for my Master's Thesis, please use the following citation if you use this project, or found it useful in your work :-)
```bibtex
@mastersthesis{Nistad2016,
    author    = "Nistad, Sindre",
    title     = "Automatic georeferencing of Orthophotographs, and Aerial Images",
    school    = "Norwegian University of Science and Technology, NTNU",
    year      = "2016",
    month     = "June",
    note      = "\url{http://hdl.handle.net/11250/2413312}",
}
