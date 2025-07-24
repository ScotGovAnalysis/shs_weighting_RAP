#########################################################################
# Name of file - 02_randad_weights.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Imports the relevant subsetted data and scales, calibrates and re-scales
# the data to individual level => only for those that completed the social survey. 
# End product is calibrated random adult-level weights.

#########################################################################

# clear environment
rm(list=ls())

### 0 - Setup ----

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here::here("Scripts", "00_setup.R"))

# Add message to inform user about progress
message("Execute random adult weights script")

### 1 - Import files ----

# Add message to inform user about progress
message("Import data")

randad <- haven::read_sas(config$randadsurvdata.path)

hhdata <- haven::read_sas(config$indsurvdata.path)

SHS <- haven::read_sas(config$hhsurvdata.path)

adultpoptotals <- read_csv(config$adultpoptotals.path)


### 2 - Rename, create and merge variables ----

# Add message to inform user about progress
message("Variable processing")

# LA_Code => Council
# Assign number LA codes with named LAs
# Create age band variable
randad <- randad %>% 
  rename(age = HA5,
         sex = HA2) %>% 
  add_la_column() %>% 
  mutate(adageband = case_when(age >= 0 & age <= 15 ~ "0-15",
                               age >= 16 & age <= 34 ~ "16-34",
                               age >= 35 & age <= 44 ~ "35-44",
                               age >= 45 & age <= 54 ~ "45-54",
                               age >= 55 & age <= 64 ~ "55-64",
                               age >= 65 ~ "65+")) %>% 
  select(UNIQID, age, RANDPEO, LA, sex, adageband)

# Counts number of participants in the dataset
ads_surv <- dim(randad)[1]

hhdata <- hhdata %>% 
  rename(sex = HA6) %>% 
  add_la_column() %>% 
  select(UNIQID, pnum, sex)

SHS <- SHS %>%
  rename(numads = NUMADS) %>% 
  select(UNIQID, numads)

hhdata <- hhdata %>% 
  left_join(SHS %>% select(UNIQID, numads), by = c("UNIQID"))

# Randomly assign those with non-binary gender to either male or female
# Only needs to be done to the person subsetted dataset
# check how many are not assigned to male/female
count(hhdata, sex) # 3 = unassigned gender

hhdata <- assign_gender(hhdata)

# check that 3s have been assigned to male/female
count(hhdata, sex)

# need to make sure that the corrected sex variable is attached to the randad dataset
# first just select the assigned randpeo from each hh from hhdata
#hhdata <- hhdata %>% 
 # filter(pnum == randpeo)

# create character variable for sex
randad <- randad %>%
  left_join(hhdata %>% select(UNIQID, sex, pnum, numads), by = c("UNIQID")) %>% 
  select(-sex.x) %>% 
  rename(sex = sex.y) %>% 
  mutate(adsex = case_when(
    sex == 1 ~ "Male",
    sex == 2 ~ "Female"))

randad <- randad %>% filter(pnum == RANDPEO)

### 3 - Survey and population proportions ----

# Add message to inform user about progress
message("Survey and population proportions")

# Survey proportions by LA => uses SHS24 (hh subsetted dataset)
survey_totals <- survey_proportions_hh(randad, LA)

# Check if the cumulative % equals 100.000000
if (survey_totals[32, 4] == 100.000000) {
  print("Survey total is 100.000000, continuing...")
} else {
  stop("Survey total is not 100.000000, stopping execution.")
}

# Population proportions by LA => uses hh calibration file
pop_totals <- population_proportions(adultpoptotals)

# Check if the cumulative % equals 100.000000
if (pop_totals[32, 4] == 100.000000) {
  print("Population total is 100.000000, continuing...")
} else {
  stop("Population total is not 100.000000, stopping execution.")
}

### 4 - adjustment factor calculation ----

# Add message to inform user about progress
message("Calculating adjustment factor")

adjustment_factor <- randad %>%
  summarise(total_numads = sum(numads), .groups = "drop") %>%
  mutate(adjfct = ads_surv / total_numads)

adjfct <- adjustment_factor$adjfct


### 5 - dweight calculation ----

# Add message to inform user about progress
message("Calculating dweight")

# Need to combine the 2 proportion tables and ensure columns are uniquely named
# dweight = percent_pop/percent_surv
dweightcalc <- calculate_design_weights(survey_totals, pop_totals)


