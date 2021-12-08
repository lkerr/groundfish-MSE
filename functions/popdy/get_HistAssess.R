#' @title Historic Stock TRajectories
#' @description Read in and set up historic assessment values to inform historic stock trajectories. Currently set up mostly for cod ??? 
#' 
#' @template global_stock
#' 
#' @return ???
#' 
#' @family operatingModel ???
#' 
#' @export

### function to read in and use historic assessment values to ultimately inform historical stock trajectories

get_HistAssess <- function(stock) {
  # Stock assessment history file name
  fn <- paste('./data/data_raw/AssessmentHistory/',stockNames[i], '.csv', sep = '') #??? Probably want this to be an input data 

  # Check that assessment history information exists for the stock
  if(!file.exists(fn)){
    stop(paste0('get_HistAssess: stock \"', stockNames[i], '\" does not exist ',
               'in directory \"./data/data_raw/AssessmentHistory/\".',
               'please add it or check spelling of file names'))
  }

  # read file for the stock with historic assessment information
  assessdat <- read.csv(paste('./data/data_raw/AssessmentHistory/',stockNames[i], '.csv', sep = '')) # ??? probably want this to be an input data 
 if(stock$M_typ== 'ramp' && stock$stockName=='codGOM'){
   assessdat<- read.csv('./data/data_raw/AssessmentHistory/codGOM_highM.csv') # !!! Cod specific ???
     if (stock$M == 0.3){
     assessdat<- read.csv('./data/data_raw/AssessmentHistory/codGOM_mediumM.csv')} # ??? Cod specific
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
