#install.packages("jsonlite")


## USE THIS SCRIPT TO PARSE MULTIPLE JSON FILES RETURNED FROM THE TWITTER ACADEMIC API INTO CSV DATAFRAMES
library(jsonlite)
library(purrr)

#getwd()
data_path <- "/Users/wayne/Dropbox/Acer Laptop Sync/Data Science/Kashmir/new_data_from_TWR_academictrack/article370/"  #point to the folder that contains multiple JSON files
files <-
  list.files(
    path = file.path(data_path),
    pattern = "^article370data_",
    recursive = T,
    include.dirs = T
  )
files <- paste(data_path, files, sep = "")
files

pb = utils::txtProgressBar(min = 0,
                           max = length(files),
                           initial = 0)

json.df.all <- data.frame()
for (i in seq_along(files)) {
  filename = files[[i]]
  json.df <- jsonlite::read_json(filename, simplifyVector = TRUE)
  json.df.all <- dplyr::bind_rows(json.df.all, json.df)
  utils::setTxtProgressBar(pb, i)
}

json.df.all$repost_id = as.character(map(json.df.all$referenced_tweets, 2))
json.df.all$retweeted = as.character(map(json.df.all$referenced_tweets, 1))
json.df.all$mentions = as.character(map(json.df.all$entities$mentions, 3))   
json.df.all$hashtags = as.character(map(json.df.all$entities$hashtags, 3))  
json.df.all$urls = as.character(map(json.df.all$entities$urls, 3))  
json.df.all$retweet_count = json.df.all$public_metrics$retweet_count  
json.df.all$reply_count = json.df.all$public_metrics$reply_count  
json.df.all$like_count = json.df.all$public_metrics$like_count  
json.df.all$quote_count = json.df.all$public_metrics$quote_count  

json.df.all_ready <- json.df.all[,c("id","lang","created_at","author_id","repost_id","retweeted","source","text","conversation_id","in_reply_to_user_id","mentions","hashtags","urls","retweet_count","reply_count","like_count","quote_count")]

write.csv(json.df.all_ready,"json.df.all_ready.csv")


