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

firstYear <- max(cmip5$year) - length(temp) + 1
yrs <- firstYear:mxyear
nyear <- length(yrs)

yrs_temp <- firstYear:max(cmip5$year)

# The first year that actual management will begin
fmyearIdx <- which(yrs == fmyear)


####### overwrite temp and Tanom with MOM6 values for new stocks
####### Keep the same number of years as CMIP so that Burn-IN works properly

# Check if there is a stock-specific temperature file
checkfiles <- list.files(path = "data/data_processed", full.names = T)
if(any(str_detect(checkfiles, stockNames))){
  MOM6 <- data.frame(year = yrs_temp) %>% 
    left_join(
      read.csv(checkfiles[str_detect(checkfiles, stockNames)]) %>%
        dplyr::filter(SSP == "SSP245",
                      Metric == "SST") %>% 
        select(year = Year, temp = Mean_Temperature, Tanom = Temp_Anomaly)
      )

  temp <- MOM6$temp
  Tanom <- MOM6$Tanom
  
  ### Fill NAs with the mean of first 10  non-NA values
  temp[is.na(temp)] <- MOM6 %>% drop_na() %>% head(n= 20) %>% pull(temp) %>% mean()
  Tanom[is.na(Tanom)] <- MOM6 %>% drop_na() %>% head(n= 20) %>% pull(Tanom) %>% mean()
}






