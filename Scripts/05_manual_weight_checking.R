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

### 0 - Setup ----

# Add message to inform user about progress
message("Execute manual weight checking script")

# Run setup script which loads all required packages and functions and 
# executes the config.R script.

source(here::here("Scripts", "00_setup.R"))


### 1 - Import files ----

# Add message to inform user about progress
message("Data import")

hhwts <- read_csv(here("Outputs", "hh_wts_final.csv"))

adwts <- read_csv(here("Outputs", "randad_wts_final.csv"))

kidwts <- read_csv(here("Outputs", "kids_wts_final.csv"))

travwts <- read_csv(here("Outputs", "trav_wts_final.csv"))

ind_large_wts <- read_csv(here("Outputs", "large_randad_wts.csv"))

kid_large_wts <- read_csv(here("Outputs", "large_randsc_wts.csv"))

hh_est <- read_csv(setup$hhpoptotals.path)

ind_est <- read_csv(setup$adultpoptotals.path)

kid_est <- read_csv(setup$kidpoptotals.path)

prev_year <- read_csv(paste0(config$prevyear.path, "shs_weights_", config$prevdate, ".csv"))

prev_trav <- read_csv(paste0(config$prevyear.path, "shs_travweight_", config$prevdate, ".csv"))

wb <- loadWorkbook(here("Outputs", "SHS_checking_template.xlsx"))



message("Inputting data into workbook")

### 2 - hhwts tab ----
hhwts_tab <- hhwts[, 1:9] #selects the 9 columns needed for the hhwts tab

writeData(wb, sheet = "hhwts", x = hhwts_tab, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)

### 3 - dweight tab ----
dweight_tab <- hh_est %>%
  select(2)

writeData(wb, sheet = "dweight", x = dweight_tab, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)

### 4 - hh_calib tab ----
hh_calib <- hhwts[, c(1, 3, 8:11)]

writeData(wb, sheet = "hh_calib", x = hh_calib, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 5 - shsind tab ----
writeData(wb, sheet = "shsind", x = adwts, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 6 - ind_wt tab ----
ind_wt_tab <- ind_est %>% 
  select(2) %>%
  slice(c(1:12, 14:20, 13, 21:n()))

writeData(wb, sheet = "ind_wt", x = ind_wt_tab, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)

### 7 - IndLargeVals tab ----
writeData(wb, sheet = "IndLargeVals", x = ind_large_wts, startRow = 2, 
          startCol = 1, colNames = FALSE, rowNames = FALSE)


### 8 - shskid tab ----
writeData(wb, sheet = "SHSkid", x = kidwts, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


### 9 - kid_wt tab ----
kid_wt_tab <- kid_est %>% 
  select(2) %>%
  slice(c(1:12, 14:20, 13, 21:n()))

writeData(wb, sheet = "kid_wt", x = kid_wt_tab, startRow = 2, 
          startCol = 3, colNames = FALSE, rowNames = FALSE)


### 10 - KidLargeValues tab ----
writeData(wb, sheet = "KidLargeValues", x = kid_large_wts, startRow = 2, 
          startCol = 1, colNames = FALSE, rowNames = FALSE)


### 11 - prev_year tab ----
prev_year_wts <- prev_year %>% 
  select(1,2,4,6)

writeData(wb, sheet = "prev_year", x = prev_year_wts, startRow = 2, 
          startCol = 1, colNames = FALSE, rowNames = FALSE)


### 12 - Trav weights tab ----
trav_check <- travwts[, 2, drop = FALSE]

writeData(wb, sheet = "Trav weights", x = trav_check, startRow = 2, 
          startCol = 2, colNames = FALSE, rowNames = FALSE)


prev_trav_wts <- prev_trav [, 2, drop = FALSE]

writeData(wb, sheet = "Trav weights", x = prev_trav_wts, startRow = 2, 
          startCol = 1, colNames = FALSE, rowNames = FALSE)


### 13 - Save workbook ----

message("Exporting workbook")

saveWorkbook(wb, file = here("Outputs", "SHS final weight checking.xlsx"), 
             overwrite = TRUE)

message("Please manually check workbook")


# Ask the user a question
answer <- readline(prompt = "Have you manually checked the workbook? Type 'yes' to proceed: ")

# Keep asking until they type "yes"
while (tolower(answer) != "yes") {
  cat("You must type 'yes' to continue.\n")
  answer <- readline(prompt = "Have you manually checked the workbook? Type 'yes' to proceed: ")
}

cat("Proceeding...\n")
