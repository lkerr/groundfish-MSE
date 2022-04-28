
# Basically a modification of the runEcon_module.

############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 

### Probably need to add the trawl survey (trawlsurvey) index here and then push over trawl survey values into the targeting dataset.  But you might do that in outside this function.
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

#set up a list to hold the expected revenue by date, hullnum, and target spstock2
annual_revenue_holder<-list()

#set up a list to hold the date, spstock2, and aggregate metrics, like open/closed status and cumulative catch
annual_fishery_status_holder<-list()
#Initialize the most_recent_target data.table. 
#This could move to preprocessing; I'll need to set one up for the entire simulation dataset (all 6 years)
# You need to save it as a .RDS and then read.  And you need to figure out what to do with your merge statements In order to keep *all*
# most_recent_target<-readRDS()
if(y == fmyearIdx){
  keepcols<-c("hullnum","spstock2","OG_choice_prev_fish")
  most_recent_target<-copy(targeting_dataset[[1]])
  most_recent_target<-most_recent_target[, ..keepcols]
  most_recent_target<-most_recent_target[spstock2!="nofish"]
  most_recent_target<-most_recent_target[OG_choice_prev_fish==1]
  setnames(most_recent_target,"OG_choice_prev_fish","targeted")
  #You should write an assert type statment that most_recent_target has >=1 rows.
}


############################################################
############################################################
# BEGIN ECON MODULE 
# Ideally, everthing from here to the end should be a function.  It's inputs are:
# fishery_holder (which should contain info on the ACL, biomass or stock indices, and which stocks need biological outputs (Catch at age or survivors at age))
# Production and targeting data
############################################################
############################################################



q_fy<-0
#for (day in 1:365){
day<-1

# On the first day of each quarter, do something 
  if (day==1 | day==91 | day==182 | day==273){
  q_fy<-q_fy+1
  print(paste("It is quarter",q_fy))
  
  # Construct RHS variables for the selection and quota price equations 
  # Extract elements of fishery_holder that you need to compute fish prices
  quarterly<-fishery_holder[,c("stocklist_index","stockName","spstock2","sectorACL","bio_model", "cumul_catch_pounds", "mults_allocated")]
  quarterly$quota_remaining_BOQ<-quarterly$sectorACL-quarterly$cumul_catch_pounds
  quarterly$quota_remaining_BOQ<-quarterly$quota_remaining_BOQ/(pounds_per_kg*kg_per_mt)
  quarterly$fraction_remaining_BOQ<-quarterly$quota_remaining_BOQ/quarterly$sectorACL
  
  #Scale to 1000s of mt
  quarterly$quota_remaining_BOQ<-quarterly$quota_remaining_BOQ/1000
  
  
  #Quarterly dummmies
  quarterly$q_fy<-q_fy
  quarterly$q_fy_1<-as.integer(q_fy==1)
  quarterly$q_fy_2<-as.integer(q_fy==2)
  quarterly$q_fy_3<-as.integer(q_fy==3)
  quarterly$q_fy_4<-as.integer(q_fy==4)
  
  # Pull in quarterly prices
  # merge quarterly prices on spstock2 and q_fy into the quarterly dataframe
  quarterly <- merge(quarterly,quarterly_prices, by=c("spstock2","q_fy"), all.x = FALSE, all.y = FALSE)

  
  # snemawinter isn't a choice. So what do we do here?
  # I guess just leave it alone?
  
  
  # 1. Split the quota_price coeffs into a selection and a badj equation. 
  
  
  
  # This is how I do it for production. It's a little easier
  
  # fyvars<-grep("^fy",colnames(prod_ds) , value=TRUE)
  # monthvars<-grep("^month",colnames(prod_ds) , value=TRUE)
  # 
  # datavars=c(production_vars,fyvars,monthvars)
  # alphavars=paste0("alpha_",datavars)
  # 
  # 
  # Z<-as.matrix(prod_ds[, ..datavars])
  # A<-as.matrix(prod_ds[,..alphavars])
  # 
  # prod_ds[, harvest_sim:=rowSums(Z*A)+q]
  # 
  
  ######################################################################
  ###################################here is the code from stata about how to do the predictions after the hurdle 
  ######################################################################
#   
#   /* doing the margins after nehurdle, by hand */		
#     
#     /* extract lnsigma and exponentiate */
#     local sig exp(_b[lnsigma:_cons])
#   
#   /* define xbs and the Inverse mills ratio */
#     local xbw xb(wage)
#     local xbs `xbw'/`sig'
# 		local IMR normalden(`xbs')/normal(`xbs')
# 		
# 		/* PSEL */
# 		/* predicted probabilities */
# 		margins, predict(psel)
# 		margins,  expression(normal(xb(selection)))
# 		
# 		/* ytrun */
# 		/* E[y|x, y>0] */
# 
# 		/* all four of these should be identical*/
# 		margins, predict(ytrun)
# 		margins, expression(`xbw'+`sig'*normalden(`xbw'/`sig')/normal(`xbw'/`sig'))
# 		margins, expression(`xbw'+`sig'*normalden(`xbs')/normal(`xbs'))
#     margins, expression(`xbw'+`sig'*`IMR')
# 
# 		
# 		/*ycen */
# 		/* E[y|x] */
# 
# 		margins, predict(ycen)
# 		margins,  expression(normal(xb(selection))*xb(wage) + `sig'*normalden(`xbs')   )
# 
  
  
  
  
  
  }
#}
    
    
  
  


#  fishery_holder will give you 
# fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","bio_model", "cumul_catch_pounds")]
# Be careful about units. The quota_price model is on 000s of mt. 
