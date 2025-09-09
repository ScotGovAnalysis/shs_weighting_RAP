#' Calculate desin weights
#' 
#' @param data Data frame that contains the formatted survey and 
#' population proportions
#' 
#' @param calculate_design_weights Will join 2 datasets, rename columns and 
#' calculate the dweight
#' 
#' @returns Data frame correctly formatted and dweight column attached


calculate_design_weights <- function(survey_totals, pop_totals) {
  bind_cols(survey_totals, pop_totals) %>%
    rename(
      LA = LA...1,
      n_surv = n...2,
      percent_surv = percent...3,
      cumul_surv = cumul...4,
      n_pop = n...6,
      percent_pop = percent...7,
      cumul_pop = cumul...8
    ) %>%
    select(-LA...5) %>%
    mutate(dweight = percent_pop / percent_surv)
}
