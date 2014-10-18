Automatic Cell Detector and Tracker
=============

An automatic cell detection and tracking method that works well even on low quality images (obscured cells, blurred frames, etc) and different types of cells and microscopic imaging techniques.

Requires to train the models using dot-annotations (for detection module) and link-annotations (for tracking module).

## Setup instructions

	git clone https://github.com/pedrokost/cell_detector_and_tracker.git
	cd cell_detector_and_tracker/+detector/setup
	# Make the setup script executable
	chmod +x setup.sh
	# Execute the script
	./setup.sh

## Troubleshooting

When compiling the `SVM_struct_matlab` code, you might get a warning like this:

	Warning: You are using gcc version '4.8.2'. The version of gcc is not supported. The version currently supported with MEX is '4.7.x'.

In this case Google for a solution. It should be as simple as downloading gcc 4.7:
	
	sudo apt-get install gcc-4.7 g++-4.7

and [setting it as default](http://askubuntu.com/questions/26498/choose-gcc-and-g-version).

Remember to execute the setup script again after the correct version of gcc is set.

## Usage:

Refer to `runner.m`.

Brief instruccions are provided in the Appendix of the [project report](https://github.com/pedrokost/cell_tracking_msc_report).

## TODO

Please refere to the [TODO file](TODO) for a list of possible improvements. 

## Pull requests

Good pull requests—patches, improvements, new features—are a fantastic help. They should remain focused in scope and avoid containing unrelated commits.

## Dependencies

This project relies on the following libraries:

* [VL_feat](http://www.vlfeat.org/)
* [SVM_struct_matlab](http://www.vlfeat.org/~vedaldi/code/svm-struct-matlab.html)
* [Inference code for Pylon models](http://www.robots.ox.ac.uk/~vilem/), which depends on the [QPBO from Vladimir Kolmogorov](http://pub.ist.ac.at/~vnk/software.html).

These dependencies can be downloaded and installed using an automated script, as described above, in the Setup instructions.

The projects was developed and tested on MATLAB R2014a, but I think it should work fine on R2013b as well. It won't work on versions prior or equal to R2013a, because of changes in the Neural Network Toolbox. 

## Acknowledgements

The original code from the cell detector module was developed by [C. Arteta, V. Lempitsky, J. A. Noble and A. Zisserman](http://www.robots.ox.ac.uk/~vgg/research/cell_detection/). Although some performance and structural improvements were required to use their code for this project, their code was of great help.

## Related repositories

* [MSc dissertation](https://github.com/pedrokost/cell_tracking_msc_report)
* [Image Sequence Annotation Tool](https://github.com/pedrokost/cell_annotator)