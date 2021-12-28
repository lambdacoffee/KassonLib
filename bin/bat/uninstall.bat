@echo off
CALL :commentary
:commentary
(
	echo Preparing to uninstall components related to Kasson Tool for ViralFusionAnalysis.
	echo This program will search for installation of Fiji or ImageJ.
	echo If successful, Fiji or ImageJ will start, and the appropriate macros for
	echo	uninstallation will be executed with dialog boxes for User actions.
	echo If User wishes to uninstall FusionReview from Python, please refer to README.md
	echo For manual uninstallaion, please consult README.md
)

PAUSE

setlocal EnableDelayedExpansion
cd ..\..
cd "%cd%\scripts\ijm"
SET uninst="%cd%\uninstall.ijm"
IF not exist %uninst% (exit -1)
cd ..\..
cd "%cd%\log
set txt="%cd%\ijpath.txt"
if exist %txt% (set /p ij=<"%txt%") else (exit -2)
if exist %ij% (
	%ij% -macro %uninst%
) else (
	echo WARNING: Cannot find ImageJ/Fiji, program has been moved or deleted!
	PAUSE
	exit -3
)
echo ***
echo uninstallation complete
PAUSE
endlocal
exit 0