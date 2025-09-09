#########################################################################
# Name of file - 01_household_weights.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Imports the relevant subsetted data and scales, calibrates and re-scales
# the data to individual and household level. 
# End product is calibrated household-level weights.

#########################################################################

### 0 - Setup ----

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here("Scripts", "00_setup.R"))

# Add message to inform user about progress
message("Execute household weights script")


### 1 - Import files ----

# Add message to inform user about progress
message("Import data")

SHS <- read_sas(setup$hhsurvdata.path)

hhdata <- read_sas(setup$indsurvdata.path)

hhpoptotals <- read_csv(setup$hhpoptotals.path)
<<<<<<< HEAD

indpoptotals <- read_csv(setup$indpoptotals.path)
=======
>>>>>>> aeef993e4c06400e1402d30477e7007f9b813f55


### 2 - Rename, create and merge variables ----

# Add message to inform user about progress
message("Variable processing")

# LA_Code => Council
# Assign number LA codes with named LAs
SHS <- SHS %>%
  add_la_column() %>% 
  select(UNIQID, LA)

# Counts number of participants in the dataset
hh_surv <- nrow(SHS)[1]

# LA_Code => Council
# Assign number LA codes with named LAs
# Create age band variable
hhdata <- hhdata %>% 
  rename(age = HA5,
         sex = HA6) %>% 
  add_la_column() %>% 
  mutate(ageband = case_when(age >= 0 & age <= 15 ~ "0-15",
                             age >= 16 & age <= 24 ~ "16-24",
                             age >= 25 & age <= 34 ~ "25-34",
                             age >= 35 & age <= 44 ~ "35-44",
                             age >= 45 & age <= 54 ~ "45-54",
                             age >= 55 & age <= 64 ~ "55-64",
                             age >= 65 ~ "65+")) %>% 
  select(UNIQID, pnum, age, NUMBHH, LA, sex, ageband)

# Counts number of participants in the dataset
ind_surv <- nrow(hhdata)[1]

# Randomly assign those with non-binary gender to either male or female
# Only needs to be done to the person subsetted dataset
hhdata <- assign_gender(hhdata)

# check that 3s have been assigned to male/female
unique_genders <- sort(unique(hhdata$sex))

if (!all(unique_genders == c(1, 2))) {
  stop(paste("Sex column must contain only 1 and 2, found:", paste(unique_genders, collapse = ", ")))
}

# Create new Sex and Age bands for calibration in hhdata (person subsetted dataset)
# create character variable for sex
hhdata <- hhdata %>% 
  mutate(sext = case_when(
    sex == 1 ~ "Male",
    sex == 2 ~ "Female"))


### 3 - Survey and population proportions ----

# Add message to inform user about progress
message("Survey and population proportions")

# Survey proportions by LA => uses SHS24 (hh subsetted dataset)
survey_totals <- survey_proportions_hh(SHS, LA)

# Check if the cumulative % equals 100.000000
if (survey_totals[32, 4] == 100.000000) {
  print("Survey total is 100.000000, continuing...")
} else {
  stop("Survey total is not 100.000000, stopping execution.")
}

# Population proportions by LA => uses hh calibration file
pop_totals <- population_proportions(hhpoptotals)

# Check if the cumulative % equals 100.000000
if (pop_totals[32, 4] == 100.000000) {
  print("Population total is 100.000000, continuing...")
} else {
  stop("Population total is not 100.000000, stopping execution.")
}

### 4 - dweight calculation ----

# Add message to inform user about progress
message("Calculating dweight")

# Need to combine the 2 proportion tables and ensure columns are uniquely named
# dweight = percent_pop/percent_surv
dweightcalc <- calculate_design_weights(survey_totals, pop_totals)


### 5 - preweight calculation ----

# Add message to inform user about progress
message("Calculating preweight")

# need to reattach the dweight and preweight of each LA onto hhdata
# calculate preweight = pop total x (dweight/sum(dweight))
# scales the dweight to the total size of the population
hhdata <- hhdata %>%
  left_join(dweightcalc %>% select(LA, dweight), by = "LA") %>%
  mutate(preweight = config$pop_total * (dweight / sum(dweight, na.rm = TRUE))) %>% 
  select(UNIQID, pnum, age, NUMBHH, LA, sex, sext, ageband, dweight, preweight)


### 6 - prep for calibration ----

# Add message to inform user about progress
message("Calibration prep")

# need to attach dweight from dweightcalc to SHS24
# calculate GR_dweight = total no. hhs x (dweight/sum(dweight))
# scales dweight to households rather than individuals like the preweight
SHS <- SHS %>%
  left_join(dweightcalc %>% select(LA, dweight), by = "LA") %>%
  mutate(GR_dweight = config$hh_total * (dweight / sum(dweight, na.rm = TRUE)))

pre_calib <- distribution_check(SHS, GR_dweight)
pre_calib_check <- pre_calib$sum

# Compare the sum to a target (e.g., 100)
if (abs(pre_calib_check - config$hh_total)) {
  print("Sum of GR_dweight matches total adult population of Scotland, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Sum of GR_dweight is", pre_calib_check, "doesn't match. Halting execution."))
}


### 7 - calibration ----

# Add message to inform user about progress
message("Calibration")

