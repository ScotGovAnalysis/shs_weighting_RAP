#' Calculate survey proportions for each LA
#' 
#' @param data Data frame that contains the relevant subsetted data
#' 
#' @param survey_proportions Will group, summarise and calculate % and cumul % 
#' 
#' @returns Data frame correctly formatted and with % and cumul % for each LA


survey_proportions_hh <- function(data, group_var) {
  data %>%
    group_by({{ group_var }}) %>%
    summarise(n = n(), .groups = "drop") %>%
    mutate(
      percent = n / sum(n) * 100,
      cumul = cumsum(percent)
    )
}


survey_proportions <- function(data, group_var, value_var) {
  data %>%
    group_by({{ group_var }}) %>%
    summarise(n = sum({{ value_var }}, na.rm = TRUE), .groups = "drop") %>%
    mutate(
      percent = n / sum(n) * 100,
      cumul = cumsum(percent)
    )
}