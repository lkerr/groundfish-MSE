# Collect biological parameters for the economic model
# There are *many* biological parameters stored in the stock lists
# This collects a few of them into lists that are easier to pass to the economic model


# So far, I just need stockName, SSB, ACL, and 

# Outer list is stocks 
# Inner list is parameters inside

# This subsets stock to just the few metrics that I care about

# myfields<-c("stockName","ACL", "SSB", "IN","waa")
# mybio<-lapply(X = stock, FUN = `[`, myfields)

get_bio_for_econ=function(stock){
  sn<-lapply(X = stock, FUN = `[[`, "stockName")
  
  #This stacks all the the metrics into individual lists
  ACL<-lapply(X = stock, FUN = `[`, "ACL")
  ACL<-lapply(X = ACL, FUN = `[`, y+1)
  
  SSB<-lapply(X = stock, FUN = `[[`, "SSB")
  SSB<-lapply(X = SSB, FUN = `[`, y)
  
  #IN and waa have a row vector per year
  waa<-lapply(X = stock, FUN = `[[`, "waa")
  waa<-lapply(X = waa, FUN = `[`, y,)
  
  trawlsurvey<-lapply(X = stock, FUN = `[[`, "IN")
  trawlsurvey<-lapply(X = trawlsurvey, FUN = `[`, y,)
  
  #multiply together
  trawlsurvey<-mapply(function(x, y) x%*%y, trawlsurvey, waa)
  
  ACL[is.na(ACL)]<-0
  
  df<-do.call(rbind,lapply(sn,data.frame))
  df<-cbind(df,do.call(rbind,lapply(trawlsurvey,data.frame)))
  df<-cbind(df,do.call(rbind,lapply(SSB,data.frame)))
  df<-cbind(df,do.call(rbind,lapply(ACL,data.frame)))
  colnames(df)<-c("spstock2","trawlsurvey","SSB","ACL")
  rownames(df)<- c()
  df$spstock2<- as.character(df$spstock2)
  return(df)
}