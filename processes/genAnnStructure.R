#' @title Calculate Temperature Anomalies
#' @description Calculate temperature anomalies and save as .csv file that can be provided as data input to runSim
#' 
#' @inheritParams runSetup # Inherit parameter definitions from runSetup
#'
#' @return A list containing the following:
#' \itemize{
#'   \item{tAnomOut - A matrix containing columns for "YEAR", temperature "T", downscaled temperature "DOWN_T", temperature anomaly "TANOM" and corresponding standard deviation "TANOM_STD"}
#'   \item{yrs - A vector of calendar years from firstYear to mxyear, set in processes/genAnnStructure.R}
#'   \item{nyear - The number of years based on available temperature data set in processes/genAnnStructure.R}
#'   \item{yrs_temp - A vector of years from firstYear to the maximum year in the cmip5 temperature timeseries, set in processes/genAnnStructure.R.}
#'   \item{fmyearIdx - An index for the year that management begins, from processes/genAnnStructure.R}
#' }
#'
#' @example
#' filenameCMIP = 'data/data_raw/NEUS_CMIP5_annual_meansLong.csv'
#' filenameDownscale = 'data/data_raw/GOMAveTemp.csv'
#' calc_Tanom(filenameCMIP = filenameCMIP, filenameDownscale = filenameDownscale,fmyear = 2019, ref0 = 1982, ref1 = 2020, baseTempYear = 1985)

calc_Tanom <- function(filenameCMIP = NULL, #!!!!! Will need to rename file to reflect change
                       filenameDownscale = NULL,
                       fmyear = NULL,
                       trcp = 8.5,
                       tmods = NULL,
                       tq = 0.5,
                       ref0 = NULL,
                       ref1 = NULL,
                       baseTempYear = NULL,
                       nburn = 50,
                       anomFun = median,
                       useTemp = TRUE,
                       simpleTemperature = FALSE){
  
# Read in the temperature data
cmip5 <- read.csv(file = filenameCMIP,
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
GOMT <- read.csv(filenameDownscale)[2:3]
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
  if(simpleTemperature == TRUE){
    smidx <- 1:length(temp)
    lo <- loess(temp ~ smidx)
    temp <- predict(lo)
  }
  anomStd <- anomFun(cmip_dwn[msyears,'T'])  # anomaly standard deviation
  Tanom <- temp - anomStd
} else{ # useTemp == FALSE
  temp <- rep(anomFun(cmip_dwn[msyears,'T']), nburn + nrow(cmip_dwn))
  Tanom <- rep(0, nburn + nrow(cmip_dwn))
}

# output the temperature anomalies that are actually used
tAnomOut <- cbind(cmip_base,
                  DOWN_T = cmip_dwn$T,
                  TANOM = tail(Tanom, nrow(cmip_base)),
                  TANOM_STD = anomStd)

write.csv(tAnomOut, 'data/data_processed/tAnomOut.csv', row.names = FALSE) # !!! May want this to be saved to the results directory since being updated for every simulation


# Determine the actual years based on the available temperature data
# (and the burn-in period which 'temp' has already incorporated)
firstYear <- max(cmip5$year) - length(temp) + 1
yrs <- firstYear:mxyear
nyear <- length(yrs)

yrs_temp <- firstYear:max(cmip5$year)

# The first year that actual management will begin
fmyearIdx <- which(yrs == fmyear)


# Setup return list
output <- NULL
output$tAnomOut <- tAnomOut 
output$yrs <- yrs
output$nyear <- nyear
output$yrs_temp <- yrs_temp
output$fmyearIdx <- fmyearIdx

return(output)
}
