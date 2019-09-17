# Merge annotations and information

library(tidyverse)
library(fuzzyjoin)

annotations <- read_csv("annotations/static_annotations.csv")

song_info <- read_csv("annotations/songs_info.csv") 

workingset <- full_join(annotations, song_info, by = "song_id") %>% 
  rename("arousal_1000songs" = "mean_arousal",
         "std_arousal_1000songs" = "std_arousal",
         "valence_1000songs" = "mean_valence",
         "std_valence_1000songs" = "std_valence")

write_csv(workingset, "datasets/1000songsWorkingDataset.csv")

# download spotify data 

library(spotifyr)

access_token <- get_spotify_access_token()

username1000songs <- "bpytj0hs8n7d0s63c418l5b1q"

playlist1000songs <- "44p9Ff4hJm7Rdnmwi11pvt"


Info1000songs <- spotifyr::get_playlist_audio_features(username1000songs, playlist1000songs) %>% 
  mutate(spotifytitle = track.name,
         Song_title = track.name) %>%
  select(track.name,
         Song_title,
         danceability,
         energy,
         key,
         key_name,
         loudness,
         mode,
         mode_name,
         speechiness,
         acousticness,
         instrumentalness,
         liveness,
         valence,
         tempo, 
         track.id,
         track.preview_url,
         track.uri
         )
  
  

write_csv(Info1000songs, "datasets/Spotify1000songsplaylist.csv")

#Join spotify songs with 1000song dataset 

fuzzyspotifyjoin <- fuzzyjoin::stringdist_full_join(workingset, 
                                                    Info1000songs,
                                                    by = "Song_title", 
                                                    max_dist = 1, 
                                                    method = "lcs", 
                                                    distance_col = "lcsDist") %>% 
  select(track.name,
         Song_title.x, 
         Artist,
         Genre,
         file_name,
         song_id,
         danceability,
         energy,
         key,
         key_name,
         loudness,
         mode,
         mode_name,
         speechiness,
         acousticness,
         instrumentalness,
         liveness,
         valence,
         valence_1000songs,
         std_valence_1000songs,
         arousal_1000songs, 
         std_arousal_1000songs,
         tempo, 
         track.id,
         track.preview_url,
         track.uri
  ) %>% 
  distinct(song_id, .keep_all = TRUE)
  

write_csv(fuzzyspotifyjoin, "datasets/AutoJoined1000SongsSpotify.csv")

