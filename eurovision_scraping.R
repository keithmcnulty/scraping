# required libraries
library(rvest)
library(xml2)
library(dplyr)

#' Get Eurovision final results from history
#'
#' @param year A numeric in the form YYYY
#' @return A dataframe of Eurovision results
#' @examples get_eurovision(1974)


get_eurovision <- function(year) {
  
  # get url from input and read html
  input <- paste0("https://en.wikipedia.org/wiki/Eurovision_Song_Contest_", year) 
  chart_page <- xml2::read_html(input, fill = TRUE)
  
  
  # scrape data from any sortable table
  chart <- chart_page %>% 
    rvest::html_nodes("#mw-content-text") %>% 
    xml2::xml_find_all("//table[contains(@class, 'sortable')]")
  
  charts <- list()
  chartvec <- vector()
  
  for (i in 1:length(chart)) {
    assign(paste0("chart", i),
           # allow for unexpected errors but warn user
           tryCatch({rvest::html_table(chart[[i]], fill = TRUE)}, error = function (e) {print("Potential issue discovered in this year!")})
    )
    
    
    charts[[i]] <- get(paste0("chart", i))
    # only include tables that have Points
    chartvec[i] <- sum(grepl("Points", colnames(get(paste0("chart", i))))) == 1 & sum(grepl("Category|Venue|Broadcaster", colnames(get(paste0("chart", i))))) == 0 
  }
  
  results_charts <- charts[chartvec]
  
  # account for move to semifinals and qualifying rounds
  if (year < 1956) {
    stop("Contest was not held before 1956!")
  } else if (year == 1956) {
    stop("Contest was held in 1956 but no points were awarded!")
  } else if (year %in% c(1957:1995)) {
    results_charts[[1]] %>% 
      dplyr::arrange(Place) %>% 
      dplyr::select(-Draw)
  } else if (year == 1996) {
    results_charts[[2]] %>% 
      dplyr::arrange(Place) %>% 
      dplyr::select(-Draw)
  } else if (year %in% 1997:2003) {
    results_charts[[1]] %>% 
      dplyr::arrange(Place) %>% 
      dplyr::select(-Draw)
  } else if (year %in% 2004:2007) {
    results_charts[[2]] %>% 
      dplyr::arrange(Place) %>% 
      dplyr::select(-Draw)
  } else {
    results_charts[[3]] %>% 
      dplyr::arrange(Place) %>% 
      dplyr::select(-Draw)
  }
  
  
  
}