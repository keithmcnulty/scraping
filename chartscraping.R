# required libraries
library(rvest)
library(xml2)
library(dplyr)


#' Get billboard chart entries from history
#'
#' @param date date in the form YYYY-MM-DD
#' @param positions numeric vector
#' @param type character string of chart type (as per billboard.com URLs)
#' @return a dataframe of rank, artist, title
#' @examples get_chart(date = "1972-11-02", positions = c(1:100), type = "billboard-200")


get_chart <- function(date = Sys.Date(), positions = c(1:10), type = "hot-100") {

  # get url from input and read html
  input <- paste0("https://www.billboard.com/charts/", type, "/", date) 
  chart_page <- xml2::read_html(input)

  
  # scrape data
  rank <- chart_page %>% 
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//span[contains(@class, 'chart-element__rank__number')]") %>% 
    rvest::html_text()
  
  artist <- chart_page %>% 
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//span[contains(@class, 'chart-element__information__artist')]") %>% 
    rvest::html_text()
  
  title <- chart_page %>% 
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//span[contains(@class, 'chart-element__information__song')]") %>% 
    rvest::html_text()

  # create dataframe, remove nas and return result
  chart_df <- data.frame(rank, artist, title)
  chart_df <- chart_df %>% 
    dplyr::filter(!is.na(rank), rank %in% positions)

chart_df

}
