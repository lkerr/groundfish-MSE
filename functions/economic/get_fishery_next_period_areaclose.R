# A function to deal with the end of the day. 
# Set the column "underACL"="TRUE" if removals are  less than the ACL.  Set the column "underACL"="FALSE" otherwise. # For the allocated multispecies stocks, set another variable (stockarea_open as a logical True/False if that stockarea is open.
# Any allocated multispecies with "underACL"=FALSE will also have "stockarea_open=FALSE"
# dc: catch for that day of all stocks by the fleet
# fh: data frame containing stock name, logical for open/closed, catch limit, and cumulative catch
# Returns the updated version of that matrix.


#get_fishery_next_period_areaclose <- function(dc,fh){
  
get_fishery_next_period_areaclose <- function(fh){
  #fh$cumul_catch_pounds<-dc$cumul_catch_pounds
  #fh$targeted<-dc$targeted
  
  fh[,sectorACL_pounds:=sectorACL*pounds_per_kg*kg_per_mt]
  fh[,underACL:=cumul_catch_pounds<sectorACL_pounds]
  
  
  #fh$sectorACL_pounds<-fh$sectorACL*pounds_per_kg*kg_per_mt
  #fh$underACL<-fh$cumul_catch<fh$sectorACL_pounds
  
  #split into allocated and non-allocated
  z0<-fh[which(fh$mults_allocated==0)]
  
  #for non-allocated stocks, set their stockarea_closed value to the negation of the underACL 
  z0$stockarea_closed<-!z0$underACL
  
  
  fh<-fh[which(fh$mults_allocated==1)]
  
  num_closed<-sum(fh$underACL==FALSE)
  if (num_closed==0){
    fh$stockarea_closed<-as.logical(FALSE)
    # If nothing is closed, just return fh
  } else{
    
    #it's easer to check if "any" stock in an area is closed than it is to check that ALL stocks are open.
    # so we'll do that, then "negate" it over to a new open variable.
    
    #by mults_allocated and stock area, sum up the number of overACLs, and set to TRUE if>0 and FALSE if ==0
    fh<-fh[,stockarea_closed :=(sum(underACL==FALSE))>0, by=list(mults_allocated,stockarea)]
    
    # examine and recode the stock areas 
    unit_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="Unit"))
    gb_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="GB"))
    gom_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="GOM"))
    snema_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="SNEMA"))
    ccgom_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="CCGOM"))
    
    
    if (unit_check>=1){
      fh$stockarea_closed=TRUE 
    } 
    
    
    if (gb_check>=1 & gom_check>=1){
        fh$stockarea_closed[which(fh$stockarea=="CCGOM")]=TRUE 
        snema_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="SNEMA"))
      }
    }
  
  
  #reassemble, negate stockarea_closed to form stockarea_open, and drop stockarea_closed
  fh<-rbind(fh,z0)
  fh$stockarea_open=!fh$stockarea_closed
  fh[,stockarea_closed:=NULL]
  setorder(fh,"spstock2")
  return(fh)
  #fh<-as.data.table(fh)
}