### 6 - preweight calculation ----

# Add message to inform user about progress
message("Calculating preweight")

# need to reattach the dweight and preweight of each LA onto hhdata
# calculate preweight = pop total x (dweight/sum(dweight))
# scales the dweight to the total size of the population
randad <- randad %>%
  left_join(dweightcalc %>% select(LA, dweight), by = "LA") %>%  
  mutate(RA_dweight = dweight * numads,
         RA_dweight2 = RA_dweight *adjfct,
         RA_dweight_sc = RA_dweight2 * config$ads_total,
         preweight = config$ads_total * (RA_dweight_sc / sum(RA_dweight_sc)))


### 7 - calibration ----

# Add message to inform user about progress
message("Calibration")

# the dweights and preweights are then scaled for sexage by LA
# SHShhtotals breaks down the no. individuals in each sexage band in each LA

result <- calibrate_weights(
  rf.data = randad,
  df.population = read.csv(config$indadpoptotals.path),
  ids = ~UNIQID,
  strata = NULL,
  model = ~LA:adsex:adageband-1,
  preweight = ~preweight,
  aggregate.stage = NULL,
  sigma2 = NULL
)

names(result$data)[names(result$data)=='preweight.cal'] <- 'SHS_ind_wt'
result$data$SHS_ind_wt_sc <- result$data$SHS_ind_wt*(ads_surv/config$ads_total)


### 8 - checks ----

# Add message to inform user about progress
message("Weight checking")

# large weight records => >5.0
large_wts <- result$data %>% 
  filter(SHS_ind_wt_sc > 5.0) 
# check to see if the large weights (those underrepresented in the survey pop) come from
# known underrepresented groups e.g. younger men in urban areas

# check LA totals => survey and pop estimates should match
la_totals <- check_la_totals(result$data, pop_totals, la_col = "LA", weight_col = "SHS_ind_wt", pop_col = "n")

# Check that the survey and pop. totals match
mismatches <- which(abs(la_totals$surv_total - la_totals$n) > 1e-8)

if (length(mismatches) == 0) {
  print("All LA values match — continuing...")
  
  # Continue with code...
  
} else {
  stop(paste("Mismatch found in rows:", paste(mismatches, collapse = ", ")))
}

# distribution of weights: SHS_ind_wt, SHS_ind_wt_sc
wt_precheck <- distribution_check(result$data, SHS_ind_wt)
wt_check_count <- wt_precheck$count
wt_check_sum <- wt_precheck$sum

if (abs(wt_check_count - ads_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_check_count, "incorrect. Halting execution."))
}

if (abs(wt_check_sum - config$ads_total) < 1e-8) {
  print("Sum of wts equal to adult population of Scotland, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Sum of wts", wt_check_sum, "not equal to adult population of Scotland. 
             Halting execution."))
}


wt_sc_precheck <- distribution_check(result$data, SHS_ind_wt_sc)
wt_sc_check_count <- wt_sc_precheck$count
wt_sc_check_sum <- wt_sc_precheck$sum
wt_sc_check_mean <- wt_sc_precheck$mean

if (abs(wt_sc_check_count - ads_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_sc_check_count, "incorrect. Halting execution."))
}

if (abs(wt_sc_check_sum - ads_surv) < 1e-8) {
  print("Sum of wts equal to number of observations, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Sum of wts", wt_sc_check_sum, "not equal to number of observations. 
             Halting execution."))
}

if (wt_sc_check_mean == 1) {
  print("Mean is 1, continuing...")
} else {
  stop("Mean is not 1, stopping execution.")
}



### 9 - export ----

# Add message to inform user about progress
message("Exporting random adult weights")

randad_wts <- result$data %>% 
  select(UNIQID, LA, adsex, adageband, numads, preweight, SHS_ind_wt,
         SHS_ind_wt_sc)

write_csv(randad_wts, here::here("Outputs", "randad_wts_final.csv"))


message("Exporting large household weights")

large_randad_wts <- large_wts %>% 
  select(LA, adsex, adageband, numads, preweight, SHS_ind_wt, SHS_ind_wt_sc)

write_csv(large_randad_wts, here::here("Outputs", "large_randad_wts.csv"))
