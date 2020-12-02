
### function to read in and use historic assessment fishing mortality values
### .csv file in /data/data_raw/AssessmentHistory/ must have same name as stockName


get_HistAssess <- function(stock) {
  # Stock assessment history file name
  fn <- paste('./data/data_raw/AssessmentHistory/',stockNames[i], '.csv', sep = '')
  
  # Check that assessment history information exists for the stock
  if(!file.exists(fn)){
    stop(paste0('get_HistAssess: stock \"', stockNames[i], '\" does not exist ',
               'in directory \"./data/data_raw/AssessmentHistory/\".',
               'please add it or check spelling of file names'))
  }
  
  # read file for the stock with historic assessment information
  assessdat <- read.csv(fn)
  if(ncol(assessdat) != 4){
    stop('Check that Assessment History file contains appropriate data.')
  }
  colnames(assessdat)<-c('Year','F','R','M')
  assess_st_yr <-   fmyearIdx-length(assessdat$Year)
  assessdat$MSEyr <- seq(assess_st_yr, (fmyearIdx-1))
  
  return(list(
    assessdat = assessdat,
    assess_st_yr = assess_st_yr))
  }
    
