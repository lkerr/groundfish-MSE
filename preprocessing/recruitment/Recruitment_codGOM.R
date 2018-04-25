

## Ricker recruitment models for GOM cod

## Read in the data
# boothbay harbor time series
load(file='data/data_processed/bbhT.Rdata') # bbhT
sr <- read.csv(file='data/data_raw/SAW55SR_codGOM.csv')

# Merge together the stock-recruit and temperature data
srt <- merge(sr, bbhT)
names(srt)[names(srt) == 'SSBMT_mRamp'] <- 'S'
names(srt)[names(srt) == 'A1Recruitmentx1000_mRamp'] <- 'R'
srt$R <- srt$R * 1000 # get the true recruitment


source('preprocessing/functions/recModel.R')

colY <- 1
colS <- 5
colR <- 7
colT <- 22


q3 <- recModel(data=srt, colID=c(colY, colS, colR, colT), rlag=1, 
               plot=TRUE, scl=c(1e3,1e6), 
               newT=round(seq(mean(srt[,colT])-3,
                              mean(srt[,colT])+3,length.out=3)))



# recModel(data=srt, colID=c(colY, colS, colR, colT), rlag=1, 
#          plot=TRUE, scl=c(1e3,1e6), 
#          newT=c(16,17.5))


