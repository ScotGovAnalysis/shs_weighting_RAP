#' Randomly assign those with non-binary gender to either male or female
#' 
#' @param data Data frame which includes the the sex variable
#' 
#' @param sex_column Variable, any obs of 3 need to be reassigned to 1 or 2
#' 
#' @returns Data frame with only 2 levels of the sex variable.
#' The set seed allows for reproducibility => same records assigned to 1 or 2
#' each time he code is run. 

 
assign_gender <- function(data, sex_column = "sex", seed = 123) {
  set.seed(seed)
  
  data <- data %>%
    mutate({{ sex_column }} := as.character(.data[[sex_column]])) %>%
    {
      index_3 <- which(.[[sex_column]] == "3")
      n_3 <- length(index_3)
      shuffled <- sample(index_3)
      half <- floor(n_3 / 2)
      
      .[[sex_column]][shuffled[1:half]] <- "1"
      .[[sex_column]][shuffled[(half + 1):n_3]] <- "2"
      .[[sex_column]] <- factor(.[[sex_column]])
      .
    }
  
  return(data)
}