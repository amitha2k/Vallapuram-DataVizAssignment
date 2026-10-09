# 01_download.R
# Downloads the Billboard Hot 100 weekly chart data from TidyTuesday (2021-09-14).
# The raw file (~45 MB) is not committed to the repo; run this script to get it.

url  <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-09-14/billboard.csv"
dest <- here::here("data", "raw", "billboard.csv")

dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)

if (!file.exists(dest)) {
  options(timeout = 300)  # the file is large; allow up to 5 minutes
  download.file(url, dest, mode = "wb")
}

message("Raw data saved to ", dest)
