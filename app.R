# Import libraries

library(shiny)
library(shinythemes)
library(tidyverse)
library(rvest)
library(knitr)
library(kableExtra)
library(XML)
library(xml2)
library(rsconnect)



ui <- navbarPage(
  theme = shinytheme("united"),
  # Application title
  title = "Top 20 IMDB Movies",
  
  mainPanel(
    tabsetPanel(
      tabPanel("Normal", tableOutput("normal"),
               downloadButton("download_normal", "Download")), 
      tabPanel("Recalculated", tableOutput("recalc"),
               downloadButton("download_recalc", "Download"))
    ),
  ),

  
  fluidRow(column(width = 2,textOutput("InfoBox")))

)


####################################
# Server                           #
####################################

server <- function(input, output) {
  
  source("top_movies.R") # Load all of the variables from the top_movies.r file
  
  # Create the df from the variables declared in source() part1
  normal_rank <- data.frame(
    Rank = top20$rank,
    Ratings = top20$ratings,
    Titles = top20$titles,
    Votes = top20$votes,
    Oscars = top20$oscar)
  
  normal <- normal_rank %>% 
    mutate(
      Ratings = cell_spec(x = Ratings, format = "html", bold = T, 
                          color = "white", 
                          background = ifelse(Ratings > mean(Ratings), "#66bf3f", "#0e5a9b"))
    ) %>%
    kable(escape = F) %>% # NOTE must have "escape = F" for HTML to render
    kable_styling(bootstrap_options = c("striped", "hover"), full_width = F)
  
  # Create the df from the variables declared in source() part2 (after recalc)
  recalc_rank <- data.frame(
    Rank = top20_updated$rank_updated,
    Change = top20_updated$rankchange,
    Ratings = top20_updated$updated_rating,
    Titles = top20_updated$titles,
    Votes = top20_updated$votes,
    Oscars = top20_updated$oscar)
  
  recalc <- recalc_rank %>% 
    mutate(
      Ratings = cell_spec(x = Ratings, format = "html", bold = T, 
                          color = "white", 
                          background = ifelse(Change > 0, "#66bf3f", "#0e5a9b"))
    ) %>%
    kable(escape = F) %>% # NOTE must have "escape = F" for HTML to render
    kable_styling(bootstrap_options = c("striped", "hover"), full_width = F)
  
  
  # Output for total movietable
  output$normal <- function(){
    normal %>% 
      scroll_box(width = "700px", height = "500px")
  }
  output$recalc <- function(){
    recalc %>% 
      scroll_box(width = "700px", height = "500px")
  }
  
  output$download_normal <- downloadHandler(
    
    filename = "normal_rank.csv",
    content = function(file) write.csv2(normal_rank, file),  # replace "times" with your data.frame to export'
    contentType = "text/csv"
    
  )
  
  output$download_recalc <- downloadHandler(
    
    filename = "recalc_rank.csv",
    content = function(file) write.csv2(recalc_rank, file),  # replace "times" with your data.frame to export'
    contentType = "text/csv"
    
  )
}


# Run the application 
shinyApp(ui = ui, server = server)