library(tuber)
library(tidyverse)

id <- Sys.getenv('id')
key <- Sys.getenv('key')
yt_oauth(app_id = id,
         app_secret = key,
         token = '')
informacoes <- get_all_channel_video_stats('UCD5VUiNxflMhmJgmh5TO14Q')
informacoes %>% arrange(publication_date) %>% write_csv("links.csv")
