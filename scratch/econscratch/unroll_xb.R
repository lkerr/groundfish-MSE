
# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
library(microbenchmark)
#library(Rcpp)
econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))
#make sure there is a nofish in bio_params_for_econ

m<-1
econtype<-mproc[m,]
myvars<-c("LandZero","CatchZero","EconType")
econtype<-econtype[myvars]
############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)

subset<-0 
eproduction<-0
eproduction2<-0
prep_target_join<-0
prep_target_dc<-0
etargeting<-0
zero_out<-0
randomdraw<-0
holder_update_flatten <-0
next_period_flatten2 <-0
runtime<-0
holder_update_flatten2<-0
loop_start<-proc.time()
revenue_holder<-as.list(NULL)

# z<-function(){
set.seed(2)

# end setups


 day<-30

 working_targeting<-copy(targeting_dataset[[day]])
 get_predict_eproduction(working_targeting)
 
 wt<-copy(working_targeting) 
 wt2<-copy(working_targeting) 
 
wt3<-copy(working_targeting) 
spstock_names<-copy(spstock2s)
#spstock_names<-spstock_names[1:4]




#this fastest way to do it. 50% speedup over the current export to matrix although, probably depends on the size of X and B. 
fastest <- function(wt,spstock_names){
  
  catches<-paste0("c_",spstock_names)
  #  landings<-paste0("l_",spstock_names)
  
  quotaprices<-paste0("q_",spstock_names)
  #  lagp<-paste0("p_",spstock_names)
  #  prices<-paste0("r_",spstock_names)
  
  
  #overwrite the c_ multiplier with catch in pounds
  for(j in catches){
    set(wt, i=NULL, j=j, value=wt[[j]]*wt[['harvest_sim']])
  }

  
  my.formula<-NULL 
  for(idx in 1:length(catches)){
    my.formula<- paste0(my.formula,catches[idx],"*",quotaprices[idx],"+")
  }
  my.formula<-substr(my.formula,1,nchar(my.formula)-1)
  #my.formula<-paste0(my.formula,"]")

  my.formula<-str2lang(my.formula)
  wt[, quota_cost:=eval(my.formula)]
  
}

#this is a function that mimics the way we are currently doing things.
basic <- function(wt,spstock_names){
  
  catches<-paste0("c_",spstock_names)
#  landings<-paste0("l_",spstock_names)
  
  quotaprices<-paste0("q_",spstock_names)
#  lagp<-paste0("p_",spstock_names)
#  prices<-paste0("r_",spstock_names)
  
  
  #overwrite the c_ multiplier with catch in pounds
  for(j in catches){
    set(wt, i=NULL, j=j, value=wt[[j]]*wt[['harvest_sim']])
  }
  
  #compute quota costs of a choice  
  Z<-as.matrix(wt[, ..quotaprices])
  A<-as.matrix(wt[,..catches])
  wt[, quota_cost:=rowSums(Z*A)]
}


#this is a function that mimics the way we are currently doing things.
explicit <- function(wt,spstock_names){
  
  catches<-paste0("c_",spstock_names)
  #  landings<-paste0("l_",spstock_names)
  
  quotaprices<-paste0("q_",spstock_names)
  #  lagp<-paste0("p_",spstock_names)
  #  prices<-paste0("r_",spstock_names)
  
  
  #overwrite the c_ multiplier with catch in pounds
  for(j in catches){
    set(wt, i=NULL, j=j, value=wt[[j]]*wt[['harvest_sim']])
  }
  
  my.formula<-NULL
  for(idx in 1:length(catches)){
    my.formula<- paste0(my.formula,"+",catches[idx],"*",quotaprices[idx])
  }
  my.formula<-substr(my.formula,2,nchar(my.formula))

  #compute quota costs of a choice  
  wt[, quota_cost:=c_americanlobster*q_americanlobster+c_americanplaiceflounder*q_americanplaiceflounder+c_codGB*q_codGB+c_codGOM*q_codGOM+c_haddockGB*q_haddockGB+c_haddockGOM*q_haddockGOM+c_monkfish*q_monkfish+c_other*q_other+c_pollock*q_pollock+c_redsilveroffshorehake*q_redsilveroffshorehake+c_redfish*q_redfish+c_seascallop*q_seascallop+c_skates*q_skates+c_spinydogfish*q_spinydogfish+c_squidmackerelbutterfishherring*q_squidmackerelbutterfishherring+c_summerflounder*q_summerflounder+c_whitehake*q_whitehake+c_winterflounderGB*q_winterflounderGB+c_winterflounderGOM*q_winterflounderGOM+c_witchflounder*q_witchflounder+c_yellowtailflounderCCGOM*q_yellowtailflounderCCGOM+c_yellowtailflounderGB*q_yellowtailflounderGB+c_yellowtailflounderSNEMA*q_yellowtailflounderSNEMA]
}



