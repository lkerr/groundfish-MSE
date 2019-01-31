

species <- 'YELLOWTAIL FLOUNDER' 
           # 'ATLANTIC COD'
           # 'HADDOCK'
           # 'YELLOWTAIL FLOUNDER'

fun <- 'sd'


# read in the data
load('data/data_processed/trawlBiol.Rdata') # biol
TAnomRaw <- read.table('scratch/growth/2019-01-24/anom1985.txt', 
                       header=TRUE)

tdc <- subset(biol, COMNAME == species)


yss <- substr(tdc$CRUISE, start=1, stop=4)
tdc$YEAR <- as.numeric(yss)


names(TAnomRaw)[1] <- 'YEAR'
dat <- merge(tdc, TAnomRaw)


brks <- c(-10, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 10)
Tf <- cut(dat$Tanom, breaks = brks)
mat <- tapply(dat$LENGTH, INDEX = list(dat$AGE, Tf), FUN=get(fun))
cr <- colorRampPalette(c('cornflowerblue', 'firebrick1'))
cols <- cr(ncol(mat))

title <- paste0(species, ' (', fun, ')')
matplot(x=mat, type='l', col=cols, main=title, 
        xlab = 'Age', ylab = 'Length', lty=1, lwd=2)

legnms <- sapply(1:(length(brks)-1), function(i){
            paste(brks[i], 'to', brks[i+1])})
legend('bottomright', lty=1, lwd=3, col=cols, legend=legnms,
       ncol=2, cex=0.75, title='Anomaly')

