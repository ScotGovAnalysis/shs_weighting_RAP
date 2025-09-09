#########################################################################
# Name of file - 03_randsc_weights.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Imports the relevant subsetted data and scales, calibrates and re-scales
# the data to individual level => only for those that completed the social survey. 
# End product is calibrated random child-level weights.

#########################################################################

### 0 - Setup ----

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here("Scripts", "00_setup.R"))

# Add message to inform user about progress
message("Execute random school child weights script")

### 1 - Import files ----

# Add message to inform user about progress
message("Import data")

randsc <- read_sas(setup$randscsurvdata.path)

hhdata <- read_sas(setup$indsurvdata.path)

SHS <- read_sas(setup$hhsurvdata.path)

kidpoptotals <- read_csv(setup$kidpoptotals.path)

hh_wts <- read_csv(here("Outputs", "hh_wts_final.csv")) 


### 2 - Rename, create and merge variables ----

# Add message to inform user about progress
message("Variable processing")

# LA_Code => Council
# Assign number LA codes with named LAs
# Create age band variable
randsc <- randsc %>% 
  rename(age = HA5)  %>% 
  add_la_column() %>% 
  mutate(ageband = case_when(age <= 6 ~ "4-6",
                             age >= 7 & age <= 9 ~ "7-9",
                             age >= 10 & age <= 12 ~ "10-12",
                             age >= 13 ~ "13+")) %>% 
  select(UNIQID, LA, age, ageband, KIDPNO)

# Counts number of participants in the dataset
kids_surv <- nrow(randsc)[1]

# rename variables
# create named LA variable
hhdata <- hhdata %>% 
  rename(age = HA5,
         sex = HA6,
         econ = HA7) %>% 
  add_la_column() %>% 
  select(UNIQID, sex, econ, age, pnum)

SHS <- SHS %>%
  rename(numkids = NUMKIDS) %>% 
  select(UNIQID, numkids)

kidpoptotals <- kidpoptotals %>% 
  rename(total = Age4_16)

# Randomly assign those with non-binary gender to either male or female
# Only needs to be done to the person subsetted dataset
# check how many are not assigned to male/female
count(hhdata, sex) # 3 = unassigned gender

hhdata <- assign_gender(hhdata)

# check that 3s have been assigned to male/female
count(hhdata, sex)

# need to make sure that the corrected sex variable is attached to the randad dataset
# first just select the assigned kidpno from each hh from hhdata
#hhdata <- hhdata %>% 
 # filter(indexp == kidpno)

# create character variable for sex
randsc <- randsc %>%
  left_join(hhdata %>% select(UNIQID, sex, econ, pnum), by = c("UNIQID")) %>%
  mutate(sext = case_when(
    sex == 1 ~ "Male",
    sex == 2 ~ "Female")) 

randsc <- randsc %>% filter(pnum == KIDPNO)

### 3 - Survey and population proportions ----

# Add message to inform user about progress
message("Survey and population proportions")

# Survey proportions by LA => uses SHS24 (hh subsetted dataset)
survey_totals <- survey_proportions_hh(randsc, LA)

# Check if the cumulative % equals 100.000000
if (survey_totals[32, 4] == 100.000000) {
  print("Survey total is 100.000000, continuing...")
} else {
  stop("Survey total is not 100.000000, stopping execution.")
}


# Population proportions by LA => uses hh calibration file
pop_totals <- population_proportions(kidpoptotals)

# Check if the cumulative % equals 100.000000
if (pop_totals[32, 4] == 100.000000) {
  print("Population total is 100.000000, continuing...")
} else {
  stop("Population total is not 100.000000, stopping execution.")
}

### 4 - adjustment factor calculation ----

# Add message to inform user about progress
message("Calculating adjustment factor")

adjustment_factor <- SHS %>%
  summarise(total_kids = sum(numkids), .groups = "drop") %>%
  mutate(adjfct = kids_surv / total_kids)

adjfct <- adjustment_factor$adjfct

randsc <- randsc %>% 
  left_join(SHS %>% select(UNIQID, numkids), by = c("UNIQID"))

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
randsc <- randsc %>%
  left_join(dweightcalc %>% select(LA, dweight), by = "LA") %>% 
  mutate(dweight2 = dweight * adjfct,
         int_dweight = dweight2 * numkids,
         preweight = config$kids_total * (int_dweight / sum(int_dweight)))


### 7 - population estimates calculation ----

# Add message to inform user about progress
message("Calculating population estimates")

#Since the schools census is the only population total produced for Scotland,
#the household weights are used to create the targets instead.
#This is because the schools census doesn't account for independent schools,
#or those who are home-schooled.

