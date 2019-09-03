# A function to zero out trips that are closed after estimating an ASCLOGIT.
# If "stockarea_open=FALSE" for any stocks, then the probability of targeting that stock is set to zero. That probability is redistributed proportionally.

# tds: working targeting dataset with asclogit coefficients 
# open_hold: a dataset of hullnum and spstock2 with one extra column (open=1 if open and =0 if closed).
# I need to fix this, because it does not close an entire stock area when a single catch limit is reached. 
#  


zero_out_closed_areas_asc_cutout <- function(tds,open_hold){
  num_closed<-sum(open_hold$stockarea_open==FALSE)
  if (num_closed==0){
    # If nothing is closed, just return tds
  } else{
  
  #tds<-left_join(tds,open_hold, by=c("spstock2"="spstock2"))
  #A data table left join
    
  tds<-open_hold[tds, on="spstock2"]
  tds[spstock2=="nofish", stockarea_open :=TRUE]
  tds[stockarea_open==FALSE, prhat :=0]
  
  #tds$stockarea_open[which(tds$spstock2=="nofish")]<-TRUE
  #tds$prhat[tds$stockarea_open==FALSE]<-0
  tds[, prsum := sum(prhat), by = id]
  tds[, prhat:=prhat/prsum]
  #tds$prhat<- tds$prhat/tds$prsum
  }
  return(tds)
  
}

