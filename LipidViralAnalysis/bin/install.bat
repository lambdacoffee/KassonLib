@echo off
GOTO commentary

:commentary
(
echo This is the batch file for the semi-automated installation of LipidViralAnalysis for the Kasson Lab!
echo	author: Marcos Cervants
echo	emails: marcerv12@gmail.com, mc2mn@virginia.edu
echo The program will search for installation of Fiji or ImageJ
echo If successful, Fiji or ImageJ will start, the appropriate macros will be installed,
echo	and dialog boxes should prompt User for actions.
echo For manual installaion, please consult README.md
)

setlocal EnableDelayedExpansion
set installmacro="%cd%\install_driver_macro.ijm"
if not exist %installmacro% (exit -1)
set initpath="%cd%\initializer.ijm"
if not exist %initpath% (exit -2)
cd ..\..
set kassonlibdir="%cd%"\
cd \

for /f "delims=" %%f in ('dir /s /b ImageJ*.exe') do (
	for %%a in (%%f) do (
		for %%b in ((%%~dpa\.) do (
			if %%~nxb EQU Fiji.app (
				set fiji="%%f"
			) else (if %%~nxb EQU ImageJ (set ij="%%f"))
		)
	)
)
pause

if not exist %fiji% (
	if not exist %ij% (start https://fiji.sc/?Downloads)
) else (if exist %fiji% (
	%fiji% --headless -macro %installmacro% %initpath%
) else (if exist %ij% (%ij% --headless -macro %installmacro% %initpath%))

if exist %fiji% (%fiji% -macro %initpath% %kassonlibdir%)
else if exist %ij% (%ij% -macro %initpath% %kassonlibdir%)

endlocal
exit 0
