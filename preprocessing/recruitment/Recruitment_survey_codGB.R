

# age of recruits
recage <- 1


## Ricker recruitment models for GB cod

## Read in the data
# boothbay harbor time series
load(file='data/data_processed/gbT.Rdata') # gbT
# sr <- read.csv(file='data/data_raw/SAW55SR_codGB.csv')
load(file='data/data_processed/trawlBiol.Rdata') #biol
load(file='data/data_processed/trawlStat.Rdata') #stat

### Subset out the species and spatial range data you want
biol <- subset(biol, STRATUM2 >= 13 & STRATUM2 <= 25 & 
                     SVSPP == 073)
stat <- subset(stat, STRATUM2 >= 13 & STRATUM2 <= 25 & 
                     SVSPP == 073)


# Get maturity and sampled spawner biomass columns

# get maturity ogive (obrien burnett and mayo 1993 ...
# see file ParametersLit.xlsx). Just for GB females right
# now as a q&d start
mogive <- function(a, b, len){
  1 / (1 + exp(-(a+b*len)))
}
stat$mat <- mogive(a=-4.932, b=0.127, len=stat$LENGTH)
stat$ssb <- stat$mat * stat$EXPANDED_CATCH_WT

### Generate age-length keys from the biological sampling
### data

# load in the age length key functions
source('preprocessing/recruitment/functions/get_alk.R')
source('preprocessing/recruitment/functions/get_ages.R')

# get the year information from cruise field
biol$YEAR <- as.numeric(substr(biol$CRUISE, start=1, stop=4))

# generate the annual keys
yrs <- unique(biol$YEAR)
alk <- list()
for(i in 1:length(yrs)){
  
  # subset the data by year
  dsub <- subset(biol, YEAR == yrs[i])
  
  # get a matrix of ages an dlengths
  almat <- cbind(dsub$AGE, dsub$LENGTH)
  almat <- almat[complete.cases(almat),]
  
  # get the age-length key for that year
  if(!is.null(nrow(almat)) && nrow(almat)>0){
    alk[[i]] <- get_alk(almat, 5, 5)
  }else{
    alk[[i]] <- NA
  }
}


### Apply the age-length keys
SR <- matrix(data=NA, nrow=length(yrs), ncol=3)
for(i in 1:length(yrs)){
  
  if(!is.na(alk[[i]][1])){
  
  # subset the data by year
  dsub <- subset(stat, YEAR==yrs[i]) 
  
  # expand out the observed lengths into a vector where
  # each value is a length record
  len <- rep(dsub$LENGTH, dsub$EXPANDED_NUMBER_AT_LENGTH)
  
  # Apply the age length key for that year to the vector of lengths
  ages <- get_ages(alk=alk[[i]], lengths=len, vector=FALSE)
  
  # Get the total sampled spawner biomass for that year
  ssb <- sum(dsub$ssb)

  # Fill in the stock-recruit matrix
  SR[i,] <- c(yrs[i], ssb, ages[as.character(recage)])
  
  }else{
    SR[i,] <- NA
  }
  
}

SR <- as.data.frame(SR)
names(SR) <- c('Year', 'S', 'R')

srt <- merge(SR, gbT)

source('preprocessing/recruitment/functions/recModel.R')

colY <- 1
colS <- 2
colR <- 3
colT <- 18

q3 <- recModel(data=srt, colID=c(colY,colS,colR,colT), rlag=recage, 
               plot=TRUE, scl=c(1,1e3), 
               newT=round(seq(mean(srt[,colT],na.rm=TRUE)-3,
                              mean(srt[,colT],na.rm=TRUE)+3,length.out=3)))


# recModel(data=srt, colID=c(colY, colS, colR, colT), rlag=1,
#          plot=TRUE, scl=c(1e3,1e6),
#          newT=c(17.5,19))




