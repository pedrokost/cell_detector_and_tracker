#!/bin/bash

INSTALL_EKFUKF=true

MATLAB_PATH_DIR=~/Documents/MATLAB/
MATLAB_LIBS_DIR=~/src/

add_once () {
	# Appends the string ($1) to file $2 if it is not already included in the file
	echo "Adding $1 to $2"

	if grep -q "$1" "$2"; then  
		echo "Nothing done, was already done."  
	else  
	   echo $1 >> "$2"    
	   echo "Done."  
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

if [[ $INSTALL_EKFUKF = true ]]; then
	echo "Installing EKF/UKF Toolkit for Matlab"
	url=http://becs.aalto.fi/en/research/bayes/ekfukf/ekfukf_1_3.zip
	[ -e ekfukf_1_3.zip ] || wget --no-verbose $url
	unzip -q ekfukf_1_3.zip -dekfukf
	rm -r ${MATLAB_LIBS_DIR}ekfukf
	
	mv -f ekfukf/ekfukf $MATLAB_LIBS_DIR
	rm ekfukf_1_3.zip

	add_once "addpath('~/src/ekfukf')" $startup_file
fi