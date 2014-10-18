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

## Usage:

Refer to `runner.m`.

Brief instruccions are provided in the Appendix of the [project report](https://github.com/pedrokost/cell_tracking_msc_report).

## TODO

Please refere to the [TODO file](TODO) for a list of possible improvements. 

## Pull requests

Good pull requests—patches, improvements, new features—are a fantastic help. They should remain focused in scope and avoid containing unrelated commits.

## Related repositories

* [MSc dissertation](https://github.com/pedrokost/cell_tracking_msc_report)
* [Image Sequence Annotation Tool](https://github.com/pedrokost/cell_annotator)