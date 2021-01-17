get_SRDat <- function(recDat, stock){
  
  # Subset the data to extract the stock of interest
  tmpRec <- subset(recDat, STOCK == stock)
  
  # Create new data frame appropriately offset such that the SSB is matched
  # with the correct number of recruits
  nr <- nrow(tmpRec)
  tmpRecOff <- tmpRec
  tmpRecOff$REC <- c(tmpRec$REC[2:nr], NA)
  
  return(tmpRecOff)
}
