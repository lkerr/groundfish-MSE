# AFS 2023 plots


for(isim in 1:10){
  source("~/Research/groundfish-MSE_WHAM/processes/runSim.R")
}

library(DataExplorer)
library(tidyverse)

fileList <- c("results_2023-08-16-15-33-54/sim/omvalGlobal2023-08-16_153502_933.Rdata", # Status quo SSP1_26
              "results_2023-08-16-15-35-03/sim/omvalGlobal2023-08-16_153613_933.Rdata",
              "results_2023-08-16-15-36-13/sim/omvalGlobal2023-08-16_153723_933.Rdata",
              "results_2023-08-16-15-37-23/sim/omvalGlobal2023-08-16_153833_933.Rdata",
              "results_2023-08-16-15-38-34/sim/omvalGlobal2023-08-16_153943_933.Rdata",
              "results_2023-08-16-15-39-44/sim/omvalGlobal2023-08-16_154051_933.Rdata",
              "results_2023-08-16-15-40-52/sim/omvalGlobal2023-08-16_154200_6351.Rdata",
              "results_2023-08-16-15-42-01/sim/omvalGlobal2023-08-16_154310_6351.Rdata",
              "results_2023-08-16-15-43-11/sim/omvalGlobal2023-08-16_154419_6351.Rdata",
              "results_2023-08-16-15-44-20/sim/omvalGlobal2023-08-16_154529_6351.Rdata")

simSetting <- c(rep("statusquo_26",5),
                rep("statusquo_2.6",5))

# Storage objects
Mohns_Rho_F <- NULL
Mohns_Rho_SSB <- NULL
Mohns_Rho_R <- NULL
Ffull_long <- NULL
Ffull_mid <- NULL
Fest_long <- NULL
Fest_mid <- NULL
SSB_long <- NULL
SSB_mid <- NULL
SSBest_long <- NULL
SSBest_mid <- NULL
R_long <- NULL
R_mid <- NULL
Rest_long <- NULL
Rest_mid <- NULL
relE_qI <- NULL
FrelE_long <- NULL
FrelE_mid <- NULL
SSBrelE_long <- NULL
SSBrelE_mid <- NULL
RrelE_long <- NULL
RrelE_mid <- NULL

for(ifile in 1:length(fileList)){
  # Load file
  load(here::here(fileList[ifile]))
  
  # Pull results for plotting
  Mohns_Rho_F <- rbind(Mohns_Rho_F, omvalGlobal$haddockGB$Mohns_Rho_F[,,169:190])
  Mohns_Rho_SSB <- rbind(Mohns_Rho_SSB, omvalGlobal$haddockGB$Mohns_Rho_SSB[,,169:190])
  Mohns_Rho_R <- rbind(Mohns_Rho_R, omvalGlobal$haddockGB$Mohns_Rho_R[,,169:190])
  Ffull_long_temp <- omvalGlobal$haddockGB$F_full[,,169:190] # OM Fs in all management loop years (2019-2040, index 169-190)
  Ffull_long <- rbind(Ffull_long, Ffull_long_temp) # OM Fs in all management loop years (2019-2040, index 169-190)
  Ffull_mid_temp <- omvalGlobal$haddockGB$F_full[,,169:180] # OM Fs for first 11 years of management loop
  Ffull_mid <- rbind(Ffull_mid, Ffull_mid_temp) # OM Fs for first 11 years of management loop
  Fest_long_temp <- omvalGlobal$haddockGB$Fest[190,32:53] # EM Fest in last year of management loop (item 54 always has NA)
  Fest_long <- rbind(Fest_long, Fest_long_temp) 
  Fest_mid_temp <- omvalGlobal$haddockGB$Fest[180,32:43] # EM Fest in 11th year of management loop 
  Fest_mid <- rbind(Fest_mid, Fest_mid_temp) # EM Fest in 11th year of management loop 
  SSB_long_temp <- omvalGlobal$haddockGB$SSB[,,169:190]
  SSB_long <- rbind(SSB_long, SSB_long_temp)
  SSB_mid_temp <- omvalGlobal$haddockGB$SSB[,,169:180]
  SSB_mid <- rbind(SSB_mid, SSB_mid_temp)
  SSBest_long_temp <- omvalGlobal$haddockGB$SSBest[190,32:53]
  SSBest_long <- rbind(SSBest_long, SSBest_long_temp)
  SSBest_mid_temp <- omvalGlobal$haddockGB$SSBest[180,32:43]
  SSBest_mid <- rbind(SSBest_mid, SSBest_mid_temp)
  R_long_temp <- omvalGlobal$haddockGB$R[,,169:190]
  R_long <- rbind(R_long, R_long_temp)
  R_mid_temp <- omvalGlobal$haddockGB$R[,,169:180]
  R_mid <- rbind(R_mid, R_mid_temp)
  Rest_long_temp <- omvalGlobal$haddockGB$Rest[190, 32:53]
  Rest_long <- rbind(Rest_long, Rest_long_temp)
  Rest_mid_temp <- omvalGlobal$haddockGB$Rest[180, 32:43]
  Rest_mid <- rbind(Rest_mid, Rest_mid_temp)
  relE_qI <- rbind(relE_qI, omvalGlobal$haddockGB$relE_qI[,,169:190])
  
  # Calculate relative errors
  FrelE_long <- rbind(FrelE_long, 100*(Fest_long_temp-Ffull_long_temp)/Ffull_long_temp)
  FrelE_mid <- rbind(FrelE_mid, 100*(Fest_mid_temp-Ffull_mid_temp)/Ffull_mid_temp)
  SSBrelE_long <- rbind(SSBrelE_long, 100*(SSBest_long_temp-SSB_long_temp)/SSB_long_temp)
  SSBrelE_mid <- rbind(SSBrelE_mid, 100*(SSBest_mid_temp-SSB_mid_temp)/SSB_mid_temp)
  RrelE_long <- rbind(RrelE_long, 100*(Rest_long_temp-R_long_temp)/R_long_temp)
  RrelE_mid <- rbind(RrelE_mid, 100*(Rest_mid_temp-R_mid_temp)/R_mid_temp)
}


