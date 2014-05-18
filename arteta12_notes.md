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



Green Kidney Data set
=================
Dimensions: 512x512 pixels
Train: first 35 frames
Test:  about last 25 frames

Over 27 testing images, I get these results:
Mean Precision: 0.68597
Mean Recall: 0.94002
