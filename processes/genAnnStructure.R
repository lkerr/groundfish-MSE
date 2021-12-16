

# Read in the temperature data
cmip5 <- read.csv(file = 'data/data_raw/NEUS_CMIP5_annual_meansLong.csv',
                    header=TRUE)
period <- 50
uy <- unique(cmip5$year)
piVal <- rep(seq(0, 2*pi, length.out = period),
             times = ceiling(length(uy)/period))[1:length(uy)]
newt <- scales::rescale(sin(piVal),
                        to = quantile(cmip5$Temperature, c(0.25, 0.75)))
# newt[1:125] <- 14
# newt[126:199] <- 18
# cmip5$Temperature <- newt[match(cmip5$year, uy)]
# cat('\n**********\nNOTE! temperature time series has been modified!\n**********\n')
# 
# manipulate data to get desired percentile
cmip_base <- get_temperatureSeries(cmip5, 
                                   RCP = trcp, 
                                   Model = tmods,
                                   quant = tq)
names(cmip_base) <- c('YEAR', 'T')

# Load in the temperature data for downscaling

if(stockArea == 'GB'){
  load('data/data_raw/mqt_oisst.Rdata')
  obsTemp <- mqt_oisst[,c('Year', 'q1')]
}else if(stockArea == 'GOM'){
  obsTemp <- read.csv('data/data_raw/GOMAveTemp.csv')[,c('Year', 'AveSST')]
}else{
  stop('stock area must be GB or GOM')
}

names(obsTemp) <- c('YEAR', 'T')

# Downscale from NELME to GB
cmip_dwn <- get_temperatureProj(prj_data = cmip_base, 
                                obs_data = obsTemp, 
                                ref_yrs = c(ref0, ref1))

# Get the temperature vector
msyears <- cmip_dwn$YEAR < baseTempYear
anomStd <- anomFun(cmip_dwn[msyears,'T'])  # anomoly standard

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

if(!simpleTemperature){
  anomOutName <- file.path('data', 'data_processed',
                           paste0('tAnomOut', stockArea, '.csv'))
  write.csv(tAnomOut, anomOutName, row.names = FALSE)
}


# Determine the actual years based on the available temperature data
# (and the burn-in period which 'temp' has already incorporated)

firstYear <- max(cmip5$year) - length(temp) + 1
yrs <- firstYear:mxyear
nyear <- length(yrs)

yrs_temp <- firstYear:max(cmip5$year)

# The first year that actual management will begin
fmyearIdx <- which(yrs == fmyear)

