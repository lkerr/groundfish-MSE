


## Read in the data
load(file='data/data_processed/gbT.Rdata') # gbT
srGB <- read.csv(file='data/data_raw/SAW55SR_codGB.csv')
load(file='data/data_processed/bbhT.Rdata') # bbhT
srGOM <- read.csv(file='data/data_raw/SAW55SR_codGOM.csv')


srGB$RS <- srGB$A1Recruitmentx1000 / srGB$SSBMT
srGOM$RS <- srGOM$A1Recruitmentx1000_mRamp / srGOM$SSBMT_mRamp


gb <- merge(srGB, gbT)
gom <- merge(srGOM, bbhT)

plot(RS ~ q3, data=gb)
plot(RS ~ q3, data=gom)

cr <- colorRamp(c('blue', 'red'))
range01 <- function(x){
  (x-min(x, na.rm=TRUE))/(max(x, na.rm=TRUE)-min(x, na.rm=TRUE))
}
scaledGBT <- range01(gb$q3)
scaledGOMT <- range01(gom$q3)
scaledGBT[is.na(scaledGBT)] <- 0
scaledGOMT[is.na(scaledGOMT)] <- 0

GBTcol <- rgb(cr(scaledGBT) / 255)
GOMcol <- cr(scaledGOMT) / 255

plot(A1Recruitmentx1000 ~ SSBMT, data=gb, col=GBTcol, pch=16)
plot(A1Recruitmentx1000_mRamp ~ SSBMT_mRamp, data=gom, col=GBTcol, pch=16)

