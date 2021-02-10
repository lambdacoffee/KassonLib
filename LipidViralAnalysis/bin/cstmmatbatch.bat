@echo off
REM This is the batch file for the ...

setlocal EnableDelayedExpansion
set txt=%cd%\macros\KassonLib\LipidViralAnalysis\log\binmatlabpath.txt
if exist %txt% (set /p mat=<"%txt%") else (exit -1)
set xtrxn=%cd%\macros\KassonLib\scripts\lipid_mixing_analysis_scripts\ExtractTracesFromVideo\Run_Me_To_Start.m
"%mat%"^ -nodesktop^ -r^ "run('%xtrxn%')"
endlocal
exit 0