#' Get ADIOS! data and prepare for Plan B smooth
#' 
#' Reads in ADIOS! csv file (ADIOS_SV_speciesitis_stock_sex_strat_mean.csv), standardizes series if desired, computes mean of all or user selected surveys, outputs csv file with Year and Mean Index.
#' @param data.dir directory with csv file
#' @param adios.file.name name of ADIOS! csv file (without the .csv extension)
#' @param od directory for output (default=working directory)
#' @param standardize true/false flag to divide by mean of time series (default=FALSE)
#' @param usesurvey vector of true/false to select surveys to average (default=NA which means use all)
#' @param saveplots true/false flag to save output to od (default=FALSE)
#' @export

ReadADIOS <- function(data.dir, 
                      adios.file.name,
                      od                = ".\\",
                      standardize       = FALSE,
                      usesurvey         = NA,
                      saveplots         = FALSE){
  
  adios.dat <- read.csv(paste0(data.dir,"\\",adios.file.name,".csv"))

  # check to make sure ADIOS! file
  if(colnames(adios.dat)[1] != "COMMON_NAME"){
    return("This does not appear to be an ADIOS! file, please check to ensure correct file defined")
  }
  
  # convert adios.dat to format that could be read by ReadRaw 
  adios.r <- filter(adios.dat, INDEX_TYPE=="Biomass (kg/tow)") %>%   # select biomass data only
    mutate(Year = ifelse(SEASON=="FALL",YEAR+1,YEAR),                # shift Fall data ahead 1 year
           PurposeSurvey = paste(PURPOSE_CODE,SURVEY)) %>%           # create survey+season variable
    select(Year, PurposeSurvey, INDEX) %>%                           # keep only needed variables
    spread(key=PurposeSurvey, value=INDEX)                           # convert long to wide format

  # print to screen the survey names in order to facilitate usesurvey variable
  cnames <- colnames(adios.r)
  ncols <- length(cnames)
  print(cbind(1:(ncols-1), cnames[2:ncols]))
  
  # save the ReadRaw formatted file
  if(saveplots) write.csv(adios.r, 
                          file=paste0(od,"adios_converted_data_", 
                                      adios.dat$SPECIES_ITIS[1],"_",
                                      adios.dat$STOCK_ABBREV[1],".csv"), row.names=FALSE)

  # standardize each column, other than year of course, if desired
  adios.s <- adios.r
  
  if(standardize == TRUE){
    for (i in 2:ncols){
      adios.s[,i] <- adios.r[,i] / mean(adios.r[,i], na.rm=T)
    }
  }
  
  # calculate row averages of selected columns
  if(is.na(sum(usesurvey))) usesurvey <- rep(TRUE, (ncols - 1))
  colvals <- 2:ncols
  adios.a <- adios.s[, (colvals * usesurvey)] # tricky way to pick the surveys
  if(sum(usesurvey) == 0) return("No surveys selected, change usesurvey option and try again.")
  if(sum(usesurvey) == 1) adios.avg <- data.frame(Year = adios.r[,1],
                                                  avg = adios.a)
  if(sum(usesurvey) >= 2) adios.avg <- data.frame(Year = adios.r[,1],
                                                  avg = apply(adios.a, 1, mean) )

  # save csv file of averaged values
  if(saveplots) write.csv(adios.avg, 
                          file=paste0(od,"adios_converted_average_",adios.file.name,".csv"), 
                          row.names = FALSE)
  
  return(adios.avg)
  
} 
