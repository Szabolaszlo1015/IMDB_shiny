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



####################################
# User interface                   #
####################################

ui <- fluidPage(
  
  # Application title
  titlePanel("Top 20 IMDB Movies by User Rating"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(width = 2,
                 checkboxGroupInput(inputId = "choicefilter", 
                                    label = "Choose ranking method", inline = FALSE,
                                    choices = sort(c("Normal", "Review penalizer", "Oscar calculator", "Review & Oscar")), 
                                    )
                ),
    
    fluidRow(
      column(5,
             tableOutput("movieranknormal")# Total movie table
      )
            ),
  
))



server <- function(input, output) {
  
  source("top_movies.R") # Load all of the variables from the top_movies.r file
  
  # Create the movie_table from the variables declared in source()
  movie_table <- data.frame(
    Rank = top20$rank,
    Ratings = top20$ratings,
    Titles = top20$titles,
    Votes = top20$votes,
    Oscars = top20$oscar
)
  

  
  movieranknormal <- reactive({
    
    # Feed the movie table through kableExtra to produce pretty output
    movieranknormal <- movie_table %>% 
      mutate(
        Ratings = cell_spec(x = Ratings, format = "html", bold = T, 
                            color = "white", 
                            background = ifelse(Ratings > mean(Ratings), "#66bf3f", "#0e5a9b"))
      ) %>%
      kable(escape = F) %>% # NOTE must have "escape = F" for HTML to render
      kable_styling(bootstrap_options = c("striped", "hover"), full_width = F)
  })  

  
  # Output for total movietable
  output$movieranknormal <- function(){
    movieranknormal %>% 
      scroll_box(width = "550px", height = "400px")
  }
  
  # # Output for filtered movie_table_f
  # output$movietablef <- function(){
  #   movie_table_f() %>% 
  #     scroll_box(width = "550px", height = "400px")
  # }
  
  output$InfoBox <- renderText({
    "This application scrapes web data from IMDB's top 250 movies by user
        ratings."
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
