---
title: "Scraping and Harvesting Web Data in R"
author: "Keith McNulty"
date: "25/07/2019"
output:
  html_document:
    keep_md: true
    code_folding: hide
    toc: true
    toc_float: true
    number_sections: true
---




# Web Page Structure and Format

Any webpage you visit has a particular, expected general structure.  It usually consists of two types of code.  

* `HTML` code, which focuses on the appearance and format of a web page.
* `XML` code, which doesn't *look* a lot different from `HTML` but focusses more on managing data in a web page. 

## `HTML` code

`HTML` code has an expected format and structure, to make it easy for people to develop web pages.   Here is an example of a simple `HTML` page:


```
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
</head>
<body>

<h1>This is a Heading</h1>
<p>This is a paragraph.</p>

</body>
</html>
```

As you can see, the content is wrapped in tags like `<head></head>`, `<body></body>`, `<p></p>`.  These tags are pre-defined by the language (you can only use the tags that `HTML` allows).  Because `HTML` has a more predictable structure, it is often easier to work with it and mine it.  

## `XML` code

`XML` format and structure is less predictable.  Although it looks very similar to `HTML`, users can create their own named tags.  Here is an example:

```
<note>
  <to>Keith</to>
  <from>Kevin Sneader</from>
  <heading>Kudos</heading>
  <body>Awesome work, dude!</body>
</note>
```
Tags like `<to></to>` and `<from></from>` are completely made up by me.  The fact that tags are not pre-defined makes `XML` a little harder to mine and analyze.  But it's hard to get at some of the data on the web without using `XML`.

## Using Google Chrome Developer

To mine web data, it's important that you can see the underlying code and understand how it relates to what you are seeing on the page.  The best way to do this (in my opinion) is to use the Developer Tools that come with Google Chrome.  

