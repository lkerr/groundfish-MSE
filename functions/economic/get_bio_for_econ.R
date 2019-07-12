# Collect biological parameters for the economic model into a dataframe. 
# Do a little processing to construct ACLs for the sector fleet
# There are *many* biological parameters stored in the stock lists
# This collects a few of them into lists that are easier to pass to the economic model


# So far, I just need stockName, SSB, ACL.  
# Outer list is stocks 
# Inner list is parameters inside

# This subsets stock to just the few metrics that I care about

# myfields<-c("stockName","ACL", "SSB", "IN","waa")
# mybio<-lapply(X = stock, FUN = `[`, myfields)

get_bio_for_econ=function(stock,basecase){
  sn<-lapply(X = stock, FUN = `[[`, "stockName")
  
  #This stacks all the the metrics into individual lists
  ACL_kg<-lapply(X = stock, FUN = `[[`, "ACL")
  ACL_kg<-lapply(X = ACL_kg, FUN = `[`, y+1)
  
  SSB<-lapply(X = stock, FUN = `[[`, "SSB")
  SSB<-lapply(X = SSB, FUN = `[`, y)
  
  #IN and waa have a row vector per year
  waa<-lapply(X = stock, FUN = `[[`, "waa")
  waa<-lapply(X = waa, FUN = `[`, y,)
  
  trawlsurvey<-lapply(X = stock, FUN = `[[`, "IN")
  trawlsurvey<-lapply(X = trawlsurvey, FUN = `[`, y,)
  
  #multiply together
  trawlsurvey<-mapply(function(x, y) x%*%y, trawlsurvey, waa)
  
  # Hack the ACL to 1e12 kg if it is null
  ACL_kg<-replace(ACL_kg, sapply(ACL_kg, is.null), 1e12) 
  
  df<-do.call(rbind,lapply(sn,data.frame))
  df<-cbind(df,do.call(rbind,lapply(trawlsurvey,data.frame)))
  df<-cbind(df,do.call(rbind,lapply(SSB,data.frame)))
  df<-cbind(df,do.call(rbind,lapply(ACL_kg,data.frame)))
  colnames(df)<-c("stockName","trawlsurvey","SSB","ACL_kg")
  df$stockName<- as.character(df$stockName)

  df<-separate(df,stockName,into=c("spstock2","variant"), remove=FALSE, fill="right")
  df$spstock2<- as.character(df$spstock2)
  
  rownames(df)<- c()
  df<-merge(df,basecase,by="spstock2",all=TRUE)
  df<-within(df, ACL_kg[is.na(ACL_kg)] <- baselineACL_kg[is.na(ACL_kg)])
  df$sectorACL_kg<-df$ACL_kg*df$sector_frac
  return(df)
}