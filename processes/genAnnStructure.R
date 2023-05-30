# Read in the temperature data
cmip5 <- read.csv(file = 'data/data_raw/NEUS_CMIP5_annual_meansLong.csv',
                  header=TRUE)

# manipulate data to get desired percentile
cmip_base <- get_temperatureSeries(cmip5, 
                                   RCP = trcp, 
                                   Model = tmods,
                                   quant = tq)
names(cmip_base) <- c('YEAR', 'T')

# Load in the GB temperature data for downscaling
#load('data/data_raw/mqt_oisst.Rdata')
#gbT <- mqt_oisst[,c('Year', 'q1')]

#Load in the GOM temperature data for downscaling 
GOMT<-read.csv('data/data_raw/GOMAveTemp.csv')[2:3]
names(GOMT) <- c('YEAR', 'T')

# Downscale from NELME to GB
cmip_dwn <- get_temperatureProj(prj_data = cmip_base, 
                                obs_data = GOMT, 
                                ref_yrs = c(ref0, ref1))

# Get the temperature vector
msyears <- cmip_dwn$YEAR < baseTempYear
if(useTemp == TRUE){
  temp <- c(rep(anomFun(cmip_dwn[msyears,'T']), nburn),
            cmip_dwn[,'T'])
  
  # Simple temperature trend for debugging -- smooth the data
  # Use only if switch is turned on
  if(simpleTemperature){
    smidx <- 1:length(temp)
    lo <- loess(temp ~ smidx)
    temp <- predict(lo)
  }
  anomStd <- anomFun(cmip_dwn[msyears,'T'])  # anomoly standard
  Tanom <- temp - anomStd
}else{
  temp <- rep(anomFun(cmip_dwn[msyears,'T']), nburn + nrow(cmip_dwn))
  Tanom <- rep(0, nburn + nrow(cmip_dwn))
}

# output the temperature anomalies that are actually used
tAnomOut <- cbind(cmip_base,
                  DOWN_T = cmip_dwn$T,
                  TANOM = tail(Tanom, nrow(cmip_base)),
                  TANOM_STD = anomStd)

write.csv(tAnomOut, 'data/data_processed/tAnomOut.csv', row.names = FALSE)


# Determine the actual years based on the available temperature data
# (and the burn-in period which 'temp' has already incorporated)
# 
# firstYear <- max(cmip5$year) - length(temp) + 1
# yrs <- firstYear:mxyear
# nyear <- length(yrs)
# 
# yrs_temp <- firstYear:max(cmip5$year)

firstYear <- 1978
yrs <- firstYear:mxyear
nyear <- length(yrs)
yrs_temp <- firstYear:max(cmip5$year)
# The first year that actual management will begin
fmyearIdx <- which(yrs == fmyear)
