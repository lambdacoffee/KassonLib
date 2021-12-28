@echo off
setlocal EnableDelayedExpansion
set klib=%1
set txt="%klib%log\binmatlabpath.txt"
if exist %txt% (set /p mat=<"%txt%") else (exit -1)
set xtrxn=%klib%scripts\mat\automation\main.m
"%mat%"^ -nodesktop^ -r^ "run('%xtrxn%')"
endlocal
exit 0