#' Recode econ status
#' 
#' @param data Data frame which includes the the econ variable
#' 
#' @returns Data frame with recoded econ status reday for further calcularions


recode_econ_status <- function(df) {
  df %>%
    dplyr::mutate(
      econ_status = dplyr::case_when(
        HA7 == 1 ~ 1,
        HA7 == 2 ~ 2,
        HA7 == 3 ~ 3,
        HA7 == 4 ~ 4,
        HA7 == 5 ~ 5,
        HA7 == 6 ~ 6,
        HA7 %in% c(7, 8, 9, 12, 13, 14) ~ 7,
        HA7 %in% c(10, 11) ~ 8
      )
    )
} 