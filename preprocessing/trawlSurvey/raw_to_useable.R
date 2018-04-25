


# Initially tried to read the excel files in directly but was having
# trouble with memory because the files were too big. saved each of
# the worksheets independently as a csv and read them in directly. Made
# no changes from the original Excel files.

# file paths for the biological data and station data (including first
# part of the names of the csv)
fishpath <- 'data/data_raw/trawlSurvey/GMRI_cod_haddock_yt_1970-2016individual_fish_data'
statpath <- 'data/data_raw/trawlSurvey/GMRI_cod_haddock_yt_1970-2016station_catch_length'

# specify column classes so that leading zeros are not
# removed from ID fields like strata
ccFish <- c(rep('character', 6), rep('numeric', 2),
            rep('character', 2), 'numeric')
ccStat <- c(rep('character', 2), 'numeric', rep('character', 14),
            rep('numeric', 5), rep('character', 2),
            rep('numeric', 7), rep('character', 2),
            rep('numeric', 4))

# read in the csvs
fish1 <- read.csv(paste0(fishpath, '_1.csv'), header=TRUE, colClasses=ccFish)
fish2 <- read.csv(paste0(fishpath, '_2.csv'), header=TRUE, colClasses=ccFish)
fish3 <- read.csv(paste0(fishpath, '_3.csv'), header=TRUE, colClasses=ccFish)

stat1 <- read.csv(paste0(statpath, '_1.csv'), header=TRUE, colClasses=ccStat)
stat2 <- read.csv(paste0(statpath, '_2.csv'), header=TRUE, colClasses=ccStat)
stat3 <- read.csv(paste0(statpath, '_3.csv'), header=TRUE, colClasses=ccStat)

biol <- rbind(fish1, fish2, fish3)
stat <- rbind(stat1, stat2, stat3)

biol$STRATUM2 <- as.numeric(substr(biol$STRATUM, start=3, stop=4))
stat$STRATUM2 <- as.numeric(substr(stat$STRATUM, start=3, stop=4))


# save under processed data
save(biol, file='data/data_processed/trawlBiol.Rdata')
save(stat, file='data/data_processed/trawlStat.Rdata')


