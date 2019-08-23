#After selecting a trip from the set of choices, the trip dataset contains catch of each stock in "wide" form where the "c_" is prepended to the spstock2.  The catch monitoring and biological models require total removals at the daily and yearly level.  These need to be in "long" format.  

#Inputs - the trips data.table (nrows=N) where rows contain the selected trip and the "c_" columns contain catch, in pounds by each of the N vessels.  
#Outputs- a data.table with two columns, spstock2 and pounds.

get_reshape_catches=function(trips){
  mm<-grep("^c_",colnames(trips))
  
  
  catches<-trips[, ..mm]
  
  catches<-catches[, lapply(.SD, sum, na.rm=TRUE)]
  catches<-t(catches)
  
  catches<-cbind(rownames(catches),catches)
  catches<-as.data.table(catches)
  colnames(catches)<-c("spstock2","daily_pounds_caught")
  
  catches$spstock2<-gsub("c_","", catches$spstock2)
  
  setorder(catches,spstock2)
  catches$daily_pounds_caught<-as.numeric(catches$daily_pounds_caught)
  return(catches)
}