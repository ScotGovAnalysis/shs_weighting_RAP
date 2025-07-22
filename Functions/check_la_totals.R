#' Comparing the population estimate totals with the calibrated survey totals
#' 
#' @param pop_totals NRS population estimates - what the weights have been calibrated to
#' 
#' @param calrdata dataset with the calibrated weights included
#' 
#' @param check_la_totals takes inputted data, re-formats and allows for easy comparison
#' 
#' @returns dataset with each row representing an individual LA and the survey/pop totals next to each other


check_la_totals <- function(data, pop_data, la_col = "LA", weight_col = "SHS_hh_wt", pop_col = "n") {
  data %>%
    select(!!sym(la_col), !!sym(weight_col)) %>%
    group_by(!!sym(la_col)) %>%
    summarise(surv_total = sum(!!sym(weight_col)), .groups = "drop") %>%
    left_join(pop_data %>% select(!!sym(la_col), !!sym(pop_col)), by = la_col)
}