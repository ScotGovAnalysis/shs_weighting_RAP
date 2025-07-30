#########################################################################
# Name of file - 05_manual_weight_checking.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Imports all the files containing the calibrated
# weights (household, random adult, random school child and travel diary)
# It them automatically allocates the necessary variables to the
# appropriate tab in the SHS final weight checking excel workbook.
# The workbook will then need to be manually checked to ensure that the 
# weights fit the parameters set out by the formulas.

########################################################################

# clear environment
rm(list=ls())

### 0 - Setup ----

# Add message to inform user about progress
message("Execute manual weight checking script")

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here::here("Scripts", "00_setup.R"))


### 1 - Import files ----

# Add message to inform user about progress
message("Data import")

hhwts <- read_csv(here::here("Outputs", "hh_wts_final.csv"))

adwts <- read_csv(here::here("Outputs", "randad_wts_final.csv"))

kidwts <- read_csv(here::here("Outputs", "kids_wts_final.csv"))

travwts <- read_csv(here::here("Outputs", "trav_wts_final.csv"))

ind_large_wts <- read_csv(here::here("Outputs", "large_randad_wts.csv"))

kid_large_wts <- read_csv(here::here("Outputs", "large_randsc_wts.csv"))

wb <- loadWorkbook(here::here("Outputs", "SHS final weight checking.xlsx"))



message("Inputting data into workbook")

### 2 - hhwts tab ----
hhwts_tab <- hhwts[, 1:9] #selects the 9 columns needed for the hhwts tab

writeData(wb, sheet = "hhwts", x = hhwts_tab, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 3 - hh_calib tab ----
hh_calib <- hhwts[, c(1, 3, 8:11)]

writeData(wb, sheet = "hh_calib", x = hh_calib, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 4 - shsind tab ----
writeData(wb, sheet = "shsind", x = adwts, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 5 - IndLargeVals tab ----
writeData(wb, sheet = "IndLargeVals", x = ind_large_wts, startRow = 2, 
          startCol = 1, colNames = FALSE, rowNames = FALSE)


### 6 - shskid tab ----
writeData(wb, sheet = "SHSkid", x = kidwts, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 7 - KidLargeValues tab ----
writeData(wb, sheet = "KidLargeValues", x = kid_large_wts, startRow = 2, 
          startCol = 1, colNames = FALSE, rowNames = FALSE)


### 8 - Trav weights tab ----
trav_check <- travwts[, 2, drop = FALSE]

writeData(wb, sheet = "Trav weights", x = trav_check, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 9 - Save workbook ----

message("Exporting workbook")

saveWorkbook(wb, file = here::here("Outputs", "SHS final weight checking.xlsx"), 
             overwrite = TRUE)

message("Please manually check workbook")
