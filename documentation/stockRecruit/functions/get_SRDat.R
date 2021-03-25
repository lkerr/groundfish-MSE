get_SRDat <- function(recDat, stock, stockArea){

  # Subset the data to extract the stock of interest
  tmpRec <- subset(recDat, STOCK == stock & STOCKAREA == stockArea)

  # Create new data frame appropriately offset such that the SSB is matched
  # with the correct number of recruits
  nr <- nrow(tmpRec)
  tmpRecOff <- tmpRec
  tmpRecOff$REC <- c(tmpRec$REC[2:nr], NA)
  tmpRecOff <- tmpRecOff[,-which(names(tmpRecOff) == 'REC000S')]
  
  return(tmpRecOff)
}
