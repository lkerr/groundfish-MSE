#load in targeting data

#rm(list=ls())
# set.seed(2) 

# empty the environment
rm(list=ls())

source('processes/runSetup.R')
source('processes/loadEcon.R')

library(data.table)


library(microbenchmark)

econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))




############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea")]
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0

revenue_holder<-NULL

#METHOD 2-  DATA.TABLE is winning so far

dtstyle <- function() {
  
  for (day in 1:365){
    #This comes in as a data.table now
    
    
    tds<-targeting_dataset[[day]]

    tds[, csum := cumsum(prhat), by = id]
    
    #make one draw per id, then replicate it nchoices time and place it into tds$draw
    tdss<-unique(tds[,c("id","nchoices")])
    td<-runif(nrow(tdss), min = 0, max = 1)
    tds$draw<-rep(td,tdss$nchoices)
    
    #Foreach id, keep the row for which draw is the smallest value that is greater than csum
    
    tds<-tds[tds$draw<tds$csum,]
    tds<-tds[tds[, .I[1], by = id]$V1] 
    
  }
}


# 
tidystyle <- function() {
  for (day in 1:365){
    #This comes in as a data.table now
    
    tds<-targeting_dataset[[day]]
    tds[, csum := cumsum(prhat), by = id]
    
    #make one draw per id, then replicate it nchoices time and place it into tds$draw
    tdss<-unique(tds[,c("id","nchoices")])
    td<-runif(nrow(tdss), min = 0, max = 1)
    tds$draw<-rep(td,tdss$nchoices)
    
    tds<-tds[tds$draw<tds$csum,]
    
    tds <-
      tds %>% 
      group_by(id) %>% 
      filter(row_number()==1)
    
    }
  
  
}

microbenchmark(ans_dtstyle<-dtstyle(), ans_tidy <- tidystyle(), times=10)




#This takes a while
# tds <-
#   tds %>% 
#   group_by(id) %>% 
#   filter(row_number()==1)


