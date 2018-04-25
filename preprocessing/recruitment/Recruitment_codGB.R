

## Ricker recruitment models for GB cod

## Read in the data
load(file='data/data_processed/gbT.Rdata') # gbT
sr <- read.csv(file='data/data_raw/SAW55SR_codGB.csv')

# Merge together the stock-recruit and temperature data
srt <- merge(sr, gbT)
names(srt)[names(srt) == 'SSBMT'] <- 'S'
names(srt)[names(srt) == 'A1Recruitmentx1000'] <- 'R'
srt$R <- srt$R * 1000 # get the true recruitment


source('preprocessing/functions/recModel.R')

colY <- 1
colS <- 3
colR <- 5
colT <- 20

q3 <- recModel(data=srt, colID=c(colY,colS,colR,colT), rlag=1, 
               plot=TRUE, scl=c(1e3,1e6), 
               newT=round(seq(mean(srt[,colT],na.rm=TRUE)-3,
                              mean(srt[,colT],na.rm=TRUE)+3,length.out=3)))


# recModel(data=srt, colID=c(colY, colS, colR, colT), rlag=1,
#          plot=TRUE, scl=c(1e3,1e6),
#          newT=c(17.5,19))


