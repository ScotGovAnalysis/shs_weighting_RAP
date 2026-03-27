#' Imports SAS and Excel files
#' 
#' @param file Filepath of file that is to be imported
#' 
#' @returns Imported data frame

sas_excel_import <- function(file){
  
  if(config$raw == 'yes'){
    X <- read_csv(file, show_col_types = FALSE)
  }
  
  if(config$raw == 'no'){
    X <- read_sas(file)
  }
  
  return(X)
  
}
