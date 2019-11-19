#After selecting a trip from the set of choices, the trip dataset contains revenue from each stock in "wide" form where the "r_" is prepended to the spstock2.  

#Inputs - the trips data.table (nrows=N) where rows contain the selected trip and the "c_" columns contain catch, in pounds by each of the N vessels.  
#Outputs- a data.table with two columns, spstock2 and pounds.

get_reshape_targets_revenues=function(trips){
  mm<-grep("^r_",colnames(trips))
  mm<-c(mm,grep("^spstock2",colnames(trips)))
  
  #need to add the spstock2 here to the column list
  
  targeted<-trips[, ..mm]
  targeted$target<-1
  targeted<-targeted[, lapply(.SD, sum, na.rm=TRUE),by=spstock2]

  targeted<-as.data.table(targeted)
  m<-gsub("r_","", colnames(targeted))
  colnames(targeted)<-m
  setcolorder(targeted,c("spstock2","target"))
  
  return(targeted)
}