#########################################################################
# Name of file - 04_travel_weights.R
#
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.4.2
#
# Description - Imports the relevant subsetted data re-scales
# the data taking into account the day the interview took place, as well as 
# the economic activity of the respondent. 
# End product is travel diary weights.

#########################################################################

### 0 - Setup ----

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here("Scripts", "00_setup.R"))

# Add message to inform user about progress
message("Execute travel diary weights script")

### 1 - Import files ----

# Add message to inform user about progress
message("Import data")

randad <- read_sas(setup$randadsurvdata.path)

ind_wts <- read_csv(here("Outputs", "randad_wts_final.csv"))


### 2 - Select and reformat variables, and merge datasets ----

# Add message to inform user about progress
message("Variable processing")

trav_wts <- process_trav_wts(randad, ind_wts)


### 3 - Day Scaling factors ----

# Add message to inform user about progress
message("Calculating day scaling factors")

# Counts number of participants in the dataset
ads_surv <- nrow(randad)[1]

day_totals <- trav_wts %>%  
  group_by(weekday) %>% 
  summarise(n = n(),
            weighted_n = sum(SHS_ind_wt, na.rm = TRUE)) %>% 
  mutate(percent = weighted_n / sum(weighted_n) * 100,
         cumul = cumsum(percent))

# Check if the cumulative % equals 100.000000
if (day_totals[7, 5] == 100.000000) {
  print("Day estimate total is 100.000000, continuing...")
} else {
  stop("Day estimate total is not 100.000000, stopping execution.")
}

expected_interviews <- ads_surv / 7

day_totals<- day_totals %>% 
  mutate(Day_i_scaling_factor = expected_interviews/weighted_n)

trav_wts <- trav_wts %>% 
  recode_econ_status() %>% 
  left_join(day_totals %>% select(weekday, Day_i_scaling_factor), by = c("weekday")) %>% 
  mutate(int_wt = SHS_ind_wt * Day_i_scaling_factor)


### 4 - Econ Scaling factors ----

# Add message to inform user about progress
message("Calculating econ scaling factors")

status_totals <- trav_wts %>%   
  group_by(econ_status) %>% 
  summarise(weighted_n = sum(int_wt, na.rm = TRUE)) %>% 
  mutate(expected_status = weighted_n/7)

trav_wts <- trav_wts %>% 
  left_join(status_totals %>% select(econ_status, expected_status), by = c("econ_status")) 

#calculate expected no. interviews for each day by econ status (56 combos)
day_status_totals <- trav_wts %>% 
  group_by(econ_status, weekday) %>% 
  summarise(cell = sum(int_wt, na.rm = TRUE), .groups = "drop")

# Check that there are 56 observations
if (nrow(day_status_totals) == 56) {
  print("Number of observations correct — continuing as expected...")
  
  # Continue your code here...
  
} else {
  stop(paste("Unexpected data found:", nrow(day_status_totals), "rows — stopping execution."))
}


trav_wts <- trav_wts %>% 
  left_join(day_status_totals %>% select(econ_status, weekday, cell), by = c("econ_status", "weekday")) 


### 5 - Calculate travel weights ----

# Add message to inform user about progress
message("Calculating travel weights")

trav_wts <- trav_wts%>% 
  mutate(status_factor = expected_status/cell,
         SHS_trav_wt = status_factor * int_wt)


### 6 - Distribution check ----

# Add message to inform user about progress
message("Weight checking")

wt_precheck <- distribution_check(trav_wts, SHS_trav_wt)
wt_check_count <- wt_precheck$count
wt_check_sum <- wt_precheck$sum
wt_check_mean <- wt_precheck$mean

if (abs(wt_check_count - ads_surv) < 1e-8) {
  print("Number of observations correct, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Number of observations", wt_check_count, "incorrect. Halting execution."))
}

if (abs(wt_check_sum - ads_surv) < 1e-8) {
  print("Sum of wts equal to number of observations, continuing...")
  
  # Continue with your analysis...
  
} else {
  stop(paste("Sum of wts", wt_check_sum, "not equal to number of observations. 
             Halting execution."))
}

if (wt_check_mean == 1) {
  print("Mean is 1, continuing...")
} else {
  stop("Mean is not 1, stopping execution.")
}



### 7 - Export ----

# Add message to inform user about progress
message("Exporting travel diary weights")

trav_wts <- trav_wts %>% 
  select(UNIQID, SHS_trav_wt)

write_csv(trav_wts, here("Outputs", "trav_wts_final.csv"))
