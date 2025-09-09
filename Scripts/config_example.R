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

config$prevdate <- xx

### 2 - File paths - TO UPDATE ----

# This section may need to be updated if the data storage location has changed

# Path to data share
config$datashare.path <- paste0("xxxx")

# Path to SAS data
config$sasdata.path <- "xxxx"

# Path to previous year's folder
config$prevyear.path <- paste0("xxx", config$prevyear, " xxx", config$prevyear, "/")


### 3 - Survey and population totals - TO UPDATE ----

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




