# KassonLib
up-to-date version of Kasson Lab collection of viral assay analysis automation
***
Pardon the appearance, currently under construction.
Come back soon!
***

Requirements for work flow & processing imaging data:
  - Either Fiji or ImageJ (Fiji is preferred as this supports additional plugins that will not be available in ImageJ)
  - Licensed version of MATLAB
  - Python3 (>= version 3.6.0)
  - See below for details on these components...

Fiji/ImageJ Instructions:
  - Download for respective OS here: https://imagej.net/software/fiji/?Downloads and follow instructions for installation
  - Ideally place somewhere in UserProfile | user directory (either C:\Users\USERPROFILE\ on Windows or ~/user/ directory on Linux/macOS)
  - Run the program, allow any updates & exit

MATLAB Instructions:
  - Ensure a working & licensed version of MATLAB (>= version 2017b) is installed on machine
  - Ensure the following toolboxes are also installed:
      - Simulink
      - Bioinformatics Toolbox
      - Computer Vision Toolbox
      - Curve Fitting Toolbox
      - Data Acquisition Toolbox
      - Database Toolbox
      - Image Processing Toolbox
      - Optimization Toolbox
      - Signal Processing Toolbox
      - Statistics and Machine Learning Toolbox
  - ***Note: it may be easier/faster to just install a new version of MATLAB & select these toolboxes, especially if several are missing...

Python Instructions:
  - Download Python3 for respective OS here: https://www.python.org/downloads/ and install (***any version >= 3.6.0 will do)\
  - Necessary packages (not essential to manually download as install will take care of things if Python3 is installed)
      - imageio
      - Matplotlib
      - NumPy
      - Pandas
      - fusion_review

***

INSTALLATION

- Download the KassonLib directory and place it somewhere accessible.
- Move/copy these files from the KassonLib/ directory into the Fiji.app/plugins/ subdirectory:
    - iText7-Core-7.1.2.zip
    - pdf_macroext-20130327.jar
- For WINDOWS:
    - Navigate to: ..\KassonLib\LipidViralAnalysis\bin\ & run win_install.exe
    - Go through the prompt messages & installation with Fiji/ImageJ
- For Linux/macOS (terminal commands delineated as $ ... ):
    - Navigate to: ../KassonLib/LipidViralAnalysis/bin/ & open a terminal instance in this path
    - $ chmod +x install.sh
    - $ ${PWD}/install.sh

***
TODO:
  - Add additional commentary & documentation!
  - Separate ../bin/ directory files by type???
