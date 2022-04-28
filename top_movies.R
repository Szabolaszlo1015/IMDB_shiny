
## Table Analytics==============================================================

# Establishing the URL we want to scrape data from
url <- "https://www.imdb.com/chart/top"
webpage <- read_html(url)

# Using rvest and html_nodes in combination with the Google Chrome Selector Gadget
# Ratings, titles, votes, number of Oscars

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


top250 <- data.frame(titles, ratings, votes, movie.link)
top20 <- head(top250, 20)

# #read all urls & store the values
# url1 <- as.character(top20$movie.link)

# # Looping starts here 
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


