

# Retrieves and processes the stock, recruit and
# temperature data to get a nice input file to go
# into the stock-recruit model file


bbh_base <- read.csv('data/1905-2017sst-3-5-18.csv', stringsAsFactors = FALSE)
sr <- read.csv('data/SAW55SR.csv')

mdy <- as.data.frame(do.call(rbind, strsplit(bbh_base$COLLECTION_DATE, split='\\/')))
qtab <- cbind(1:12, rep(1:4, each=3))
names(mdy) <- c('MONTH', 'DAY', 'YEAR')
mdy$Q <- qtab[match(as.numeric(as.character(mdy$MONTH)), qtab[,1]),2]


bbh <- cbind(mdy, bbh_base)


# get Q1 - Q4 median temp
bbhyv <- data.frame(tapply(bbh$Sea.Surface.Temp.Ave.C, 
                           INDEX=list(mdy$YEAR, mdy$Q), 
                           FUN=median, na.rm=TRUE))
bbhyv$Year <- row.names(bbhyv)
names(bbhyv) <- c('Q1', 'Q2', 'Q3', 'Q4', 'Year')










