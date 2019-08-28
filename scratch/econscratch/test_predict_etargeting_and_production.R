# some code to test "get_predict_etargeting.R" and "get_predict_eproduction.R" makes more sense to test them here, because there's some overhead from loading stuff.

# something is broken -- verify primary==1 and secondary==0?  Check if things work for choice==1

# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
econ_timer<-0
set.seed(2)
mproc_bak<-mproc
mproc<-mproc_bak[1,]
nrep<-1
## For each replicate and mproc, I need to randomly pull in some simulation data.
####################End Temporary changes for testing ####################

random_sim_draw <-as.data.table(cbind(1:nyear, sample(1:6, eyears, replace=T),sample(1:6, eyears, replace=T)))
colnames(random_sim_draw)<-c("simyear","pricedraw","otherdraw")

mydraw<-6
day<-1
#setup yearly stuff THIS GOES INTO THE TOP YEAR LOOP AREA
wm<-multipliers[[mydraw]]
wo<-outputprices[[mydraw]]
wi<-inputprices[[mydraw]]







working_targeting<-(targeting_dataset[[mydraw]])[doffy==day]
working_targeting<-copy(working_targeting)

# bring in production coefficients
working_targeting<-production_coefs[working_targeting, on=c("spstock2","gearcat","post")]

# Construct Primary and Secondary
set(working_targeting,i=NULL, j="primary",as.integer(1))
set(working_targeting,i=NULL, j="secondary",as.integer(0))
set(working_targeting,i=NULL, j="constant",as.integer(1))

# Construct Month and Year
df2<-dcast(working_targeting,  id +spstock2 ~ gffishingyear , fun.aggregate = function(x) 1L, fill=0L,value.var = "gffishingyear")
df2[,c("id","spstock2"):=NULL]
colnames(df2)<-paste0("fy", colnames(df2))

df3<-dcast(working_targeting,  id +spstock2 ~ MONTH, fun.aggregate = function(x) 1L, fill=0L,value.var = "MONTH")
df3[,c("id","spstock2"):=NULL]
colnames(df3)<-paste0("month", colnames(df3))

working_targeting<-cbind(working_targeting,df2, df3)

working_targeting<-get_predict_eproduction(working_targeting)

#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works

working_targeting$harvest_sim[working_targeting$spstock2=="nofish"]<-0
working_targeting$delta<-abs(working_targeting$harvest_sim-working_targeting$h_hat)

summary(working_targeting$delta)
#get_predict_eproduction works

working_targeting$exp_rev_bak<-working_targeting$exp_rev_total
# Drop unnecessary columns 
dropper<-grep("^alpha_",colnames(working_targeting), value=TRUE)
working_targeting[, (dropper):=NULL]

# Pull in multipliers 



working_targeting<-wm[working_targeting, on=c("hullnum","MONTH","spstock2","gffishingyear","post")]

# Pull in output prices
working_targeting<-wo[working_targeting, on=c("doffy","gffishingyear", "post")]

# Pull in input prices
working_targeting<-wi[working_targeting, on=c("hullnum","doffy","spstock2","gffishingyear","post")]


    working_targeting<-get_joint_production(working_targeting,spstock2s) 
    working_targeting[, exp_rev_total:=exp_rev_total/1000]
setcolorder(working_targeting,c("exp_rev_bak","exp_rev_total"))

working_targeting$exp_rev_total[working_targeting$spstock2=="nofish"]<-0

working_targeting$delta2<-abs(working_targeting$exp_rev_total-working_targeting$exp_rev_bak)
summary(working_targeting$delta2)

#Works well!  
setcolorder(working_targeting,c("spstock2","delta","harvest_sim","h_hat"))
setorder(working_targeting,-delta2)

# can drop out extraneous columns, but the daily dataset is still pretty small
format(object.size(working_targeting), units="MB")


#here, you can summary if choice==0 or choice==1
#tdss<-tds[which(tds$choice==1)]
#summary(tdss$delta)

#targeting_vars
#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this

working_targeting[, fuelprice_len:=fuelprice*len]
working_targeting[, fuelprice_distance:=fuelprice*distance]

setcolorder(working_targeting,choice_equation)
setcolorder(working_targeting,spstock_equation)


working_targeting<-targeting_coefs[working_targeting, on=c("gearcat","spstock2")]
#Need to set some of the betas  to zero for spstock2==nofish
# there aren't even any rows for spstock2==nofish in the targeting_coefs data.table







# spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
# choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len", "das_price_mean", "das_price_mean_len")
# 
# choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")

tds<-working_targeting



part3<-0
sa<-Sys.time()

#code to test function. Remove when done.
predicted_trips<-get_predict_etargeting(tds)
#targeting_dataset<-cbind(phat,targeting_dataset)

test<-predicted_trips[,..datavars] 
summary(test)




predicted_trips[, del:=prhat-pr]
summary(predicted_trips$del)

setcolorder(predicted_trips,c("id", "prhat", "pr", "del", "xb"))
setorder(predicted_trips,-del)
# This actually works too!
#We see maximum differences of magnitude 0.08 (7 hundredths of a pound), which is probably due to rounding differences. 
#I think stata will use quad precision internally, but only export in double precisions.  This is NBD.








#We see maximum differences of magnitude .001 (A tenth of 1%), which is probably due to rounding differences.  I think stata will use quad precision internally, but only export in double precisions.  This is NBD.
# 
# predicted_trips <- predicted_trips %>%
#   select(xb,prhat, pr, del, spstock2, exp_rev_total, das_charge, fuelprice_distance, distance, mean_wind, mean_wind_noreast, permitted, lapermit ,partial_closure ,start_of_season, wkly_crew_wage, len, fuelprice, fuelprice_len, everything())
#  
# predicted_trips<-predicted_trips[order(-predicted_trips$del),]

# sb<-Sys.time()
# part3<-part3+sb-sa
# 
# predicted_trips <- predicted_trips %>% 
#   group_by(hullnum,date) %>%
#   filter(prhat == max(prhat)) 
# 
# 
# #Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  
# 
# saveRDS(predicted_trips, file=file.path(savepath, "trips_combined.Rds"))

