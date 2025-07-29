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
require("foreign")
require("haven")

### 2 - Load functions from functions folder of SHS Weighting RAP ----

walk(list.files(here::here("Functions"), pattern = "\\.R$", full.names = TRUE), 
     source)


### 3 - Load config file from code folder of SHS Weighting RAP ----

# The config.R script is the only file which needs to be updated before 
# the RAP can be run. 

source(here::here("Scripts", "config.R"))


### 4 - Message style ----

#title <- black $ bold

#normal <- black