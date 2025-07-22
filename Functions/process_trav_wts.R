#' Create initial travel weights dataset
#' 
#' @param data Data frames that need to be joined together
#' 
#' @returns trav_wts => usable data frame to calculate travel wieghts


process_trav_wts <- function(randad, ind_wts) {
  # Select relevant columns
  randad <- randad %>% 
    dplyr::select(UNIQID, R_DATE, HA7)
  
  ind_wts <- ind_wts %>% 
    dplyr::select(UNIQID, SHS_ind_wt)
  
  # Join and mutate
  trav_wts <- randad %>% 
    dplyr::left_join(ind_wts, by = "UNIQID") %>%
    dplyr::mutate(
      r_date = as.Date(R_DATE),
      weekday = weekdays(r_date, abbreviate = TRUE)
    )
  
  return(trav_wts)
}