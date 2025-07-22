#' Ensuring that all the weights add up and mean correctly
#' 
#' @param calrdata dataset with the calibrated weights included
#' 
#' @param check_la_totals takes inputted data, re-formats and allows for easy comparison
#' 
#' @returns dataset with each row representing an individual LA and the survey/pop totals next to each other


distribution_check <- function(data, weight_col) {
  weight_col <- rlang::ensym(weight_col)
  
  data %>%
    summarise(
      count = n(),
      sum = sum(!!weight_col, na.rm = TRUE),
      mean = mean(!!weight_col, na.rm = TRUE),
      sd = sd(!!weight_col, na.rm = TRUE),
      IQR = IQR(!!weight_col, na.rm = TRUE)
    )
}
