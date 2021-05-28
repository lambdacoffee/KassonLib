#!/bin/bash

set +v
# comment
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

