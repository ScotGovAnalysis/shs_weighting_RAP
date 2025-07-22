#########################################################################
# Name of file - config.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Specifies file paths, file names.
# This is the only file which requires manual changes before the 
# RAP process is run. It is not pushed to git as it contains 
# sensitive information.
#########################################################################

### 1 - Sample year - TO UPDATE ----

# initiate list 
config <- list()

# Year the data is being weighted for (usually the previous calendar year)
# (i.e., 20XX)
config$wyear <- xx

# Date that the RAP is run to produce the weights
# MUST be changed each time it's run (if on a different day)
config$date <- xxxx

### 2 - File paths - TO UPDATE ----

# This section may need to be updated if the data storage location has changed

# Path to data share
config$datashare.path <- paste0("xxxx")

# Path to SAS data
config$sasdata.path <- "xxxx"

### 3 - File names - TO UPDATE ----

# File path to raw data - only need if sub-setting required
#config$shs_raw.path <- paste0(config$datashare.path, "shs24q4_05.99_toSGforweightingsetup4Apr25.sav") 


# File path to NRS mid-year hh population totals
config$hhpoptotals.path <- paste0(config$datashare.path, "xxxx")

# File path to NRS mid-year ind population totals
config$indpoptotals.path <- paste0(config$datashare.path, "xxxx")

# File path to NRS mid-year indad population totals
config$indadpoptotals.path <- paste0(config$datashare.path, "xxxx")

#File path to NRS mid-year ind population totals 
config$adultpoptotals.path <- paste0(config$datashare.path, "xxxx")

#File path to NRS mid-year child population totals 
config$kidpoptotals.path <- paste0(config$datashare.path, "xxxx")


#File path to household subsetted survey data
config$hhsurvdata.path <- paste0(config$sasdata.path, "xxxx")

#File path to person subsetted survey data
config$indsurvdata.path <- paste0(config$sasdata.path, "xxxx")

#File path to random adult subsetted survey data
config$randadsurvdata.path <- paste0(config$sasdata.path, "xxxx")

#File path to random school child subsetted survey data
config$randscsurvdata.path <- paste0(config$sasdata.path, "xxxx")


### 4 - Survey and population totals - TO UPDATE ----

#Total population of Scotland
config$pop_total <- xxxx
#this is obtained from SHS 20xx Population Source workbook, People tab

#Total household population of Scotland
config$hh_total <- xxxx
#this is obtained from SHS 20xx Population Source workbook, Households tab

#Total adult population of Scotland
config$ads_total <- xxxx
#this is obtained from SHS 20xx Population Source workbook, People tab

#Total child population of Scotland
config$kids_total <- xxxx
#this is obtained from SHS 20xx Population Source workbook, People tab




