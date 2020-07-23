
### function to read in and use historic assessment fishing mortality values
### .csv file in /data/data_raw/AssessmentHistory/ must have same name as stockName


get_HistAssess <- function(stock) {
  # read file for the stock with historic assessment information
  assessdat <- read.csv(paste('./data/data_raw/AssessmentHistory/',stockNames[i], '.csv', sep = ''))
  if(ncol(assessdat) != 4){
    stop('Check that Assessment History file contains appropriate data.')
  }
  assess_st_yr <-   fmyearIdx-length(assessdat$Year)
  assessdat$MSEyr <- seq(assess_st_yr, (fmyearIdx-1))
  
  return(list(
    assessdat = assessdat,
    assess_st_yr = assess_st_yr))
  }
    
