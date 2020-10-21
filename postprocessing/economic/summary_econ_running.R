#Summarizing econ results at a monthly resolution.

# This is pretty janky. But if you don't summarize as you go along, you'll end up with a massive dataset.  
# Instead of reading everything in, then summarizing, you'll read in a dataset, summarize it and store it in a list. Then concatenate all the lists together.
# The result csv's may or may not contain an entire replicate; but they will contain entire fishing years.
library(data.table)


#Follow this naming pattern
#monthly_summary_validation_modelstuffhere.csv
#stock_status_validation_modelstuffhere.csv

#filenames for results
#econ_out_csv<-"monthly_summary_counterfactual_closeown.csv"
#stock_status_out_csv<-"stock_status_counterfactual_closeown.csv"
econ_out_csv<-"monthly_summary_counterfactual_closemult.csv"
stock_status_out_csv<-"stock_status_counterfactual_closemult.csv"
#econ_out_csv<-"monthly_summary_validation1.csv"
#stock_status_out_csv<-"stock_status_validation1.csv"

#selects most recent file path in groundfish_MSE folder that starts with "results_" 
file_path = file.info(list.files(path=".",pattern="^results_*",include.dirs=TRUE,full.names = T,recursive=TRUE))
file_path= rownames(file_path)[which.max(file_path$mtime)]
file_path="./results_2020-10-20-10-45-24"

#selects just the econ_2020 datasets
file_names = list.files(path=file.path(file_path, "econ","raw"), pattern = "econ_2020", full.names = TRUE)

#binding into a data.table
simulations<-list()
file_nums<-length(file_names)
for(file in 1:file_nums){

sim<-fread(file_names[file], stringsAsFactors = FALSE)
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

simulations[[file]]<-monthly_summary
}


monthly_summary <- rbindlist(simulations)
table(monthly_summary$replicate, monthly_summary$model)
#monthly_summary <- monthly_summary[replicate>90]

#Verifying econ results before saving
#source("postprocessing/economic/verify_econ_result.R")
#verify_econ_results(monthly_summary = monthly_summary)



write.csv(monthly_summary, file.path(file_path, econ_out_csv))





#read in stock status




file_names = list.files(path=file.path(file_path, "econ","raw"), pattern = "econ_stock_status", full.names = TRUE)


#binding into a data.table
stock_status<-list()


#don't read the last file name
file_nums<-length(file_names)

for(file in 1:file_nums){
  
  
  sim<-fread(file_names[file], stringsAsFactors = FALSE)

  setnames(sim, old="r", new="replicate")
 # setnames(sim, old="m", new="model")
  
  stock_status[[file]]<-sim
}



stock_status <- rbindlist(stock_status)
#stock_status <- stock_status[replicate>90]

stock_status[,c("bio_model","SSB","mults_allocated","sectorACL"):=NULL]
# 1 row per  per year, spstock2, replicate, model,
# Either the last day of the year OR the first day where the stock_area was closed or the acl was reached

stock_status<-stock_status[(underACL==FALSE | doffy==365 | stockarea_open==FALSE)]

stock_status<-stock_status[, head(.SD, 1), by = c("year","spstock2","replicate","m")]

write.csv(stock_status, file.path(file_path, stock_status_out_csv))






