### function to read in and use historic assessment values

get_HistAssess <- function(stock) {
  # read file for the stock with historic assessment information
  assessdat <- read.csv(paste('./data/data_raw/AssessmentHistory/',stockNames[i], '.csv', sep = ''))
 if(stock$M_typ== 'ramp' && stock$stockName=='codGOM'){
   assessdat<- read.csv('./data/data_raw/AssessmentHistory/codGOM_highM.csv')
 }
 if(ncol(assessdat) != 4){
    stop('Check that Assessment History file contains appropriate data.')
  }
  colnames(assessdat)<-c('Year','F','R','M')
  assess_st_yr <- fmyearIdx-length(assessdat$Year)
  assessdat$MSEyr <- seq(assess_st_yr, (fmyearIdx-1))
  
  return(list(
    assessdat = assessdat,
    assess_st_yr = assess_st_yr))
  }
    
