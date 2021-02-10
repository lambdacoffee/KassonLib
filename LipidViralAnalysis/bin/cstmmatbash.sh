#!/bin/bash

set +v
# comment

xtrxn="$PWD/macros/KassonLib/scripts/lipid_mixing_analysis_scripts/ExtractTracesFromVideo/Run_Me_To_Start.m"
txt="$PWD/macros/KassonLib/LipidViralAnalysis/log/binmatlabpath.txt"
if [ test -f "$txt" ]
then
	read mat < "$txt"
	"$mat" -nosplash -r "run(\"$xtrxn\")"
else
	exit -1
fi
exit 0

