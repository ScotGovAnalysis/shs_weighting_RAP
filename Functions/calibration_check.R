#' Check that dweights, preweights, and int_SHS_hh_wts are the same within a hh after calibration
#' 
#' @param calrdata Data frame that needs to be checked
#' 
#' @param vars_to_check Variables that should be the same within a hh (dweights, preweights, and int_SHS_hh_wts)
#' 
#' @returns Data frame with count of those that are different => 0 observations good


calibration_check <- function(data, group_var, vars_to_check) {
  data %>%
    group_by({{ group_var }}) %>%
    summarise(across(all_of(vars_to_check), ~n_distinct(.), .names = "{.col}_unique"), .groups = "drop") %>%
    filter(if_any(ends_with("_unique"), ~ . > 1))
}