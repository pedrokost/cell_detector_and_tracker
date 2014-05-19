Learning
===========

* produce a set of candidate extremal regions
* pick a subset of the candidate extremal regions based on a learned classifier score


Nestedness:
	for the same image I two extremal regions R and S can be either nested or non-overlapping


Green Lung dataset
================


train profile:
140 seconds for 10 images of dimensions

- svm_struct_learn (MEX-file)3 96.204s 55.785s
- java.util.concurrent.LinkedBlockingQueue (Java method)48 37.114 s37.114 s
- buildPylonMSER 350 32.116 s10.137 s
- unique>uniqueR2012a 45010 4.470 s4.470 s
- ismember>ismemberBuiltinTypes 24850 3.978 s3.978 s
- count_unique>int_log_unique 33145 3.889 s3.889 s
- unique 45010 7.561 s3.091 s
- PylonInference 340 42.134 s2.890 s


Red Lung dataset
==================
Training took 725.57seconds (96.65% for QP, 0.00% for kernel, 3.34% for Argmax...). Most of the time was spend on Iteration 2/3.

Testing: fails (see problems)

Problems:

 * When testing: Attempted to access nodesMapping(12); index out of bounds because numel(nodesMapping)=11.
 * Training: too long... something must be wrong


Red Kidney Data set
=================
Dimensions: 512x512 pixels
Train: frames 1-40 (40 frames)
Test:  frames 40-66 (26 frames)

Problems:

* On several images 25/26 and >35 I get errors about 0 subscript, so I just deleted them from the trainin set.

Over 25 testing images, I got these results:
Mean Precision: 0.64
Mean Recall: 1


Green Kidney Data set
=================
Dimensions: 512x512 pixels
Train: first 35 frames
Test:  about last 25 frames

Over 27 testing images, I get these results:
Mean Precision: 0.68597
Mean Recall: 0.94002


Cell detection remarks
=================

The learning algorithm is able to detect cell with very high recall (over 94%), but quite low precision (~65%). The low precision is due to the subjective cell annotation. It is difficult to annotate the cells images equally, that is determine what a cell is in each image, because of the high variance in depth and clarity of each cell. For this reason, the low precision is acceptable, as it allows us to detect cells that the annotator has missed. Furthermore, in the further work of generating tracks, it will be easier to elimintate these outliers, than it would be to add new 'virtual cells' that the algorithm may have missed.

As seen in image [!cell_tracking_papers/code/arteta12_tests/kidney/outKidneyRed/timeplot.png], the tracks of the cells (red kidneys dataset) are clearly discernible, and so are the outliers. It will be easy to discard detected cells that do not repeat in a few image of a sequence.

Code structure
================
Hungarian.m: A function for finding a minimum edge weight matching given a MxN Edge weight matrix WEIGHTS using the Hungarian Algorithm.

PylonInference.m: Picks the best subset of extremal regions in 'r' using the pylon inference

buildPylonMSER.m: Builds the different trees that are formed when running MSER on the cell

count_unique.m: Determines unique values, and counts occurrences

cpdh.m: Invariant Contour Points Distribution Histogram

demo.m: The main function to test/train models

encodeImage.m: Collects the MSERs in an image and encodes individually with the selected features.

encodeMSER.m: Encodes a single MSER with the selected features.

evalDetect.m: Evaluation script to match detections based on the hungarian algorithm.

loadDatasetInfo.m: This is used to setup (and load) the parameters of the dataset.

p_see_annotations.m: Plots an image with its annotations

plotDotsSequence.m: Given a cell of dots arrays, it plots them in a spatial view

setFeatures.m: To set the features and control for training/testing.

testCellDetect.m: Detect cells in an image given the W vector

trainCellDetect.m: Learn a structured output SVM classifier to detect cells based on non-overlapping extremal regions