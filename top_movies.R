


## Table Analytics==============================================================

# Establishing the URL we want to scrape data from
url <- "https://www.imdb.com/chart/top"
webpage <- read_html(url)

# Using rvest and html_nodes in combination with the Google Chrome Selector Gadget
# Ratings, titles, votes, number of Oscars, movie links

ratings <- webpage %>% 
  html_nodes("div strong") %>% 
  html_text() %>% 
  as.numeric()

ratings <- ratings[!ratings > 10.0] # remove numeric values captures not in range
ratings <- ratings[!is.na(ratings)] # remove all NAs introduced

titles <- webpage %>% 
  html_nodes(".titleColumn a") %>% 
  html_text() 

titles <- titles[!titles == " "] # remove all blank values

rating.nodes = html_nodes(webpage,'.imdbRating strong')
votes = as.numeric(gsub(',','',
                        gsub(' user ratings','',
                             gsub('.*?based on ','',
                                  sapply(html_attrs(rating.nodes),`[[`,'title')
                             ))))

movie.nodes <- html_nodes(webpage,'.titleColumn a')
movie.link = sapply(html_attrs(movie.nodes),`[[`,'href')
movie.link = paste0("http://www.imdb.com",movie.link)

# Generating ranks
rank = seq(1, 250, 1)

# Making a dataframe and pick the first 20 rows
top250 <- data.frame(rank, titles, ratings, votes)
top20 <- head(top250, 20)

# Manually caculated number of Oscars (could not find out how to extract this data from html)
oscar <- c(0,3,2,6,0,7,11,1,4,0,6,0,4,2,1,4,1,5,0,0)
top20$oscar <-oscar

# #read all urls & store the values
# url1 <- as.character(top20$movie.link)

# # Looping (does not work)
# movie.db <- lapply(url1,function(x) {  
#   
#   page <- read_html(x)
#   
#   oscar<- page %>% 
#       html_node(xpath = "main/div/section[1]/div/section/div/div[1]/section[1]/div/ul/li/a[1]") %>% 
#       html_text
#   
#   mov.total <- data.frame(oscar)
#   
# })
# 
# page <- read_html("https://www.imdb.com/title/tt2119532/awards/?ref_=tt_awd")
# 
# oscar <- page %>% 
#   html_node(page, ".award_category")

# penalizer after number of votes
top20_updated <- data.frame(top20)

maxvotes = max(top20_updated$votes)

review_penalizer <- floor((top20_updated$votes - maxvotes)/100000)*0.1
top20_updated$review_penalizer <- c(review_penalizer)








# Function to calculate new ranking based on number of Oscars

oscarfunc <- function(x) {
  if (x == 0) {
    result <- 0
  }
  else if (x >= 1 & x <= 2) {
    result <- 0.3
  }
  else if (x >= 3 & x <= 5) {
    result <- 0.5
  }
  else if (x >= 6 & x <= 10) {
    result <- 1
  }
  else if (x > 10 ) {
    result <- 1.5
  }
  else {
    result <- "NA"
  }
  return(result)
}

result_oscar <- unlist(lapply(top20_updated$oscar, oscarfunc))

top20_updated$oscar_corr <- c(result_oscar)

# update ratings
newrating <- (top20_updated$ratings + top20_updated$review_penalizer + top20_updated$oscar_corr)
top20_updated$updated_rating <- c(newrating)


# calculating changes in ratings

sort.by.column <- function(df, column.name) {
  df[order(df[,column.name], decreasing = T ),]
}  

top20_updated <- sort.by.column(top20_updated, "updated_rating")

rank_updated = seq(1, 20, 1)
top20_updated$rank_updated <- rank_updated