plotData <- list(simSetting = simSetting,
     Mohns_Rho_F=Mohns_Rho_F,  Mohns_Rho_SSB=Mohns_Rho_SSB,  Mohns_Rho_R=Mohns_Rho_R,
     Ffull_long=Ffull_long, Ffull_mid=Ffull_mid, Fest_long=Fest_long, Fest_mid=Fest_mid, FrelE_long=FrelE_long, FrelE_mid=FrelE_mid,
     SSB_long=SSB_long, SSB_mid=SSB_mid, SSBest_long=SSBest_long, SSBest_mid=SSBest_mid, SSBrelE_long=SSBrelE_long, SSBrelE_mid=SSBrelE_mid,
     R_long=R_long, R_mid=R_mid, Rest_long=Rest_long, Rest_mid=Rest_mid,  RrelE_long=RrelE_long, RrelE_mid=RrelE_mid,
     relE_qI=relE_qI, Year = 2019:2040)

plotData %>% as.data.frame() %>% select(Year, SSB_long)
  ggplot() +
  geom_line(aes(x=Year,))

# OM SSB time series
plot_SSBlong <- cbind(SSB_long, simSetting, simnum = 1:length(simSetting)) %>% 
  as.data.frame() %>% 
  pivot_longer(., cols = c(grep("nyear", colnames(.))), names_sep = "nyear", names_to = c("nyear", "Year"), values_to = "SSB_long") %>% 
  mutate(Year = as.numeric(Year) + 1850, Scenario = simSetting, SSB_long = as.numeric(SSB_long)) %>% 
  drop_columns(c("nyear", "simSetting")) %>%
# plot_SSBlong[1:22,]%>%
  ggplot()+
  geom_line(aes(x=Year, y=SSB_long, color = simnum))
# ggsave(plot_SSBlong, filename = here::here("SDM_MSE", "AFS_2023_plots"))

# SSB relative error time series
cbind(SSBrelE_long, simSetting, simnum = 1:length(simSetting)) %>%
  as.data.frame() %>%
  pivot_longer(., cols = c(grep("nyear", colnames(.))), names_sep = "nyear", names_to = c("nyear", "Year"), values_to = "SSBrelE_long") %>%
  mutate(Year = as.numeric(Year)+1850, Scenario = simSetting, SSBrelE_long = as.numeric(SSBrelE_long)) %>%
  drop_columns(c("nyear", "simSetting")) %>%
  ggplot()+
  geom_line(aes(x=Year, y=SSBrelE_long, color = simnum))

# SSB relative error box plots
cbind(SSBrelE_long, simSetting, simnum = 1:length(simSetting)) %>%
  as.data.frame() %>%
  pivot_longer(., cols = c(grep("nyear", colnames(.))), names_sep = "nyear", names_to = c("nyear", "Year"), values_to = "SSBrelE_long") %>%
  mutate(Year = as.numeric(Year)+1850, Scenario = simSetting, SSBrelE_long = as.numeric(SSBrelE_long)) %>%
  drop_columns(c("nyear", "simSetting")) %>%
  group_by(simnum) %>%
  summarize(median_SSBrelE = median(SSBrelE_long), Scenario = unique(Scenario)) %>%
  ggplot()+
  geom_boxplot(aes(x=Scenario, y=median_SSBrelE)) + 
  ylab("Median SSB relative error")

# qI relative error time series
cbind(relE_qI, simSetting, simnum = 1:nrow(relE_qI)) %>%
  as.data.frame() %>%
  pivot_longer(., cols = c(grep("nyear", colnames(.))), names_sep = "nyear", names_to = c("nyear", "Year"), values_to = "relE_qI") %>%
  mutate(Year = as.numeric(Year)+1850, Scenario = simSetting, relE_qI = as.numeric(relE_qI)) %>%
  drop_columns(c("nyear", "simSetting")) %>%
  ggplot()+
  geom_line(aes(x=Year, y=relE_qI, color = simnum))

# qI relative error box plots
cbind(relE_qI, simSetting, simnum = 1:nrow(relE_qI)) %>%
  as.data.frame() %>%
  pivot_longer(., cols = c(grep("nyear", colnames(.))), names_sep = "nyear", names_to = c("nyear", "Year"), values_to = "relE_qI") %>%
  mutate(Year = as.numeric(Year)+1850, Scenario = simSetting, relE_qI = as.numeric(relE_qI)) %>%
  group_by(simnum) %>%
  summarize(median_qI = median(relE_qI), Scenario = unique(Scenario)) %>%
  ggplot()+
  geom_boxplot(aes(x=Scenario, y=median_qI)) +
  ylab("Median survey catchability relative error")

