#Summarizing resutls at a monthly and daily resolution 

library(data.table)

#selects most recent file path in groundfish_MSE folder, which should be resuls_2020-... if the runsim_Econonly.R has just been run 
file_path = file.info(list.files(full.names = T))
file_path= rownames(file_path)[which.max(file_path$mtime)]

#if that does not work then the file path needs to be copied in 
file_path = "./results_2020-07-29-19-17-27/"

#selects just the econ_2020 datasets
file_names = list.files(path=paste0(file_path, "econ/raw/"), pattern = "econ_2020", full.names = TRUE)

#binding into a data.table
simulations = (lapply(file_names, fread, stringsAsFactors = FALSE))
sim = rbindlist(simulations)
sim[, trips := 1]

setnames(sim, old="r", new="nreps")
setnames(sim, old="m", new="model")

#selecting one replicate for daily resolution 
daily_summary = sim[sim$nreps==1]
daily_summary [ ,c("id","hullnum", "y") := NULL]
daily_summary = daily_summary [, lapply(.SD, sum, na.rm=TRUE), by=list(year, doffy, spstock2, gearcat, nreps, model)]

write.csv(daily_summary, paste0(file_path, "daily_summary.csv"))

#monthly resolution data 

#generate date from doffy and extract month only 
sim[, month := month(as.Date(doffy, origin=paste0(year, "-04-30"))), by=year]
#start fishing year May = 1 
sim[, month := ifelse(month < 5, month+8, month-4)]
sim[ ,c("id","hullnum", "doffy", "y") := NULL]

monthly_summary = sim[, lapply(.SD, sum, na.rm=TRUE), by=list(year, month, spstock2, gearcat, nreps, model)]

write.csv(monthly_summary, paste0(file_path, "monthly_summary.csv"))




