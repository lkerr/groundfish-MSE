get_SRDat <- function(recDat, anomDat, stock){
  
  # Subset the data to extract the stock of interest
  tmpRec <- subset(recDat, STOCK == stock)
  
  # Create new data frame appropriately offset such that the SSB is matched
  # with the correct number of recruits
  nr <- nrow(tmpRec)
  tmpRecOff <- tmpRec
  tmpRecOff$REC000S <- c(tmpRec$REC000S[2:nr], NA)
  
  return(tmpRecOff)
}
