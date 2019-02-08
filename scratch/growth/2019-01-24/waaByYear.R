

species <- 'YELLOWTAIL FLOUNDER' 
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



datWt <- subset(dat, YEAR > 1991)

mla <- tapply(X = datWt[,type], 
              INDEX = list(datWt$AGE, datWt$YEAR), 
              FUN = get(fun),
              na.rm = TRUE)

cr <- colorRampPalette(c('cornflowerblue', 'firebrick1'))
cols <- cr(ncol(mla))

title <- paste0(fun, ' WAA: ', species)
matplot(x=mla, type='l', col=cols, main=title, 
        xlab = 'Age', ylab = type, lty=1, lwd=2)

legnms <- sapply(1:(length(brks)-1), function(i){
  paste(brks[i], 'to', brks[i+1])})
legend('topleft', lty=1, lwd=3, col=c(cols[1], tail(cols, 1)), 
       legend=range(datWt$YEAR),
       ncol=2, cex=0.75, title='Year')


yrs <- unique(datWt$YEAR)
lwpar_list <- list()
newL <- seq(from = min(datWt$LENGTH), 
            to = max(datWt$LENGTH), 
            by = 1)
newW_list <- list()

for(i in 1:length(yrs)){
  
  temp <- subset(datWt, YEAR == yrs[i])
  lwmod <- nls(INDWT ~ a * LENGTH^b, 
               data = temp, 
               start = c(a=0.00001, b=3))
  cmod <- coef(lwmod)
  lwpar_list[[i]] <- cmod
  
  newW_list[[i]] <- cmod['a'] * newL ^ cmod['b']
}
lwpar <- do.call(rbind, lwpar_list)
newW <- do.call(rbind, newW_list)


cr <- colorRampPalette(c('cornflowerblue', 'firebrick1'))
cols <- cr(nrow(newW))

matplot(x = newL,
        y = t(newW),
        col = cols,
        lty = 1,
        lwd = 2,
        type = 'l',
        xlab = 'Length',
        ylab = 'Weight',
        las = 1,
        main = species)

legend('topleft', lty=1, lwd=3, col=c(cols[1], tail(cols, 1)), 
       legend=range(datWt$YEAR),
       ncol=2, cex=1.25, title='Year')
