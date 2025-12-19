#########################################################################
# Name of file - 05_collate_weights.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Imports all the files containing the calibrated
# weights (household, random adult, random school child and travel diary)
# End product is one csv file with all the weights attched to the 
# correct UNIQID

#########################################################################

### 0 - Setup ----

# Add message to inform user about progress
message("Execute collate weights script")

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here::here("Scripts", "00_setup.R"))

wt_date <- gsub("-", "", Sys.Date())

### 1 - Import files ----

# Add message to inform user about progress
message("Data import")

hhwts <- read_csv(here("Outputs", "hh_wts_final.csv"))

adwts <- read_csv(here("Outputs", "randad_wts_final.csv"))

kidwts <- read_csv(here("Outputs", "kids_wts_final.csv"))

travwts <- read_csv(here("Outputs", "trav_wts_final.csv"))


### 2 - Select the relevant variables ----

message("Tidying the datasets up")

hhwts <- hhwts %>% 
  select(UNIQID, SHS_hh_wt_sc, SHS_hh_wt) %>% 
  rename(LA_GRWT = SHS_hh_wt,
         LA_WT = SHS_hh_wt_sc)

adwts <- adwts %>% 
  select(UNIQID, SHS_ind_wt_sc, SHS_ind_wt) %>% 
  rename(IND_GRWT = SHS_ind_wt,
         IND_WT = SHS_ind_wt_sc)

kidwts <- kidwts %>% 
  select(UNIQID, SHS_kid_wt_sc, SHS_kid_wt) %>% 
  rename(KID_GRWT = SHS_kid_wt,
         KID_WT = SHS_kid_wt_sc)


### 3 - Join the datasets together ----

# Add message to inform user about progress
message("Joining datasets together")

SHS_wts <- hhwts %>% 
  full_join(adwts, by = "UNIQID") %>% 
  full_join(kidwts, by = "UNIQID") %>% 
  full_join(travwts, by = "UNIQID")

### 4 - Export ----

# Add message to inform user about progress
message("Exporting SHS weights")

write.csv(SHS_wts, here("Outputs", paste0("shs_weights_", wt_date, ".csv")))
