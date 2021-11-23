@echo off
GOTO commentary

:commentary
(
	echo This is the batch file for the semi-automated installation of LipidViralAnalysis for the Kasson Lab!
	echo	author: Marcos Cervants
	echo	emails: marcerv12@gmail.com, mc2mn@virginia.edu
	echo The program will search for installation of Fiji or ImageJ and Python
	echo If successful, Fiji or ImageJ will start, the appropriate macros will be installed,
	echo	and dialog boxes should prompt User for actions.
	echo If ImageJ/Fiji cannot be found, a web browser will open to prompt download.
	echo If Python3 cannot be found, it will be downloaded.
	echo If necessary Python packages cannot be found, these will also be downloaded.
	echo For a complete list of all dependencies, please consult README.md
	echo For manual installaion, please consult README.md
)

setlocal EnableDelayedExpansion
set installmacro="%cd%\install_driver_macro.ijm"
if not exist %installmacro% (exit -1)
set initpath="%cd%\initializer.ijm"
if not exist %initpath% (exit -2)
set bindir="%cd%"\
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

where /q /r "C:\Program Files" python.exe && GOTO pycheck || GOTO getpython

:getpython
(
	cd %bindir%
	set arch=%PROCESSOR_ARCHITECTURE%
	if %arch% == AMD64 (
		python-3.6.0-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
		GOTO pycheck
	)
)

:pycheck
(
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python get-pip.py
	python -m pip install matplotlib
	python -m pip install pandas
	python -m pip install imageio
	python -m pip install numpy
	python -m pip install fusion_review==0.4.0
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