When you are viewing a web page in chrome, simply used `Ctrl+Shift+C` in Windows or `Cmd+Options+C` on a Mac to open up the Elemenrs console where you can see all the code underlying the page.  This can look really complex, but don't worry.  Here's a photo of Google Chrome Developer open on the [Billboard Hot 100 page](https://www.billboard.com/charts/hot-100):

<center><img src="chrome-dev-screenshot.png" alt="Google Chrome Developer"></center>

## Embedded structure of web code

If you play around with the code in the Developer you will see that it has an embedded structure.  

* At the highest level there is a `<html>` tag.  
* At the second level there are `<head>` and `<body>` tags.
* Inside the `<body>` of the page, different elements are often separated by `<div>` tags.
* Many different types of tags continue to be embedded down to many nested levels

This is important because it means we can mine elements of a web page and treat them like lists in R.  We often call a specific element of the page a *node*.  So if we want to mine a specific node, we can capture its sub-nodes in a list.  By doing so, this gives us the opportunity to apply the tidyverse when mining web pages.  The process of mining data from the web is called *scraping* or *harvesting*.

## The `rvest` and `xml2` packages

The `rvest` and `xml2` packages were designed to make it easier for people working in R to harvest web data.  Since `xml2` is a required package for `rvest` and the idea is that both packages work together, you only need to install `rvest`.  First, lets ensure the packages we need are installed and loaded:


```r
if (!("rvest" %in% installed.packages())) {
  install.packages("rvest")
}

if (!("dplyr" %in% installed.packages())) {
  install.packages("dplyr")
}

library(rvest)
```

```
## Loading required package: xml2
```

```r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

`rvest` and `xml2` contain functions that allow us to read the code of a web page, break it into a nead structure, and work with the pipe command to efficienly find and extract specific pieces of information.  Think of it a bit like performing keyhole surgery on a webpage.  One you understand what functions are available and what they do, it makes basic web scraping very easy and can produce really powerful functionality.

# Basic harvesting:  The Billboard Hot 100 page

We are going to use the example of mining the Billboard Hot 100 page at https://www.billboard.com/charts/hot-100.   If you view this page, it's pretty bling.  There are videos popping up, images all over the place.  But the basic point of the page is to show the current Hot 100 chart.  

So let's set ourself the task of just harvesting the basic info from this page: Position Number, Artist, Song Title for the Hot 100.

## Getting started

First we load our packages and then we use the function `read_html()` to capture the HTML code of the Billboard Hot 100 page.


```r
hot100page <- "https://www.billboard.com/charts/hot-100"
hot100 <- read_html(hot100page)

hot100
```

```
## {xml_document}
## <html class="" lang="">
## [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset= ...
## [2] <body class="chart-page chart-page- " data-trackcategory="Charts-The ...
```

```r
str(hot100)
```

```
## List of 2
##  $ node:<externalptr> 
##  $ doc :<externalptr> 
##  - attr(*, "class")= chr [1:2] "xml_document" "xml_node"
```

The function has captured the entire content of the page in the form of a special list-type document with two nodes `<head>` and `<body>`.  Almost always we are interested in the body of a web pages.  You can select a node using `html_node()` and then see its *child nodes* using `html_children()`.  


```r
body_nodes <- hot100 %>% 
  html_node("body") %>% 
  html_children()

body_nodes
```

```
## {xml_nodeset (20)}
##  [1] <div class="header-wrapper ">\n<header id="site-header" class="site ...
##  [2] <div class="site-header__placeholder"></div>
##  [3] <main id="main" class="page-content"><div class="chart-detail-heade ...
##  [4] <div class="ad_desktop dfp-ad" data-position="promo" data-sizes="[[ ...
##  [5] <footer id="site-footer" class="site-footer"><div class="container  ...
##  [6] <script>\n    window.CLARITY = window.CLARITY || [];\n</script>
##  [7] <div class="ad_clarity" data-out-of-page="true" style="display: non ...
##  [8] <script>\n    CLARITY.push({\n        use: ['ads', 'cookies', 'head ...
##  [9] <script type="text/javascript" src="https://assets.billboard.com/as ...
## [10] <script type="text/javascript" src="https://assets.billboard.com/as ...
## [11] <script type="text/javascript" src="https://assets.billboard.com/as ...
## [12] <script type="text/javascript" src="https://assets.billboard.com/as ...
## [13] <script type="text/javascript" src="https://assets.billboard.com/as ...
## [14] <script type="text/javascript">\n\tvar _sf_async_config={};\n\t/**  ...
## [15] <script class="kxct" data-id="JsVUOKRj" data-timing="async" data-ve ...
## [16] <script class="kxint" type="text/javascript">\n    window.Krux||((K ...
## [17] <script data-src="//platform.instagram.com/en_US/embeds.js"></script>
## [18] <script data-src="//platform.twitter.com/widgets.js"></script>
## [19] <div id="fb-root"></div>
## [20] <script type="text/javascript">\n    PGM.createScriptTag("//connect ...
```

If we want, we can go one level deeper, to see the nodes inside the nodes, we can just continue to pipe deeper into the code:


```r
body_nodes %>% 
  html_children()
```

```
## {xml_nodeset (12)}
##  [1] <header id="site-header" class="site-header " role="banner"><div cl ...
##  [2] <div class="header-wrapper__secondary-header">\n<nav class="site-he ...
##  [3] <div class="chart-detail-header">\n<div class="chart-detail-header_ ...
##  [4] <div class="ad-container leaderboard leaderboard--top">\n<div class ...
##  [5] <div class="container chart-container container--xxlight-grey conta ...
##  [6] <div class="chart-list__expanded-header">\n<div class="chart-list__ ...
##  [7] <div id="dateSearchModal" class="date-search-modal" data-visible="f ...
##  [8] <div class="ad-holder ad-holder--footer">\n<div class="ad_desktop d ...
##  [9] <div class="container footer-content">\n<div class="cover-image">\n ...
## [10] <div class="container">\n<p class="copyright__paragraph">© 2019 Bil ...
## [11] <div class="container">\n<p class="station-identification">\nBillbo ...
## [12] <div class="container">\n<div class="ad_desktop dfp-ad dfp-ad-adhes ...
```

## Forensically targeting information of interest

So we could mess around with the functions above for a long time, but might find it hard to work out where exactly this chart data is.  This is where we will use Chrome Developer to tell us where we can find the data in the code, and then we can use `rvest` to harvest out the data.

If you run your mouse over the code in the Developer you will see that the elements of the page that the code revers to are highlighted in the browser.  You can click to expand embedded nodes to get to more specific parts of the page.  Watch this video to see how I progressively drill down the code to find the precise nodes that contain the details of each chart entry.

<center>
<video width="320" height="240" controls>
  <source src="chromechart.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>
</center>

What we see is that each chart entry appears to be in a `<div>` tag with the class name `chart-list-item` and the div tag seems to have attributes that we are interested in, namely `data-rank`, `data-artist`, `data-title`.

<img src="class item screenshot.png" alt="This is the node we are looking for!">

Now we can use the function `xml_find_all()` to find all `<div>` nodes in the body of the document that have a class name containing `chart-list-item`.  `xml_find_all()` accepts `xpath` syntax.  You can learn more about `xpath` syntax [here](https://www.w3schools.com/xml/xpath_syntax.asp):


```r
chart_items <- hot100 %>% 
  html_node("body") %>% 
  xml_find_all("//div[contains(@class, 'chart-list-item  ')]")

chart_items
```

```
## {xml_nodeset (100)}
##  [1] <div class="chart-list-item  " data-rank="1" data-artist="Lil Nas X ...
##  [2] <div class="chart-list-item  " data-rank="2" data-artist="Billie Ei ...
##  [3] <div class="chart-list-item  " data-rank="3" data-artist="Ed Sheera ...
##  [4] <div class="chart-list-item  " data-rank="4" data-artist="Shawn Men ...
##  [5] <div class="chart-list-item  " data-rank="5" data-artist="Khalid" d ...
##  [6] <div class="chart-list-item  " data-rank="6" data-artist="Lizzo" da ...
##  [7] <div class="chart-list-item  " data-rank="7" data-artist="Post Malo ...
##  [8] <div class="chart-list-item  " data-rank="8" data-artist="Jonas Bro ...
##  [9] <div class="chart-list-item  " data-rank="9" data-artist="Post Malo ...
## [10] <div class="chart-list-item  " data-rank="10" data-artist="Chris Br ...
## [11] <div class="chart-list-item  " data-rank="11" data-artist="DaBaby"  ...
## [12] <div class="chart-list-item  " data-rank="12" data-artist="Drake Fe ...
## [13] <div class="chart-list-item  " data-rank="13" data-artist="Shawn Me ...
## [14] <div class="chart-list-item  " data-rank="14" data-artist="Post Mal ...
## [15] <div class="chart-list-item  " data-rank="15" data-artist="Taylor S ...
## [16] <div class="chart-list-item  " data-rank="16" data-artist="Panic! A ...
## [17] <div class="chart-list-item  " data-rank="17" data-artist="Sam Smit ...
## [18] <div class="chart-list-item  " data-rank="18" data-artist="Blanco B ...
## [19] <div class="chart-list-item  " data-rank="19" data-artist="Ed Sheer ...
## [20] <div class="chart-list-item  " data-rank="20" data-artist="Blake Sh ...
## ...
```

Now that looks like what we want. Nice!  You'll see that these `<div>` nodes have the attributes we need, and we can draw them down individially using the `xml_attr()` function:


```r
title <- chart_items %>% 
  xml_attr("data-title")

title %>%  head(10)
```

```
##  [1] "Old Town Road"                                
##  [2] "Bad Guy"                                      
##  [3] "I Don't Care"                                 
##  [4] "Senorita"                                     
##  [5] "Talk"                                         
##  [6] "Truth Hurts"                                  
##  [7] "Goodbyes"                                     
##  [8] "Sucker"                                       
##  [9] "Sunflower (Spider-Man: Into The Spider-Verse)"
## [10] "No Guidance"
```

That's the Billboard Hot 100 Top 10!  Nice!  Now we can easy draw down the other two attributes we want and combine them all into a neat dataframe.


```r
rank <- chart_items %>% 
  xml_attr('data-rank')
  
artist <- chart_items %>% 
  xml_attr('data-artist')
  
chart_df <- data.frame(rank, artist, title)

knitr::kable(
  chart_df  %>% head(10)
)
```



rank   artist                                title                                         
-----  ------------------------------------  ----------------------------------------------
1      Lil Nas X Featuring Billy Ray Cyrus   Old Town Road                                 
2      Billie Eilish                         Bad Guy                                       
3      Ed Sheeran & Justin Bieber            I Don't Care                                  
4      Shawn Mendes & Camila Cabello         Senorita                                      
5      Khalid                                Talk                                          
6      Lizzo                                 Truth Hurts                                   
7      Post Malone Featuring Young Thug      Goodbyes                                      
8      Jonas Brothers                        Sucker                                        
9      Post Malone & Swae Lee                Sunflower (Spider-Man: Into The Spider-Verse) 
10     Chris Brown Featuring Drake           No Guidance                                   


# Making scraping easy by automating tasks

Generally we don't just scrape a single webpage for fun.  We are usually scraping because there is information that we need on a large scale or on a regular basis.  Therefore, once you have worked out how to scrape this information, you'll need to set things up in a way that it is easy to obtain it in the future.  Writing functions is often a good way of doing this.

## Example: Writing a function to grab any Billboard chart from history

If you take a look around the billboard site, you'l see that you can basically look up any chart at any date in history by simply inserting the chart name and date at the appropriate point in the URL.  For example, to see the Billboard 200 on 21st July 1972 you would navigate to https://www.billboard.com/charts/billboard-200/1972-07-21.

Since this will always produce a webpage in exactly the same structure as the one we just scraped, we can now create quite a powerful function that accepts a chart name, date and set of ranks, and returns the entries for that chart on that date in thise ranks.


```r
#' Get billboard chart entries from history
#'
#' @param date date in the form YYYY-MM-DD
#' @param positions numeric vector
#' @param type character string of chart type (as per billboard.com URLs)
#' @return a dataframe of rank, artist, title
#' @example get_chart(date = "1972-11-02", positions = c(1:100), type = "billboard-200")


get_chart <- function(date = Sys.Date(), positions = c(1:10), type = "hot-100") {

  # get url from input and read html
  input <- paste0("https://www.billboard.com/charts/", type, "/", date) 
  chart_page <- xml2::read_html(input)

  
  # scrape data
  chart <- chart_page %>% 
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//div[contains(@class, 'chart-list-item  ')]")

  rank <- chart %>% 
    xml2::xml_attr('data-rank')
  
  artist <- chart %>% 
    xml2::xml_attr('data-artist')
  
  title <- chart %>% 
    xml2::xml_attr('data-title')

  # create dataframe, remove nas and return result
  chart_df <- data.frame(rank, artist, title)
  chart_df <- chart_df %>% 
    dplyr::filter(!is.na(rank), rank %in% positions)

  chart_df

}
```

Now let's test out function by looking up the Top 10 singles from 20th January 1966:


```r
test1 <- get_chart(date = "1966-01-20", positions = 1:10, type = "hot-100")

knitr::kable(test1)
```



rank   artist                        title                                    
-----  ----------------------------  -----------------------------------------
1      Simon & Garfunkel             The Sound Of Silence                     
2      The Beatles                   We Can Work It Out                       
3      Gary Lewis And The Playboys   She's Just My Style                      
4      The Vogues                    Five O'Clock World                       
5      The Beatles                   Day Tripper                              
6      The T-Bones                   No Matter What Shape (Your Stomach's In) 
7      Mike Douglas                  The Men In My Little Girl's Life         
8      Herman's Hermits              A Must To Avoid                          
9      The Rolling Stones            As Tears Go By                           
10     The Lovin' Spoonful           You Didn't Have To Be So Nice            

## Example: Packaging `wikifacts`

Recently I thought it might be useful to have a package that generated random facts for people.  This could be helpful for scripts or apps that take a long time to execute, where you could occasionally display random facts to keep people entertained.

The Wikipedia Main Page has three predictable sections which can be reliably scraped.  So I used them to create three functions:

* `wiki_didyouknow()` which takes random facts from the 'Did you know...' section
* `wiki_onthisday()` which takes random facts from the 'On this day...' section
* `wiki_inthenews()` which takes random facts from the 'In the news...' section

A fourth function `wiki_randomfact()` executes one of the above three functions at random.  

I packaged this into a package called `wikifacts()` which can be installed from github.  Here's some examples of the functions at work:


```r
library(devtools)
devtools::install_github("keithmcnulty/wikifacts")
```

```
## Skipping install of 'wikifacts' from a github remote, the SHA1 (50ef374c) has not changed since last install.
##   Use `force = TRUE` to force installation
```

```r
library(wikifacts)

wiki_didyouknow()
```

```
## Did you know that Samuel Adalberg, pioneer of Polish paremiology, committed suicide upon learning of the Germans' plans to construct the Warsaw Ghetto? (Courtesy of Wikipedia)
```

```r
wiki_onthisday()
```

```
## Did you know that on this day in 1261 – Alexios Strategopoulos led the Nicaean forces of Michael VIII Palaiologos to recapture Constantinople, re-establish the Byzantine Empire, and end the Latin Empire. (Courtesy of Wikipedia)
```
