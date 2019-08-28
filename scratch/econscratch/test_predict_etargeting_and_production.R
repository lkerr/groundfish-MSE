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
#setup yearly stuff
wm<-multipliers[[mydraw]]
wo<-outputprices[[mydraw]]
wi<-inputprices[[mydraw]]


tds_day<-(targeting_dataset[[mydraw]])[doffy==day]
tds_day<-copy(tds_day)

# bring in production coefficients
tds_day<-production_coefs[tds_day, on=c("spstock2","gearcat","post")]

# Construct Primary and Secondary
set(tds_day,i=NULL, j="primary",as.integer(1))
set(tds_day,i=NULL, j="secondary",as.integer(0))
set(tds_day,i=NULL, j="constant",as.integer(1))

# Construct Month and Year
df2<-dcast(tds_day,  id +spstock2 ~ gffishingyear , fun.aggregate = function(x) 1L, fill=0L,value.var = "gffishingyear")
df2[,c("id","spstock2"):=NULL]
colnames(df2)<-paste0("fy", colnames(df2))

df3<-dcast(tds_day,  id +spstock2 ~ MONTH, fun.aggregate = function(x) 1L, fill=0L,value.var = "MONTH")
df3[,c("id","spstock2"):=NULL]
colnames(df3)<-paste0("month", colnames(df3))

tds_day<-cbind(tds_day,df2, df3)

tds_day<-get_predict_eproduction(tds_day)

#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works

tds_day$harvest_sim[tds_day$spstock2=="nofish"]<-0
tds_day$delta<-abs(tds_day$harvest_sim-tds_day$h_hat)

summary(tds_day$delta)
#get_predict_eproduction works

tds_day$exp_rev_bak<-tds_day$exp_rev_total
# Drop unnecessary columns 
dropper<-grep("^alpha_",colnames(tds_day), value=TRUE)
tds_day[, (dropper):=NULL]

# Pull in multipliers 



tds_day<-wm[tds_day, on=c("hullnum","MONTH","spstock2","gffishingyear","post")]

# Pull in output prices
tds_day<-wo[tds_day, on=c("doffy","gffishingyear", "post")]

# Pull in input prices
tds_day<-wi[tds_day, on=c("hullnum","doffy","spstock2","gffishingyear","post")]


tds_day<-get_joint_production(tds_day,spstock2s) 
tds_day$exp_rev_total<-tds_day$exp_rev_total/1000
setcolorder(tds_day,c("exp_rev_bak","exp_rev_total"))

tds_day$exp_rev_total[tds_day$spstock2=="nofish"]<-0

tds_day$delta2<-abs(tds_day$exp_rev_total-tds_day$exp_rev_bak)
summary(tds_day$delta2)

#Works well!  
setcolorder(tds_day,c("spstock2","delta","harvest_sim","h_hat"))
setorder(tds_day,-delta2)

# can drop out extraneous columns, but the daily dataset is still pretty small
format(object.size(tds_day), units="MB")


#here, you can summary if choice==0 or choice==1
#tdss<-tds[which(tds$choice==1)]
#summary(tdss$delta)

#targeting_vars
#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this

tds_day[, fuelprice_len:=fuelprice*len]
tds_day[, fuelprice_distance:=fuelprice*distance]

setcolorder(tds_day,choice_equation)
setcolorder(tds_day,spstock_equation)


tds_day<-targeting_coefs[tds_day, on=c("gearcat","spstock2")]
#Need to set some of the betas  to zero for spstock2==nofish
# there aren't even any rows for spstock2==nofish in the targeting_coefs data.table







# spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
# choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len", "das_price_mean", "das_price_mean_len")
# 
# choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")

tds<-tds_day



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

