#' Assign number LA codes with name LAs
#' 
#' @param data Data frame that needs column added
#' 
#' @param council_col Variable contains the number code of LA that will correspond to new name variable
#' 
#' @returns Data frame with new named LA column

add_la_column <- function(data, council_col = "COUNCIL", new_col = "LA") {
  data %>%
    mutate(
      !!sym(new_col) := case_when(
        .data[[council_col]] == 100 ~ "Aberdeen City",
        .data[[council_col]] == 110 ~ "Aberdeenshire",
        .data[[council_col]] == 120 ~ "Angus",
        .data[[council_col]] == 130 ~ "Argyll & Bute",
        .data[[council_col]] == 150 ~ "Clackmannanshire",
        .data[[council_col]] == 170 ~ "Dumfries & Galloway",
        .data[[council_col]] == 180 ~ "Dundee City",
        .data[[council_col]] == 190 ~ "East Ayrshire",
        .data[[council_col]] == 200 ~ "East Dunbartonshire",
        .data[[council_col]] == 210 ~ "East Lothian",
        .data[[council_col]] == 220 ~ "East Renfrewshire",
        .data[[council_col]] == 230 ~ "Edinburgh, City of",
        .data[[council_col]] == 235 ~ "Na h-Eileanan Siar",
        .data[[council_col]] == 240 ~ "Falkirk",
        .data[[council_col]] == 250 ~ "Fife",
        .data[[council_col]] == 260 ~ "Glasgow City",
        .data[[council_col]] == 270 ~ "Highland",
        .data[[council_col]] == 280 ~ "Inverclyde",
        .data[[council_col]] == 290 ~ "Midlothian",
        .data[[council_col]] == 300 ~ "Moray",
        .data[[council_col]] == 310 ~ "North Ayrshire",
        .data[[council_col]] == 320 ~ "North Lanarkshire",
        .data[[council_col]] == 330 ~ "Orkney Islands",
        .data[[council_col]] == 340 ~ "Perth & Kinross",
        .data[[council_col]] == 350 ~ "Renfrewshire",
        .data[[council_col]] == 355 ~ "Scottish Borders",
        .data[[council_col]] == 360 ~ "Shetland Islands",
        .data[[council_col]] == 370 ~ "South Ayrshire",
        .data[[council_col]] == 380 ~ "South Lanarkshire",
        .data[[council_col]] == 390 ~ "Stirling",
        .data[[council_col]] == 395 ~ "West Dunbartonshire",
        .data[[council_col]] == 400 ~ "West Lothian",
        TRUE ~ NA_character_
      )
    )
}
