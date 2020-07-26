library(data.table)
library(foreach)

file.path = ("results_counter_07_22/econ/raw")

file_names = list.files(path=file.path, pattern=".csv", full.names = TRUE)

#need to clean up code to export data at the day level for one rep 
simulations = (lapply(file_names[1:2], fread, stringsAsFactors = FALSE))
sim = rbind(simulations[[1]], simulations[[2]])

#aggreagtes data at the month level 
summary = foreach (file = 1:length(file_names), .combine=rbind) %do% {
  simulations = fread(file = file_names[file], stringsAsFactors = FALSE)
  
  #generate date from doffy and extract month only 
  simulations[, month := month(as.Date(doffy, origin=paste0(year, "-04-30"))), by=year]
  #start fishing year May = 1 
  simulations[, month := ifelse(month < 5, month+8, month-4)]
  
  simulations[ ,c("id","hullnum", "doffy", "y") := NULL]
  
  simulations[, trips := 1]
  
  simulations = simulations[, lapply(.SD, sum, na.rm=TRUE), by=list(year, month, spstock2, gearcat, r, m)]
}

sum = copy(summary)
sum = sum[, lapply(.SD, sum, na.rm=TRUE), by=list(year, month, spstock2, gearcat, r, m)]

setnames(sum, old="r", new="nreps")

#write.csv(sum, here::here("results_2020-07-22-16-44-37", "sum_counterfactual.csv"))
#sum = read.csv(here::here("results_2020-07-22-16-44-37", "sum_counterfactual.csv"))




