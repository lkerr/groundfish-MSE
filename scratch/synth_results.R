#####################
## read across simulation results
## 

# which scenario to extract results from
setwd("C:/Users/aweston/Box/Ashley Weston/Discard Sims/Scenarios for LK/results_scenario1_v2/sim")
#setwd("C:/Users/aweston/Box/Ashley Weston/Discard Sims/Scenarios for LK/results_scenario2_v2/sim")
#setwd("C:/Users/aweston/Box/Ashley Weston/Discard Sims/Scenarios for LK/results_scenario3_v2/sim")

sims <- list.files()


# get SSB and catch weight by stock and MP by year
cod_SSB_MP1 <- matrix(NA, ncol = length(sims), nrow = 200)
cod_SSB_MP2 <- matrix(NA, ncol = length(sims), nrow = 200)
haddock_SSB_MP1 <- matrix(NA, ncol = length(sims), nrow = 200)
haddock_SSB_MP2 <- matrix(NA, ncol = length(sims), nrow = 200)
cod_catch_MP1 <- matrix(NA, ncol = length(sims), nrow = 200)
cod_catch_MP2 <- matrix(NA, ncol = length(sims), nrow = 200)
haddock_catch_MP1 <- matrix(NA, ncol = length(sims), nrow = 200)
haddock_catch_MP2 <- matrix(NA, ncol = length(sims), nrow = 200)
for (i in 1:length(sims)){
  load(sims[i])
  cod_SSB_MP1[,i] <- as.numeric(omvalGlobal$codGB_Error$SSB[1,1,])
  cod_SSB_MP2[,i] <- as.numeric(omvalGlobal$codGB_Error$SSB[1,2,])
  haddock_SSB_MP1[,i] <- as.numeric(omvalGlobal$haddockGB$SSB[1,1,])
  haddock_SSB_MP2[,i] <- as.numeric(omvalGlobal$haddockGB$SSB[1,2,])
  cod_catch_MP1[,i] <- as.numeric(omvalGlobal$codGB_Error$sumCW[1,1,])
  cod_catch_MP2[,i] <- as.numeric(omvalGlobal$codGB_Error$sumCW[1,2,])
  haddock_catch_MP1[,i] <- as.numeric(omvalGlobal$haddockGB$sumCW[1,1,])
  haddock_catch_MP2[,i] <- as.numeric(omvalGlobal$haddockGB$sumCW[1,2,])
  
}


# calculate standard deviation/mean (SSB and catch) for each year by stock/MP
library(matrixStats)
sd_cod_SSB_MP1 <- rowSds(cod_SSB_MP1)
mean_cod_SSB_MP1 <- rowMeans(cod_SSB_MP1)
sd_cod_SSB_MP2 <- rowSds(cod_SSB_MP2)
mean_cod_SSB_MP2 <- rowMeans(cod_SSB_MP2)

sd_haddock_SSB_MP1 <- rowSds(haddock_SSB_MP1)
mean_haddock_SSB_MP1 <- rowMeans(haddock_SSB_MP1)
sd_haddock_SSB_MP2 <- rowSds(haddock_SSB_MP2)
mean_haddock_SSB_MP2 <- rowMeans(haddock_SSB_MP2)


sd_cod_cw_MP1 <- rowSds(cod_catch_MP1)
mean_cod_cw_MP1 <- rowMeans(cod_catch_MP1)
sd_cod_cw_MP2 <- rowSds(cod_catch_MP2)
mean_cod_cw_MP2 <- rowMeans(cod_catch_MP2)

sd_haddock_cw_MP1 <- rowSds(haddock_catch_MP1)
mean_haddock_cw_MP1 <- rowMeans(haddock_catch_MP1)
sd_haddock_cw_MP2 <- rowSds(haddock_catch_MP2)
mean_haddock_cw_MP2 <- rowMeans(haddock_catch_MP2)


all_mean_SSB <- cbind(mean_cod_SSB_MP1, mean_cod_SSB_MP2, mean_haddock_SSB_MP1, mean_haddock_SSB_MP2)
all_sd_SSB <- cbind(sd_cod_SSB_MP1, sd_cod_SSB_MP2, sd_haddock_SSB_MP1, sd_haddock_SSB_MP2)
all_mean_cw <- cbind(mean_cod_cw_MP1, mean_cod_cw_MP2, mean_haddock_cw_MP1, mean_haddock_cw_MP2)
all_sd_cw <- cbind(sd_cod_cw_MP1, sd_cod_cw_MP2, sd_haddock_cw_MP1, sd_haddock_cw_MP2)

setwd("C:/Users/aweston/Box/Ashley Weston/Discard Sims/Scenarios for LK/results_scenario1_v2")
#setwd("C:/Users/aweston/Box/Ashley Weston/Discard Sims/Scenarios for LK/results_scenario2_v2")
#setwd("C:/Users/aweston/Box/Ashley Weston/Discard Sims/Scenarios for LK/results_scenario3_v2")

write.csv(all_mean_SSB, "mean_SSB.csv")
write.csv(all_sd_SSB, "sd_SSB.csv")
write.csv(all_mean_cw, "mean_cw.csv")
write.csv(all_sd_cw, "sd_cw.csv")


