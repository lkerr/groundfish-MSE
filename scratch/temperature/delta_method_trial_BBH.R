

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
bbhy <- data.frame(YEAR=as.numeric(names(bbhyv)), Tbbh=bbhyv)


# get annual median CMIP5 temperature (from suite)
cmip5y <- as.data.frame(cbind(cmip5[,1], 
                              apply(cmip5[,2:ncol(cmip5)], 1, median)),
                        stringsAsFactors = FALSE)
names(cmip5y) <- c('YEAR', 'Tcmip5')

# merge the data sets
T2 <- merge(bbhy, cmip5y, all=TRUE)

# set the year indices to calculate the anomolies by
anchor_yrs <- 1980:2017
anchor_idx <- T2$YEAR %in% anchor_yrs

# get the (anchor) mean values for bbh and cmip5
anchor_bbh <- mean(T2$Tbbh[anchor_idx], na.rm=TRUE)
anchor_cmip5 <- mean(T2$Tcmip5[anchor_idx], na.rm=TRUE)

# calculate the cmip5 anomoly
T2$cmip5_anom <- T2$Tcmip5 - anchor_cmip5

# calculate a new bbh time series using the cmip anomolies
T2$bbhT2 <- anchor_bbh + T2$cmip5_anom



# Plot the result

yrange <- with(T2, range(bbhT2, Tcmip5, Tbbh, na.rm=TRUE))
xrange <- range(cmip5y$YEAR)

par(mar=c(4,4,4,1))

plot(0, type='n' ,ylim=yrange, xlim=xrange, xlab='', ylab='', las=1)

# anchor period
rect(xleft=anchor_yrs[1], ybottom=0, xright=tail(anchor_yrs, 1), ytop=30,
     col='darkseagreen1', border='black')


lines(Tbbh ~ YEAR, data=T2, type='o', col='black', lty=3, pch=16, cex=0.5)
lines(Tcmip5 ~ YEAR, data=T2, pch=16, cex=0.5, col='slateblue', lwd=3)
lines(bbhT2 ~ YEAR, data=T2, col='firebrick1', lwd=3)
box()

legend('top', inset=-0.4, xpd=NA, ncol=2,
       legend = c('CMIP5', 'BBH hat', 'BBH obs', 'Anchor period'),
       bty='n',
       col=c('slateblue', 'firebrick1', 'black', 'black'),
       lty=c(1,1,3,NA),
       lwd = c(3, 3, 1, NA),
       pch=c(NA, NA, 16, 22),
       pt.cex = c(1, 1, 0.75, 2.5),
       pt.bg = c(NA, NA, NA, 'darkseagreen1'))

mtext(side=1:2, line=c(2.5,2.5), cex=1.25, c('Year', 'Temperature (C)'))




