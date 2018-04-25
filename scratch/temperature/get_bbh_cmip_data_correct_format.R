

### read in the data
bbh <- read.csv('data/1905-2017sst-3-5-18.csv', stringsAsFactors = FALSE)
cmip5 <- read.table('data/NEUS_CMIP5_annual_means.txt', header=TRUE, skip=2)


### get annual median BBH temperature
# start by splitting out into month / day / year
mdy <- as.data.frame(do.call(rbind, strsplit(bbh$COLLECTION_DATE, split='\\/')))
names(mdy) <- c('MONTH', 'DAY', 'YEAR')

# find the annual median bbh temperature
bbhyv <- tapply(bbh$Sea.Surface.Temp.Ave.C, INDEX=mdy$YEAR, 
                FUN=median, na.rm=TRUE)
# merge into a bbh data frame
bbhy <- data.frame(YEAR=as.numeric(names(bbhyv)), T=bbhyv)


# get annual median CMIP5 temperature (from suite)
cmip5y <- as.data.frame(cbind(cmip5[,1], 
                              apply(cmip5[,2:ncol(cmip5)], 1, median)),
                        stringsAsFactors = FALSE)
names(cmip5y) <- c('YEAR', 'T')

write.csv(cmip5y, file='C:/Users/struesdell/Desktop/cmip5.csv', 
            row.names=FALSE)
write.csv(bbhy, file='C:/Users/struesdell/Desktop/bbh.csv', 
            row.names=FALSE)

x <- get_temperatureProj(prj_data = cmip5y, obs_data = bbhy,
                         anchor_yrs = c(2000, 2017), 
                         centralFun = mean, plot=TRUE)


