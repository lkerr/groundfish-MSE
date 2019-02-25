


species <- 'HADDOCK' 
# 'ATLANTIC COD'
# 'HADDOCK'
# 'YELLOWTAIL FLOUNDER'

type <- 'INDWT'
# 'LENGTH'
# 'INDWT'

fun <- 'mean'
tempAgeMax <- 5 # care about temp through this age
brks <- c(-5, 4, 11)



# read in the data
load('data/data_processed/trawlBiol.Rdata') # biol
TAnomRaw <- read.table('scratch/growth/2019-01-24/anom1985.txt', 
                       header=TRUE)

tdc <- subset(biol, COMNAME == species)


yss <- substr(tdc$CRUISE, start=1, stop=4)
tdc$YEAR <- as.numeric(yss)
tdc <- tdc[!is.na(tdc$AGE),]


names(TAnomRaw)[1] <- 'YEAR'
dat <- merge(tdc, TAnomRaw)

# birth year
dat$BYEAR <- dat$YEAR - dat$AGE

sumAnom <- numeric(nrow(dat))
for(i in 1:nrow(dat)){
  
  temp <- dat[i,]
  iYears <- (temp$YEAR - temp$AGE):temp$YEAR
  iAnom <- TAnomRaw[TAnomRaw$YEAR %in% iYears,2]
  
  # Consider only the temperatures experienced over the first
  # tempAgeMax years
  iAnom <- head(iAnom, tempAgeMax+1) # +1 to account for age-0
  sumAnom[i] <- sum(iAnom)
  
}

dat$GDY <- cut(sumAnom, breaks = brks)

mla <- tapply(X = dat[,type], 
              INDEX = list(dat$AGE, dat$GDY), 
              FUN = get(fun),
              na.rm = TRUE)

cr <- colorRampPalette(c('cornflowerblue', 'firebrick1'))
cols <- cr(ncol(mla))

title <- paste0(species, ' (', fun, ') -- ', 'tempAgeMax = ', tempAgeMax)
matplot(x=mla, type='l', col=cols, main=title, 
        xlab = 'Age', ylab = type, lty=1, lwd=2)

legnms <- sapply(1:(length(brks)-1), function(i){
  paste(brks[i], 'to', brks[i+1])})
legend('bottomright', lty=1, lwd=3, col=cols, legend=legnms,
       ncol=2, cex=0.75, title='GDYAnomaly')






