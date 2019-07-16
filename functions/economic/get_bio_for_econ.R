# Collect biological parameters for the economic model into a dataframe. 
# Do a little processing to construct ACLs for the sector fleet
# There are *many* biological parameters stored in the stock lists
# This collects a few of them into lists that are easier to pass to the economic model

# trawlsurvey extraction not working.

# So far, I just need stockName, SSB, ACL.  
# Outer list is stocks 
# Inner list is parameters inside

# This subsets stock to just the few metrics that I care about

# myfields<-c("stockName","ACL", "SSB", "IN","waa")
# mybio<-lapply(X = stock, FUN = `[`, myfields)

get_bio_for_econ=function(stock,basecase){
  sn<-lapply(X = stock, FUN = `[[`, "stockName")
  
  #This stacks all the the metrics into individual lists
  ACL<-lapply(X = stock, FUN = `[[`, "ACL")
  ACL<-lapply(X = ACL_kg, FUN = `[`, y)
  
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
  
  df<-do.call(rbind,lapply(sn,data.frame))
  df<-cbind(c(1:nrow(df)),df)
  df<-cbind(df,do.call(rbind,lapply(trawlsurvey,data.frame)))
  df<-cbind(df,do.call(rbind,lapply(SSB,data.frame)))
  df<-cbind(df,do.call(rbind,lapply(ACL_kg,data.frame)))
  df<-cbind(df,1)
  colnames(df)<-c("stocklist_index","stockName","trawlsurvey","SSB","ACL","bio_model")
  df$stockName<- as.character(df$stockName)

  df<-separate(df,stockName,into=c("spstock2","variant"), sep="_", remove=FALSE, fill="right")
  df$spstock2<- as.character(df$spstock2)
  
  rownames(df)<- c()
  df<-merge(df,basecase,by="spstock2",all=TRUE)
  df<-within(df, ACL[is.na(ACL)] <- baselineACL[is.na(ACL)])
  
  df<-within(df, bio_model[is.na(bio_model)] <- 0)
             
  df$sectorACL<-df$ACL*df$sector_frac
  df$nonsector_catch_kg<-df$ACL*(1-df$sector_frac)
  
  return(df)
}