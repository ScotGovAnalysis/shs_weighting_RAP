#########################################################################
# Name of file - 00_setup.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Sets up environment required for running the SHS Weighting RAP.

#########################################################################

### 1 - Load packages ----

library(tidyverse)
library(dplyr)
library(janitor)
library(lattice)
library(ReGenesees)
library(readr)
library(rlang)
library(openxlsx)
library(foreign)
library(haven)

### 2 - Load functions from functions folder of SHS Weighting RAP ----

walk(list.files(here("Functions"), pattern = "\\.R$", full.names = TRUE), 
     source)


### 3 - Load config file from code folder of SHS Weighting RAP ----

# The config.R script is the only file which needs to be updated before 
# the RAP can be run. 

source(here("Scripts", "config.R"))



### 4 - Non-sensitive file paths needed for SHS Weighting RAP ----

# initiate list 
setup <- list()

# File path to NRS mid-year hh population totals
setup$hhpoptotals.path <- paste0(config$datashare.path, "hhtotals.csv")

# File path to NRS mid-year ind population totals
setup$indpoptotals.path <- paste0(config$datashare.path, "SHShhtotals.csv")

# File path to NRS mid-year indad population totals
setup$indadpoptotals.path <- paste0(config$datashare.path, "SHSindtotals.csv")

#File path to NRS mid-year ind population totals 
setup$adultpoptotals.path <- paste0(config$datashare.path, "la pop totals.csv")

#File path to NRS mid-year child population totals 
setup$kidpoptotals.path <- paste0(config$datashare.path, "la child totals.csv")


#File path to household subsetted survey data
setup$hhsurvdata.path <- paste0(config$sasdata.path, "hhold", config$wyear, ".sas7bdat")

#File path to person subsetted survey data
setup$indsurvdata.path <- paste0(config$sasdata.path, "person", config$wyear, ".sas7bdat")

#File path to random adult subsetted survey data
setup$randadsurvdata.path <- paste0(config$sasdata.path, "randad", config$wyear, ".sas7bdat")

#File path to random school child subsetted survey data
setup$randscsurvdata.path <- paste0(config$sasdata.path, "randsc", config$wyear, ".sas7bdat")
