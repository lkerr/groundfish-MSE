#' Get raw data and prepare for Plan B smooth
#' 
#' Reads in csv file with Year in first column and as many survey indices as desired, standardizes series if desired, computes mean of all or user selected surveys, outputs csv file with Year and Mean Index.
#' @param data.dir directory with csv file
#' @param data.file.name name of csv file (without the .csv extension)
#' @param od directory for output (default=working directory)
#' @param standardize true/false flag to divide by mean of time series (default=FALSE)
#' @param usesurvey vector of true/false to select surveys to average (default=NA which means use all)
#' @param saveplots true/false flag to save output to od (default=FALSE)
#' @export
 
ReadRaw <- function(data.dir, 
                    data.file.name,
                    od               = ".\\",
                    standardize      = FALSE,
                    usesurvey        = NA,
                    saveplots        = FALSE){
  
  raw.dat <- read.csv(paste0(data.dir,"\\",data.file.name,".csv"))
  
  # get some basic info about raw.dat
  cnames <- colnames(raw.dat)
  ncols <- length(cnames)
  
  # check for Year in first column
  if(cnames[1] != "Year" & cnames[1] != "YEAR"){
    return("Header of first column not Year or YEAR, please check to ensure correct file defined")
  }
  
  # print to screen the survey names in order to facilitate usesurvey variable
  print(cbind(1:(ncols-1), cnames[2:ncols]))
  
  # standardize each column, other than year of course, if desired
  raw.s <- raw.dat
  if(standardize == TRUE){
    for (i in 2:ncols){
      raw.s[,i] <- raw.dat[,i] / mean(raw.dat[,i], na.rm=T)
    }
  }
  
  # keep only used surveys, then average
  if(is.na(sum(usesurvey))) usesurvey <- rep(TRUE, (ncols - 1))
  colvals <- 2:ncols
  raw.a <- raw.s[, (colvals * usesurvey)] # tricky way to pick the surveys
  if(sum(usesurvey) == 0) return("No surveys selected, change usesurvey option and try again.")
  if(sum(usesurvey) == 1) raw.avg <- data.frame(Year = raw.dat[,1],
                                                avg = raw.a)
  if(sum(usesurvey) >= 2) raw.avg <- data.frame(Year = raw.dat[,1],
                                                avg = apply(raw.a, 1, mean) )

  # save csv file of averaged values
  if(saveplots) write.csv(raw.avg, 
                          file=paste0(od,"raw_converted_average_",data.file.name,".csv"), 
                          row.names = FALSE)
  
  return(raw.avg)

}
  
