

## script to get annual monthly and quarterly median values
## for temperature from the boothbay harbor time series


## Read in the data
# boothbay harbor time series
bbh_base <- read.csv('data/data_raw/1905-2017sst-3-5-18.csv', 
                     stringsAsFactors = FALSE)


# split the dates into M/D/Y columns
mdy <- as.data.frame(do.call(rbind, 
                             strsplit(bbh_base$COLLECTION_DATE, 
                                      split='\\/')))

# assign a column for quarters
qtab <- cbind(1:12, rep(1:4, each=3))
names(mdy) <- c('Month', 'Day', 'Year')
mdy$Q <- qtab[match(as.numeric(as.character(mdy$Month)), qtab[,1]),2]


# attach the M/D/Y/quarter information to the bbh temp data
bbh_mdyq <- cbind(mdy, bbh_base)


library(reshape2)

bbh <- dcast(bbh_mdyq, 
             formula = Year ~ Month,
             value.var = 'Sea.Surface.Temp.Ave.C',
             fun.aggregate = median, na.rm=TRUE)

bbh <- cbind(Year=bbh[,1], bbh[,2:13][,order(as.numeric(names(bbh[2:13])))])

names(bbh)[2:ncol(bbh)] <- paste0('m', names(bbh)[2:ncol(bbh)])

qmean <- function(m){
  nms <- paste0('m', m)
  sapply(1:nrow(bbh), function(x) mean(unlist(bbh[x,nms])))
}

bbh$q1 <- qmean(m=1:3)
bbh$q2 <- qmean(m=4:6)
bbh$q3 <- qmean(m=7:9)
bbh$q4 <- qmean(m=10:12)

bbhT <- bbh
save(bbhT, file='data/data_processed/bbhT.Rdata')



