

get_temperatureSeries <- function(cmip5Long, RCP, Model = NULL, quant){
  
  # If no Model given assume all models are used
  if(is.null(Model)){
    Model <- unique(cmip5Long$Model)
  }
  
  # Subset based on RCP level
  csub <- subset(cmip5Long, RCP == RCP)
  
  # Get indices of models that are chosen and subset
  idx <- sapply(seq_along(Model), 
                FUN = function(x) which(csub$Model == Model[x]))
  csub2 <- csub[c(idx),]
  
  # Get quantile by year
  cquant <- aggregate(Temperature ~ year,
                      data = csub2,
                      FUN = quantile,
                      probs = quant)
  
  return(cquant)
}




# Test the function

# x <- get_temperatureSeries(cmip5Long, RCP = 8.5, 
#                            Model = c("CAN_ESM2", "IPSL_CM5B_LR", "GFDL_ESM2G"), 
#                            quant = 0.6)
# 
# y <- subset(cmip5Long, 
#             Model == "CAN_ESM2" | Model == "IPSL_CM5B_LR" | 
#             Model == "GFDL_ESM2G")
# 
# z <- aggregate(Temperature ~ year,
#                data = y,
#                FUN = quantile,
#                probs = 0.6)

# head(x)
## year Temperature
## 1 1901    16.23859
## 2 1902    16.04888
## 3 1903    16.27139
## 4 1904    15.86023
## 5 1905    16.16733
## 6 1906    16.13775

# head(z)
## year Temperature
## 1 1901    16.23859
## 2 1902    16.04888
## 3 1903    16.27139
## 4 1904    15.86023
## 5 1905    16.16733
## 6 1906    16.13775
