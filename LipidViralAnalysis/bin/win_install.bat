@echo off
CALL :commentary
:commentary
(
	echo This is the batch file for the semi-automated installation of LipidViralAnalysis for the Kasson Lab!
	echo	author: Marcos Cervants
	echo	emails: marcerv12@gmail.com, mc2mn@virginia.edu
	echo The program will search for installation of Fiji or ImageJ and Python
	echo If successful, Fiji or ImageJ will start, the appropriate macros will be installed,
	echo	and dialog boxes should prompt User for actions.
	echo If ImageJ/Fiji cannot be found, a web browser will open to prompt download.
	echo If Python3 cannot be found, a web browser will open to prompt download.
	echo If necessary Python packages cannot be found, these will also be downloaded.
	echo For a complete list of all dependencies, please consult README.md
	echo For manual installaion, please consult README.md
)

PAUSE

setlocal EnableDelayedExpansion
SET cfg="%cd%\config.ijm"
IF not exist %cfg% (exit -1)
SET stp="%cd%\setup.ijm"
IF not exist %stp% (exit -2)
SET bindir="%cd%"
cd ..\..
SET kassonlibdir="%cd%"\
cd \

python --version
if not %ERRORLEVEL% EQU 0 (
	start https://www.python.org/downloads/
) else (
	CALL :pycheck
)

:pycheck
	python -m pip install --upgrade pip
	python -m pip install matplotlib
	python -m pip install pandas
	python -m pip install imageio
	python -m pip install numpy
	python -m pip install fusion_review

echo Searching for Fiji/ImageJ...
cd %USERPROFILE%
for /f "delims=" %%f in ('dir /s /b ImageJ*.exe') do (
	for %%a in (%%f) do (
		for %%b in ((%%~dpa\.) do (
			if %%~nxb EQU Fiji.app (
				SET fiji="%%f"
				echo found Fiji
			) else (if %%~nxb EQU ImageJ (
				SET ij="%%f"
				echo found ImageJ
				)
			)
		)
	)
)

PAUSE

if not exist %fiji% (
	if not exist %ij% (start https://imagej.net/software/fiji/downloads)
) else (if exist %fiji% (
		%fiji% --headless -macro %cfg% %stp%
		%fiji% -macro %stp% %kassonlibdir%
	) else (if exist %ij% (
			%ij% --headless -macro %cfg% %stp%
			%ij% -macro %stp% %kassonlibdir%
		)
	)
)

endlocal
exit 0
