@echo off
REM This is the batch file for the automated installation of LipidViralAnalysis

setlocal EnableDelayedExpansion
set installerpath="%cd%\lipidviralinstall.ijm"
if exist "%cd%\ImageJ-win64.exe" (set ij="%cd%\ImageJ-win64.exe")
if exist "%cd%\ImageJ-win32.exe" (set ij="%cd%\ImageJ-win32.exe")
if exist "%cd%\ImageJ.exe" (set ij="%cd%\ImageJ.exe")
if not defined ij (exit -1)
if exist %installerpath% (start "" powershell -WindowStyle Hidden %ij% -macro %installerpath%) else (exit -1)
endlocal
exit 0