# A function to zero out trips that are closed.
#
# tds: working targeting dataset with asclogit coefficients 
# open_hold: a dataset of hullnum2 and spstock2 with one extra column (open=1 if open and =0 if closed).
# I need to :
# A. 


zero_out_closed <- function(tds,open_hold){
  tds<-merge(tds,open_hold, by=c("hullnum2","spstock2"))
  tds$prhat[tds$open==0]<-0
  return(tds)
}



