#!/bin/bash
INSTALL_VL_FEAT=true
INSTALL_SVM_STRUCT=true
INSTALL_PYLON_INFERENCE=true

# MATLAB_PATH_DIR=~/Documents/MATLAB/
# MATLAB_LIBS_DIR=~/src/

read -p "Directory in  matlab path [~/Documents/MATLAB/]: " MATLAB_PATH_DIR
MATLAB_PATH_DIR=${MATLAB_PATH_DIR:-'~/Documents/MATLAB/'}

read -p "Directory to dependencies (i.e. VLFeat) [~/src/]: " MATLAB_LIBS_DIR
MATLAB_LIBS_DIR=${MATLAB_LIBS_DIR:-'~/src/'}

echo
echo "The script with download the required libraries"
echo "and place them in the directory ${MATLAB_PATH_DIR}."
echo
echo "It will also create/update a file called startup.m"
echo "in the directory ${MATLAB_LIBS_DIR}"
echo "to initialize the Pylon code on startup of MATLAB."
echo

add_once () {
	# Appends the string ($1) to file $2 if it is not already included in the file
	echo "$1 $2"

	if grep -q "$1" "$2"; then  
		# echo exist 
		echo "$2 is already in $1." 
	else  
	   echo $1 >> "$2"    
	fi
}

# Setup startup.m file
startup_file=${MATLAB_PATH_DIR}startup.m
if [[ ! -e $startup_file ]]; then
	[ -d $MATLAB_PATH_DIR ] || mkdir -p  $MATLAB_PATH_DIR
	touch $startup_file
else
	cp $startup_file ${startup_file}.backup # Make a backup
fi

if [[ $INSTALL_VL_FEAT = true ]]; then
	echo "Installing VL_FEAT"
	url=http://www.vlfeat.org/download/vlfeat-0.9.18-bin.tar.gz
	[ -e vlfeat-0.9.18-bin.tar.gz ] || wget --no-verbose $url
	tar -zxvf vlfeat-0.9.18-bin.tar.gz
	mkdir -p ~/src/vlfeat
	rm -rf ~/src/vlfeat/*
	mv vlfeat-0.9.18/* ${MATLAB_LIBS_DIR}/vlfeat
	rm -r vlfeat-0.9.18
	[ -e vlfeat-0.9.18-bin.tar.gz ] && rm vlfeat-0.9.18-bin.tar.gz

	add_once "run('~/src/vlfeat/toolbox/vl_setup')" $startup_file

	# To test, run `vl_version` in Matlab
fi

if [[ $INSTALL_SVM_STRUCT = true ]]; then
	echo "Installing SVM_struct_matlab"
	url=http://www.robots.ox.ac.uk/~vedaldi/assets/svm-struct-matlab/versions/svm-struct-matlab-1.2.tar.gz
	[ -e svm-struct-matlab-1.2.tar.gz ] || wget --no-verbose $url
	# I am not re-extracting because I had to make some fixes
	# tar -zxvf svm-struct-matlab-1.2.tar.gz
	cd svm-struct-matlab-1.2
	make
	# Hopefully it finishes with no errors
	cp {svm_struct_learn.mex*,svm_struct_learn.m} $MATLAB_PATH_DIR
	cd ..
	# I am not deleting the folder, because it has useful demos
	# rm -r svm-struct-matlab-1.2
	rm -r svm-struct-matlab-1.2.tar.gz

	# To test, run `svm_struct_learn` in Matlab
fi

if [[ $INSTALL_PYLON_INFERENCE = true ]]; then
	echo "Installing Inference module for Pylon model"
	url=http://www.robots.ox.ac.uk/~vilem/PylonCode.zip
	[ -e PylonCode.zip ] || wget --no-verbose $url
	unzip -q PylonCode.zip -dPylonCode
	rm -r ${MATLAB_LIBS_DIR}PylonCode
	

	echo "Installing QPBO"
	url=http://pub.ist.ac.at/~vnk/software/QPBO-v1.31.src.zip
	[ -e QPBO-v1.31.src.zip ] || wget --no-verbose $url
	unzip -q QPBO-v1.31.src.zip
	mv QPBO-v1.31.src/* PylonCode

	mv -f PylonCode $MATLAB_LIBS_DIR
	rm PylonCode.zip
	rm QPBO-v1.31.src.zip

	add_once "addpath('~/src/PylonCode')" $startup_file
	# add_once "run('~/src/PylonCode/pylonSetup')" $startup_file

fi

# tar -zxvf CellDetect_v1.0.tar.gzgs