#this is a function that mimics the way we are currently doing things.
loopget <- function(wt,spstock_names){
  
  catches<-paste0("c_",spstock_names)
  #  landings<-paste0("l_",spstock_names)
  
  quotaprices<-paste0("q_",spstock_names)
  #  lagp<-paste0("p_",spstock_names)
  #  prices<-paste0("r_",spstock_names)
  
  
  #overwrite the c_ multiplier with catch in pounds
  for(j in catches){
    set(wt, i=NULL, j=j, value=wt[[j]]*wt[['harvest_sim']])
  }
  
  
  wt$quota_cost<-0
  for (i in 1:length(cNames)){
   wt[, quota_cost := quota_cost+ get( catches[i])*get( quotaprices[i]) ]
  }
 
}




microbenchmark(ans_sq<-basic(wt,spstock_names), ans_exp<-explicit(wt2,spstock_names), alm<-fastest(wt3,spstock_names), times=5000)





#These two come out equal
Z<-as.matrix(wt[, ..quotaprices])
A<-as.matrix(wt[,..catches])
wt[, quota_cost2:=rowSums(Z*A)]


my.formula<-NULL 
for(idx in 1:length(catches)){
  my.formula<- paste0(my.formula,catches[idx],"*",quotaprices[idx],"+")
}
my.formula<-substr(my.formula,1,nchar(my.formula)-1)
#my.formula<-paste0(my.formula,"]")

my.formula<-str2lang(my.formula)
wt[, quota_cost:=eval(my.formula)]


#compute quota costs of a choice  
wt[, quota_cost3:=c_americanlobster*q_americanlobster+c_americanplaiceflounder*q_americanplaiceflounder+c_codGB*q_codGB+c_codGOM*q_codGOM+c_haddockGB*q_haddockGB+c_haddockGOM*q_haddockGOM+c_monkfish*q_monkfish+c_other*q_other+c_pollock*q_pollock+c_redsilveroffshorehake*q_redsilveroffshorehake+c_redfish*q_redfish+c_seascallop*q_seascallop+c_skates*q_skates+c_spinydogfish*q_spinydogfish+c_squidmackerelbutterfishherring*q_squidmackerelbutterfishherring+c_summerflounder*q_summerflounder+c_whitehake*q_whitehake+c_winterflounderGB*q_winterflounderGB+c_winterflounderGOM*q_winterflounderGOM+c_witchflounder*q_witchflounder+c_yellowtailflounderCCGOM*q_yellowtailflounderCCGOM+c_yellowtailflounderGB*q_yellowtailflounderGB+c_yellowtailflounderSNEMA*q_yellowtailflounderSNEMA]

setcolorder(wt,c("quota_cost", "quota_cost2", "quota_cost3"))




dt <- data.table(c_1= c(1,2,3,4,5,6,7,8,9),
                 q_1 = c(100,150,200,180,10,15,11,25,1),
                 c_2 = c(150,200,250,300,15,20,19,30,2),
                 q_2 = c(100,101,102,103,104,105,106,107,109))
dt3<-copy(dt)
dt3$var4<-0

cNames <- c("c_1", "c_2")
qNames <- c("q_1", "q_2")



for(j in Names){
  set(dt, i = NULL, j = j, value = (dt[[j]] - mean(dt[[j]],
                                                   na.rm = TRUE)/sd(dt[[j]], na.rm = TRUE)))
}
