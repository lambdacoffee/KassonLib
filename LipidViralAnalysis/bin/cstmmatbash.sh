#!/bin/bash

echo This is the batch file for the semi-automated installation of LipidViralAnalysis for the Kasson Lab!
echo	author: Marcos Cervants
echo	emails: marcerv12@gmail.com, mc2mn@virginia.edu
echo The program will search for installation of Fiji or ImageJ
echo If successful, Fiji or ImageJ will start, the appropriate macros will be installed,
echo	and dialog boxes should prompt User for actions.
echo For manual installaion, please consult README.md

set +v
klib=$1
xtrxn="$klibscripts/automation/main.m"
txt="$klibLipidViralAnalysis/log/binmatlabpath.txt"
if [ test -f "$txt" ]
then
	read mat < "$txt"
	"$mat" -nosplash -r "run(\"$xtrxn\")"
else
	exit -1
fi
exit 0

