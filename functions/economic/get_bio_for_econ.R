# Collect biological parameters for the economic model into a dataframe. 
# Do a little processing to construct ACLs for the sector fleet
# There are *many* biological parameters stored in the stock lists
# This collects a few of them into lists that are easier to pass to the economic model

# trawlsurvey extraction not working, might be a timing thing. 
# myfields<-c("stocklist_index","stockName","spstock2", ACL", "SSB", "IN","waa")

get_bio_for_econ=function(stock,basecase){
  sn<-lapply(X = stock, FUN = `[[`, "stockName")
  
  #This stacks all the the metrics into individual lists
  ACL<-lapply(X = stock, FUN = `[[`, "ACL_kg") #This needs to be changed to "ACL" once the containers change.
  ACL<-lapply(X = ACL, FUN = `[`, y)
  
  SSB<-lapply(X = stock, FUN = `[[`, "SSB")
  SSB<-lapply(X = SSB, FUN = `[`, y)
  
  #IN and waa have a row vector per year
  waa<-lapply(X = stock, FUN = `[[`, "waa")
  waa<-lapply(X = waa, FUN = `[`, y)
  
  trawlsurvey<-lapply(X = stock, FUN = `[[`, "IN")
  trawlsurvey<-lapply(X = trawlsurvey, FUN = `[`, y)
  
  #multiply together
  trawlsurvey<-mapply(function(x, y) x%*%y, trawlsurvey, waa)
  
  # Hack the ACL to 1e6 mt if it is null
  ACL<-replace(ACL, sapply(ACL, is.null), 1e6) 
  
  #Stack these into a dataframe and give the columns good names
  biocontain<-do.call(rbind,lapply(sn,data.frame))
  biocontain<-cbind(c(1:nrow(biocontain)),biocontain)
  biocontain<-cbind(biocontain,do.call(rbind,lapply(trawlsurvey,data.frame)))
  biocontain<-cbind(biocontain,do.call(rbind,lapply(SSB,data.frame)))
  biocontain<-cbind(biocontain,do.call(rbind,lapply(ACL,data.frame)))
  biocontain<-cbind(biocontain,1)
  colnames(biocontain)<-c("stocklist_index","stockName","trawlsurvey","SSB","ACL","bio_model")
  biocontain$stockName<- as.character(biocontain$stockName)
  #Parse the stockName column
  biocontain<-separate(biocontain,stockName,into=c("spstock2","variant"), sep="_", remove=FALSE, fill="right")
  biocontain$spstock2<- as.character(biocontain$spstock2)
  
  #Pull in baseline ACLs from historical data, mark rows that have a biological model, and compute the sector and non-sector ACLs
  rownames(biocontain)<- c()
  biocontain<-merge(biocontain,basecase,by="spstock2",all=TRUE)
  biocontain<-within(biocontain, ACL[is.na(ACL)] <- baselineACL_mt[is.na(ACL)])
  
  biocontain<-within(biocontain, bio_model[is.na(bio_model)] <- 0)
             
  biocontain$sectorACL<-biocontain$ACL*biocontain$sector_frac
  biocontain$nonsector_catch_mt<-biocontain$ACL*(1-biocontain$sector_frac)
  
  return(biocontain)
}