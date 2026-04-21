### function to read in and use historic assessment values to ultimately inform historical stock trajectories

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
  assessdat <- read.csv(paste('./data/data_raw/AssessmentHistory/',stockNames[i], '.csv', sep = ''))
 if(stock$M_typ== 'ramp' && stock$stockName=='codGOM'){
   assessdat<- read.csv('./data/data_raw/AssessmentHistory/codGOM_highM.csv')
     if (stock$M == 0.3){
     assessdat<- read.csv('./data/data_raw/AssessmentHistory/codGOM_mediumM.csv')}
 }
 if(ncol(assessdat) != 4){
    stop('Check that Assessment History file contains appropriate data.')
  }
  colnames(assessdat)<-c('Year','F','R','M')
  assess_st_yr <- fmyearIdx-length(assessdat$Year)
  assessdat$MSEyr <- seq(assess_st_yr, (fmyearIdx-1))

  
  ##### Read in NAA deviations if a stock-specific file exists in the data directory
  fn2 <- paste('./data/data_raw/AssessmentHistory/',stockNames[i], '_NAAdeviations.csv', sep = '')
  
  # If historical NAA deviations exist for the stock, read them in
  if(file.exists(fn2)){
    devs <- read.csv(fn2) %>% 
      mutate(age = as.numeric(str_remove(age, "Age ")),
             re = case_when(age == 1 ~ 0, .default = re)) %>%  # set age 1 deviation to 0. We use the estimated age 1 trajectory, which already incorporates for the deviation
      left_join(select(assessdat, year = Year, MSEyr), by = "year")
      
      }
  
  if(!exists("devs")){ cat(paste0("get_HistAssess: stock ", stockNames[i],
                    " does not have historical survival deviations in ./data/data_raw/AssessmentHistory.",
                    " Assuming historical survival deviations of 0"))}
  
  return(list(
    assessdat = assessdat,
    assess_st_yr = assess_st_yr,
        NAA_deviations = get0("devs", ifnotfound = NULL)))
  }
