@echo off
REM This is the batch file for the ...

setlocal EnableDelayedExpansion
set klib=%1
set txt=%klib%LipidViralAnalysis\log\binmatlabpath.txt
if exist %txt% (set /p mat=<"%txt%") else (exit -1)
set xtrxn=%klib%scripts\automation\main.m
"%mat%"^ -nodesktop^ -r^ "run('%xtrxn%')"
endlocal
exit 0