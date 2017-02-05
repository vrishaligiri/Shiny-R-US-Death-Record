library(dplyr)

allzips <- read.csv("data/DeathRecords_copy.csv")
allzips$latitude <- jitter(allzips$latitude)
allzips$longitude <- jitter(allzips$longitude)
allzips$zipcode <- formatC(allzips$zipcode, width=5, format="d", flag="0")

dist <- read.csv("data/dummy.csv")
disease <- dist$Disease
sex <- dist$Sex
states <- dist$LocationDesc
total <- length(unique(allzips$zipcode))