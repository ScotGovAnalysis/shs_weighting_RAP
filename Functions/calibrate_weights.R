#' The dweights and preweights are scaled for sexage by LA to population 
#' estimates via calibration
#' 
#' @param Data frame that needs to be calibrated (hhdata, randad, randsc)
#' 
#' @param function contains all the parameters required for the calibration 
#' to take place
#' 
#' @returns Dataset with the calibrated weights


calibrate_weights <- function(rf.data,
                              df.population,
                              ids = ~UNIQID,
                              strata = NULL,
                              model = ~LA:sext:ageband - 1,
                              preweight = ~preweight,
                              calfun = "linear",
                              bounds = c(0.1, 10000),
                              aggregate.stage = 1,
                              sigma2 = ~NUMBHH) {
  
  # Ensure variables are factors
  rf.data <- rf.data %>%
    mutate(across(all.vars(model), as.factor))
  
  # Create population template
  pop <- pop.template(rf.data, calmodel = model)
  
  # Standardize population variable names if necessary
  df.population$name <- sub("^la", "LA", df.population$name)
  
  # Transpose and clean up
  pop2 <- t(pop)
  colnames(pop2) <- "NA"
  pop.names <- data.frame(name = rownames(pop2))
  
  # Merge population totals
  merge1 <- merge(pop.names, df.population, by = "name", all.x = TRUE, sort = FALSE)
  merge1[!complete.cases(merge1), "total"] <- 0
  
  merge2 <- data.frame(merge1[, "total"])
  rownames(merge2) <- merge1[, "name"]
  merge3 <- t(merge2)
  final_pop <- data.frame(merge3)
  colnames(final_pop) <- colnames(merge3)
  
  rf.data <- as.data.frame(rf.data)  # Force base R data.frame
  rf.data$preweight <- as.numeric(as.character(rf.data$preweight))  # Force clean numeric
  
  # Create survey design object
  des <- e.svydesign(data = rf.data, ids = ids, strata = strata, weights = ~preweight)
  
  # Calibrate
  calr <- e.calibrate(design = des, 
                      df.population = final_pop,
                      calmodel = model,
                      calfun = calfun,
                      bounds = bounds,
                      aggregate.stage = aggregate.stage,
                      sigma2 = sigma2)

  # This then creates a separate data file with the output weights added  
  calrdata <- calr$variables					
  list(data=calrdata, poptemp=pop, poptot=final_pop)
}
