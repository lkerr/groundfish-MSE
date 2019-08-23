#After selecting a trip from the set of choices, the trip dataset contains catch of each stock in "wide" form where the "c_" is prepended to the spstock2.  The catch monitoring and biological models require total removals at the daily and yearly level.  These need to be in "long" format.  

#Inputs - the trips data.table (nrows=N) where rows contain the selected trip and the "c_" columns contain catch, in pounds by each of the N vessels.  
#Outputs- a data.table with two columns, spstock2 and pounds.

get_reshape_landings=function(trips){
  mm<-grep("^l_",colnames(trips))
  
  
  landings<-trips[, ..mm]
  
  landings<-landings[, lapply(.SD, sum, na.rm=TRUE)]
  landings<-t(landings)
  
  landings<-cbind(rownames(landings),landings)
  landings<-as.data.table(landings)
  colnames(landings)<-c("spstock2","daily_pounds_landed")
  
  landings$spstock2<-gsub("l_","", landings$spstock2)
  setorder(landings,spstock2)
  catches$daily_pounds_landed<-as.numeric(catches$daily_pounds_landed)
  
  return(landings)
}