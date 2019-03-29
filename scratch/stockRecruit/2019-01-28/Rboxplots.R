

srh_base <- read.csv('scratch/stockRecruit/2019-01-28/HAD_S_R.csv', 
                header=TRUE)

srp_base <- read.csv('scratch/stockRecruit/2019-01-28/POL_S_R.csv', 
                header=TRUE)
srp_base <- srp_base[,-ncol(srp_base)]

sry_base <- read.csv('scratch/stockRecruit/2019-01-28/YTF_S_R.csv', 
                header=TRUE)

src_base <- read.csv('data/data_raw/SAW55SR_codGB.csv')


TAnomRaw <- read.table('scratch/growth/2019-01-24/anom1985.txt', 
                       header=TRUE)
names(TAnomRaw)[1] <- 'Year'
TAnom <- subset(TAnomRaw, Year >= 1960 & Year <= 2016)

sry <- merge(TAnomRaw, sry_base)
  names(sry)[3] <- 'R'
  names(sry)[4] <- 'S'
srh <- merge(TAnomRaw, srh_base)
  names(srh)[3] <- 'R'
  names(srh)[4] <- 'S'
srp <- merge(TAnomRaw, srp_base)
  names(srp)[4] <- 'R'
  names(srp)[3] <- 'S'
src <- merge(TAnomRaw, src_base)
  names(src)[6] <- 'R'
  names(src)[4] <- 'S'



bpfun <- function(dat, title){
  medS <- median(dat$S)
  medT <- median(dat$Tanom)
  catS <- ifelse(dat$S < medS, 'lowS', 'highS')
  catT <- ifelse(dat$Tanom < medT, 'lowT', 'highT')
  # datLowS <- dat[catS == 'lowS',]
  # datHighS <- dat[catS == 'highS',]
  
  splDat <- split(dat, list(catS, catT))
  
  boxplot(NA, xlim=c(0,5), ylim=range(dat$R, na.rm=TRUE), main=title)
  axis(1, at=1:4, labels = NA)
  order <- c(4,2,3,1)
  mtext(text=names(splDat), at=order, las=2, side=1, line=0.5)
  for(i in order){
    boxplot(splDat[[i]]$R, add=TRUE, at=i)
  }
  abline(v=2.5, lty=3, lwd=3, col='gray40')
  mtext(side=3, line=-1, adj=c(0.05,0.95), 
        text=c('low stock', 'high stock'))
}


# Function for overplotting recruitment and temp trajectories
# 2-axis plot -- very different scales
trajFun <- function(dat, title){
  par(mar = c(5,6,2,4))
  plot(R ~ Year, 
       data = dat,
       las = 1,
       xlab = '',
       ylab = '',
       type = 'o',
       pch = 16)
  par(new = TRUE)
  plot(Tanom ~ Year, 
       data = dat,
       type = 'o',
       pch = 16,
       col = 'blue',
       ann = FALSE,
       axes = FALSE)
  axis(side = 4,
       las = 1)
  abline(h=0, col='blue', lty=3)
  
  mtext(text = 'Year', side = 1, line = 3, cex = 1.5)
  mtext(text = 'Recruitment', side = 2, line = 4, cex = 1.5)
  mtext(text = 'Temp Anomaly', side = 4, line = 2.5, cex = 1.5)
  mtext(text = title, side = 3, line = 0.5, cex = 1.5)
}




bpfun(dat = sry, title = 'YTF')
bpfun(dat = srh, title = 'Haddock')
bpfun(dat = srp, title = 'Pollock')
bpfun(dat = src, title = 'Cod')

trajFun(dat = sry, title = 'YTF')
trajFun(dat = srh, title = 'Haddock')
trajFun(dat = srp, title = 'Pollock')
trajFun(dat = src, title = 'Cod')
