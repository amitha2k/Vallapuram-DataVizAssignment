# 02_clean.R
# Turns weekly chart rows into one row per song and saves a small processed file.
#
# Definitions used throughout the analysis:
#   weeks_total  = total weeks on the Hot 100, counting every re-entry
#   weeks_top40  = weeks spent at position 40 or higher
#   peak         = best (lowest-numbered) position reached
#   debut_year   = year of the song's first week on the chart
# Analysis window: songs that debuted 1959-2019. 1958 is a partial year, and
# songs debuting from 2020 had not finished their chart runs when the data ends.

library(dplyr)
library(readr)

raw <- read_csv(here::here("data", "raw", "billboard.csv"), show_col_types = FALSE)

weekly <- raw |>
  mutate(week = as.Date(week_id, format = "%m/%d/%Y"))

songs <- weekly |>
  group_by(song_id) |>
  summarise(
    song        = first(song),
    performer   = first(performer),
    debut       = min(week),
    last_week   = max(week),
    weeks_total = n(),
    weeks_top40 = sum(week_position <= 40),
    peak        = min(week_position),
    .groups = "drop"
  ) |>
  mutate(
    debut_year = as.integer(format(debut, "%Y")),
    top10      = peak <= 10,
    era        = case_when(
      debut_year <= 1990 ~ "1959-1990",
      debut_year <= 2004 ~ "1991-2004",
      debut_year >= 2010 ~ "2010-2019",
      TRUE               ~ NA_character_   # 2005-2009 is a transition period
    )
  ) |>
  filter(debut_year >= 1959, debut_year <= 2019)

dir.create(here::here("data", "processed"), recursive = TRUE, showWarnings = FALSE)
saveRDS(songs, here::here("data", "processed", "songs.rds"))

# Quick checks (should match the exploratory numbers)
message("Songs: ", nrow(songs))
songs |>
  group_by(era) |>
  summarise(n = n(),
            share_exactly_20 = mean(weeks_total == 20),
            share_exactly_1  = mean(weeks_total == 1)) |>
  print()