#Now calculate totals based on the household weights carried out previously
#obtain hh weights
hh_wts <- hh_wts %>% 
  select(UNIQID, LA, SHS_hh_wt)

#obtain person-level dataset
hhdata <- hhdata %>% 
  select(UNIQID, age, econ)

#join them by UNIQID
#filter by econ so only records with 7 are present (in education)
kids_pop_totals <- hhdata %>% 
  left_join(hh_wts,  by = c("UNIQID"))%>% 
  filter(econ == 7) %>%
  mutate(ageband = case_when(
    age <= 6 ~ "4-6",
    age >= 7 & age <= 9 ~ "7-9",
    age >= 10 & age <= 12 ~ "10-12",
    age >= 13 ~ "13+"))

kids_pop_totals <- kids_pop_totals %>% 
  group_by(LA, ageband) %>% 
  summarise(n = sum(SHS_hh_wt, na.rm = TRUE)) %>% 
  mutate(n = round(n), #rounds to whole number
         percent = n / sum(n) * 100)

kids_pop_est <- kids_pop_totals %>%
  ungroup() %>% 
  mutate(total = n,
         name = str_c("la", str_trim(as.character(LA)), ":ageband", str_trim(ageband))) %>%
  select(total, name) 

kids_pop_totals <- kids_pop_totals %>% 
  group_by(LA) %>% 
  summarise(n = sum(n, na.rm = TRUE)) %>% 
  mutate(#n = round(n),
         percent = n / sum(n) * 100,
         cumul = cumsum(percent))
#this dataset will be used to help check the calibrated wts

# Check if the cumulative % equals 100.000000
if (kids_pop_totals[32, 4] == 100.000000) {
  print("Population estimate total is 100.000000, continuing...")
} else {
  stop("Population estimate total is not 100.000000, stopping execution.")
}

psize <- sum(kids_pop_totals$n)

### 8 - calibration ----

# Add message to inform user about progress
message("Calibration")

# the dweights and preweights are then scaled for ageband by LA
# kids_pop_est breaks down the no. individuals in each ageband band in each LA

result <- calibrate_weights(
  rf.data = randsc,
  df.population = kids_pop_est,
  ids = ~UNIQID,
  strata = NULL,
  model = ~LA:ageband-1,
  preweight = ~preweight,
  aggregate.stage = NULL,
  sigma2 = NULL
)

names(result$data)[names(result$data)=='preweight.cal'] <- 'SHS_kid_wt'
result$data$SHS_kid_wt_sc <- result$data$SHS_kid_wt*(kids_surv/psize)

### 8 - checks ----

# Add message to inform user about progress
message("Weight checking")

# check LA totals => survey and pop estimates should match
la_totals <- check_la_totals(result$data, kids_pop_totals, la_col = "LA", weight_col = "SHS_kid_wt", pop_col = "n")

# Check that the survey and pop. totals match
mismatches <- which(abs(la_totals$surv_total - la_totals$n) > 1e-8)

if (length(mismatches) == 0) {
  print("All LA values match — continuing...")
  
  # Continue with code...
  
} else {
  stop(paste("Mismatch found in rows:", paste(mismatches, collapse = ", ")))
}


# distribution of weights: SHS_kid_wt, SHS_kid_wt_sc
wt_precheck <- distribution_check(result$data, SHS_kid_wt)
wt_check_count <- wt_precheck$count
wt_check_sum <- wt_precheck$sum

if (abs(wt_check_count - kids_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_check_count, "incorrect. Halting execution."))
}

if (abs(wt_check_sum - psize) < 1e-8) {
  print("Sum of wts equal to calculated child population of Scotland, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Sum of wts", wt_check_sum, "not equal to calculated child population of Scotland. 
             Halting execution."))
}


wt_sc_precheck <- distribution_check(result$data, SHS_kid_wt_sc)
wt_sc_check_count <- wt_sc_precheck$count
wt_sc_check_sum <- wt_sc_precheck$sum
wt_sc_check_mean <- wt_sc_precheck$mean

if (abs(wt_sc_check_count - kids_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_sc_check_count, "incorrect. Halting execution."))
}

if (abs(wt_sc_check_sum - kids_surv) < 1e-8) {
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
message("Exporting random school child weights")

randsc_wts <- result$data %>% 
  select(UNIQID, LA, numkids, dweight2, int_dweight, ageband, preweight, 
         SHS_kid_wt, SHS_kid_wt_sc)

write_csv(randsc_wts, here("Outputs", "kids_wts_final.csv"))


message("Exporting large child weights")

large_randsc_wts <- randsc_wts %>% 
  select(UNIQID, LA, numkids, ageband, SHS_kid_wt, SHS_kid_wt_sc)

write_csv(large_randsc_wts, here("Outputs", "large_randsc_wts.csv"))