# the dweights and preweights are then scaled for sexage by LA
# SHShhtotals breaks down the no. individuals in each sexage band in each LA

result <- calibrate_weights(
  rf.data = hhdata,
  df.population = indpoptotals,
  ids = ~UNIQID,
  strata = NULL,
  model = ~LA:sext:ageband - 1,
  preweight = ~preweight,
  sigma2 = ~NUMBHH
)

names(result$data)[names(result$data)=='preweight.cal'] <- 'int_SHS_hh_wt'
result$data$int_SHS_hh_wt_sc <- result$data$int_SHS_hh_wt*(ind_surv/config$pop_total)


### 8 - remove duplicate weights ----

# Add message to inform user about progress
message("Removing duplicate weights")

# this is so only 1 UNIQID per hh is present in the dataset, 
# ensure it's the 1st person from each hh => indexp = 1
# dweights, preweights, and int_SHS_hh_wts should be the same within a hh => check
calib_check <- calibration_check(
  data = result$data,
  group_var = UNIQID,
  vars_to_check = c("dweight", "preweight", "int_SHS_hh_wt"))


# Check that there are NO observations
if (nrow(calib_check) == 0) {
  print("Same weights within households — continuing as expected...")
  
  # Continue your code here...
  
} else {
  stop(paste("Unexpected data found:", nrow(calib_check), "rows — stopping execution."))
}
# 0 observations good sign

hhwts <- result$data %>% 
  select(UNIQID, pnum, NUMBHH, LA, sext, ageband, dweight, preweight, int_SHS_hh_wt, int_SHS_hh_wt_sc) %>% 
  filter(pnum == '1')

# Check for correct no. observations
if (nrow(hhwts) == hh_surv) {
  print("Correct number of households — continuing as expected...")
  
  # Continue your code here...
  
} else {
  stop(paste("Unexpected data found:", nrow(hhwts), "rows — stopping execution."))
}

### 9 - calculate and apply adjustment factor ----

# Add message to inform user about progress
message("Calculating and applying adjustment factor")

# Adjust weights to no. hhs rather than individuals in each LA
# This is done by calculating the adjustment factor for each LA

# Calculate the weighted number of households in each LA
# Attach the hh totals for each LA (pop_totals data frame from earlier) 
# Calculate adjustment factor for each LA => total no. hhs in LA / weighted total in LA
# => n / surv_total
hhwts <- hhwts %>%
  group_by(LA) %>%
  mutate(surv_total = sum(int_SHS_hh_wt), 
         .groups = "drop") %>%
  left_join(pop_totals %>% select(LA, n), by = "LA") %>%
  mutate(adjfct = n / surv_total,
         SHS_hh_wt = adjfct * int_SHS_hh_wt,
         SHS_hh_wt_sc = SHS_hh_wt * 
           (hh_surv / config$hh_total))


### 10 - checks ----

# Add message to inform user about progress
message("Weight checking")

# large weight records => >2.5
large_wts <- hhwts %>% 
  filter(SHS_hh_wt_sc > 2.5) 
# check to see if the large weights (those underrepresented in the survey pop) come from
# known underrepresented groups e.g. younger men in urban areas

# check LA totals => survey and pop estimates should match
la_totals <- check_la_totals(hhwts, pop_totals, la_col = "LA", weight_col = "SHS_hh_wt", pop_col = "n")

# Check that the survey and pop. totals match
mismatches <- which(abs(la_totals$surv_total - la_totals$n) > 1e-8)

if (length(mismatches) == 0) {
  print("All LA values match — continuing...")
  
  # Continue with code...
  
} else {
  stop(paste("Mismatch found in rows:", paste(mismatches, collapse = ", ")))
}

# distribution of weights: SHS_hh_wt, SHS_hh_wt_sc
wt_precheck <- distribution_check(hhwts, SHS_hh_wt)
wt_check_count <- wt_precheck$count
wt_check_sum <- wt_precheck$sum

if (abs(wt_check_count - hh_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_check_count, "incorrect. Halting execution."))
}

if (abs(wt_check_sum - config$hh_total) < 1e-8) {
  print("Sum of wts equal to household population of Scotland, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Sum of wts", wt_check_sum, "not equal to household population of Scotland. 
             Halting execution."))
}


wt_sc_precheck <- distribution_check(hhwts, SHS_hh_wt_sc)
wt_sc_check_count <- wt_sc_precheck$count
wt_sc_check_sum <- wt_sc_precheck$sum
wt_sc_check_mean <- wt_sc_precheck$mean

if (abs(wt_sc_check_count - hh_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_sc_check_count, "incorrect. Halting execution."))
}

if (abs(wt_sc_check_sum - hh_surv) < 1e-8) {
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


### 11 - export ----

# Add message to inform user about progress
message("Exporting household weights")

hhwts <- hhwts %>%
  select(UNIQID, pnum, LA, sext, ageband, dweight, preweight, int_SHS_hh_wt, 
         int_SHS_hh_wt_sc, SHS_hh_wt, SHS_hh_wt_sc)

write_csv(hhwts, here("Outputs", "hh_wts_final.csv"))


message("Exporting large household weights")

large_hh_wts <- large_wts %>% 
  write_csv(here("Outputs", "large_hh_wts.csv"))
