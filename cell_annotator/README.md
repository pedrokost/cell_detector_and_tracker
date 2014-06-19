![cell annotator logo](https://gitlab.doc.ic.ac.uk/pdk10/cell-tracking/raw/master/cell_annotator/thumbnail.png "Cell Annotator") Cell Annotator
===================================

A utility to facilitate the annotation of cell images with dots and connect the cells between consecutive frames (links).

Dots represent the centroids of cells, while links connect the same cells across consecutive frames.

![cell annotator screenshot](https://gitlab.doc.ic.ac.uk/pdk10/cell-tracking/raw/master/cell_annotator/screenshot.png "Cell Annotator")

## Possible applications

The main goal of this application is the annotation of cells in image sequences, however it can be used for the annotation of any kind of images with dots, for example a particle system.

## Usage

The application is distributed as a compiled MATLAB application. It can be installed by double clicking on the binary executable. If the user does not have the MATLAB Compiler Runtime installed, internet connection is required to download it first.

## Requirements

The MATLAB Compiler Runtime (installed automatically if missing)

## Features

* Display sequence of images, up to 10 images in a single screen
* Dot annotations
* Link annotation (connection between consecutive images)
* Wide range of optional filters to improve the visibility of the cells
* Shortcuts for many things
* Overlay of a different annotation set, for example one obtained using a cell detection algorithm.
* Resizable interface

## File format

The application requires that images and annotations are stored in the same folder, using the following structure:

```
dataFolder
	|- im[0-9]+.pgm 
	|- im[0-9]+.mat
```
The image file format is limited to `pgm` files, but this can be easily configured within the script.

The `mat` should contain two variables (if the variables are not existent, they will be created) called `dots` and `links`.

`dots` is a `nCells x 2` matrix containing `x`- and `y`- coordinates of cell positions. For example:
```
dots =

         252         292
          46         323
          81         399
```

`links` is a `nCells x 1` matrix containing for each cell the index of the linked cell in the next image, or 0 if there is no link. For example:

```
links =

     1
     0
     3
```

## Known bugs

* If an action (eg add link) is being used and the window is closed, a new blank figure will open.
* Cannot use scroll wheel to scroll between images when an action is being used (eg add dot annotation)
* When the `+ link` tool is being use, and a new tool is selected, the tool change happens only after the user clicks twice on invalid cells (eg. twice on the same image, or too far from annotated cells)
* The first click on the image to add an annotation takes several seconds.

## TODO

* licence (probably BSD)
* compile binary