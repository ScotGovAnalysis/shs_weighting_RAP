# SHS Weighting
This repository contains the Reproducible Analytical Pipeline (RAP) for the Scottish Household Survey (SHS) weighting.

# Updating Required Information
The only file that needs to be updated before running the shs_weighting_RAP is the config.R file.

# Running the RAP
To run the RAP, first download the zip folder of the RAP and save it to the correct folder on the datashare. The config.R file will need to be copied from the previous year's weighting folder, then it can be updated with the new file paths.
To execute the shs_weighting.R file which automatically loads the config.R file, the 00_setup.R file and all functions in the functions folder.

# Dependencies
R Packages used and their versions:
- tidyverse: Version 2.0.0
- dplyr: Version 1.1.4
- here: Version 1.0.1
- janitor: Version 2.2.0
- lattice: Version 0.22.6
- ReGenesees: Version 2.4
- readr: Version 2.1.5
- rlang: Version 1.1.3
- openxlsx: Version 4.2.7.1
- foreign: 0.8.87
- haven: Version 2.5.4

IF R IS UPDATED BY SCOTS MAKE SURE TO UPDATE ALL THE PACKAGES
This can be done using this code: install.packages("package name")

# Licence
This repository is available under the Open Government Licence v3.0.
