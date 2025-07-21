#########################################################################
# Name of file - shs_weighting.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Calls all scripts needed to to weight the Scottish Household
# Survey data. Structures and calculates the variables necessary for 
# calibration. The calibrated weights are then adjusted (if necessary)
# and their distribution checked. Finally, they are then exported
# to the Outputs folder.

#########################################################################

# clear environment
rm(list=ls())

### 0 - Setup ----

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here::here("Scripts", "00_setup.R"))


### 1 - Household weights ----

# Runs the household weights script
source(here::here("Scripts", "01_household_weights.R"))


### 2 - Random adult weights ----

# Runs the random adult weights script
source(here::here("Scripts", "02_randad_weights.R"))


### 3 - Random school child weights ----

# Runs the random school child weights script
source(here::here("Scripts", "03_randsc_weights.R"))


### 4 - Travel diary weights ----

# Runs the travel weights script
source(here::here("Scripts", "04_travel_weights.R"))


### 5 - Collate the weights ----

# Runs the collate weights script
source(here::here("Scripts", "05_collate_weights.R"))
