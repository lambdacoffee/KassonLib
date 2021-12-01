#!/bin/bash

echo This is the batch file for the semi-automated installation of LipidViralAnalysis for the Kasson Lab!
echo	author: Marcos Cervants
echo	emails: marcerv12@gmail.com, mc2mn@virginia.edu
echo The program will search for installation of Fiji or ImageJ
echo If ImageJ/Fiji cannot be found, a web browser will open to prompt download.
echo If Python3 cannot be found, Python 3.6.0 will be installed.
echo If necessary Python packages cannot be found, these will also be downloaded.
echo For a complete list of all dependencies, please consult README.md
echo For manual installaion, please consult README.md

read -n 1 -p "Press any key to continue: "

set +V
installmacro="${PWD}/install_driver_macro.ijm"
if [ ! test -f "$installmacro" ];
then
	exit -1;
fi
initpath="${PWD}/initializer.ijm"
if [ ! test -f "$initpath" ];
then
	exit -2;
fi

cd ../..
kassonlibdir="${PWD}/"
cd

python3 --version
if [ ! $? == 0 ];
then
        
fi      
xdg-open https://imagej.net/software/fiji/downloads

