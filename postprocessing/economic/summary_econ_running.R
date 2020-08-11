#Summarizing econ results at a monthly resolution.

# This is pretty janky. But if you don't summarize as you go along, you'll end up with a massive dataset.  
# Instead of reading everything in, then summarizing, you'll read in a dataset, summarize it and store it in a list. Then concatenate all the lists together.
# The result csv's may or may not contain an entire replicate; but they will contain entire fishing years.
library(data.table)

#selects most recent file path in groundfish_MSE folder, which should be resuls_2020-... if the runsim_Econonly.R has just been run 

file_path = file.info(list.files(full.names = T))
file_path= rownames(file_path)[which.max(file_path$mtime)]

#if that does not work then the file path needs to be copied in 
file_path = "./results_2020-08-11-10-41-12/"

#selects just the econ_2020 datasets
file_names = list.files(path=file.path(file_path, "econ","raw"), pattern = "econ_2020", full.names = TRUE)

#binding into a data.table
simulations<-list()

for(r in 1:length(file_names)){

sim<-fread(file_names[r], stringsAsFactors = FALSE)
sim[, trips := 1]

setnames(sim, old="r", new="replicate")
setnames(sim, old="m", new="model")

#selecting one replicate for daily resolution 
#daily_summary = sim[sim$replicate==1]
#daily_summary [ ,c("id","hullnum", "y") := NULL]
#daily_summary = daily_summary [, lapply(.SD, sum, na.rm=TRUE), by=list(year, doffy, spstock2, gearcat, replicate, model)]

#write.csv(daily_summary, paste0(file_path, "daily_summary.csv"))

#monthly resolution data 

#generate date from doffy and extract month only 
sim[, month := month(as.Date(doffy, origin=paste0(year, "-04-30"))), by=year]
#start fishing year May = 1 
sim[, month := ifelse(month < 5, month+8, month-4)]
sim[ ,c("id","hullnum", "doffy", "y") := NULL]

monthly_summary = sim[, lapply(.SD, sum, na.rm=TRUE), by=list(year, month, spstock2, gearcat, replicate, model)]

simulations[[r]]<-monthly_summary
}


monthly_summary <- rbindlist(simulations)

write.csv(monthly_summary, file.path(file_path, "monthly_summary.csv"))






#read in stock status




file_names = list.files(path=file.path(file_path, "econ","raw"), pattern = "econ_stock_status", full.names = TRUE)




#binding into a data.table
stock_status<-list()

for(r in 1:length(file_names)){

  sim<-fread(file_names[r], stringsAsFactors = FALSE)

  setnames(sim, old="r", new="replicate")
 # setnames(sim, old="m", new="model")
  
  stock_status[[r]]<-sim
}


stock_status_stacked <- rbindlist(stock_status)

write.csv(stock_status_stacked, file.path(file_path, "stock_status_stacked_troubleshoot.csv"))






