#' Calculate population estimate proportions for each LA
#' 
#' @param data Data frame that contains the relevant calibration estimates data
#' 
#' @param population_proportions Will group, summarise and calculate % and cumul %
#' 
#' @returns Data frame correctly formatted and with % and cumul % for each LA



population_proportions <- function(data) {
  data %>%
    rename(LA = la, n = total) %>%
    mutate(
      LA = recode(LA, "Eilean Siar" = "Na h-Eileanan Siar")
    ) %>%
    slice(c(1:12, 14:20, 13, 21:n())) %>%
    mutate(
      percent = n / sum(n) * 100,
      cumul = cumsum(percent)
    )
}
