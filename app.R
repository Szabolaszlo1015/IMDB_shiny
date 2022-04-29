# Import libraries

library(shiny)
library(shinythemes)
library(tidyverse)
library(rvest)
library(knitr)
library(kableExtra)
library(highcharter)
library(viridisLite)
library(XML)
library(xml2)
library(rsconnect)



####################################
# User interface                   #
####################################

ui <- fluidPage(
  # Application title
  titlePanel("Top 20 IMDB Movies"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(width = 1,
                 checkboxGroupInput(inputId = "choicefilter", 
                                    label = "Select ranking method(s)", inline = FALSE,
                                    choices = sort(c("Normal", "Recalculated")), 
                 )
    ),
    
    fluidRow(
      column(4,
             tableOutput("normal")# Total movie table
      )
      )
    )
  )
  
  fluidRow(column(width = 2,textOutput("InfoBox")))
  



####################################
# Server                           #
####################################

server <- function(input, output) {
  
  source("top_movies.R") # Load all of the variables from the top_movies.r file
  
  # Create the movie_table from the variables declared in source()
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
  
  
  # Output for total movietable
  output$normal <- function(){
    normal %>% 
      scroll_box(width = "550px", height = "400px")
  }
  
  output$InfoBox <- renderText({
    "This application scrapes web data from IMDB's top 250 movies by user
        ratings."
  })
  

  
}


# Run the application 
shinyApp(ui = ui, server = server)
