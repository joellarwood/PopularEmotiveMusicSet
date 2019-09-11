# Merge annotations and information

library(readr)
library(dplyr)

annotations <- read_csv("annotations/static_annotations.csv")

song_info <- read_csv("annotations/songs_info.csv")

full_join(annotations, song_info, by = "song_id") %>% 
  write_csv("1000songsWorkingDataset.csv")
