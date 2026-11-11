library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggh4x)


# Scenarios<-c("PetraleBCBase","PetraleBC_NoRecentAge","PetraleBC_GapsInAge","PetraleBC_LessAge",
#              "PetraleBC_MRE","PetraleBC_MRE_NoRecentAge","PetraleBC_MRE_GapsInAge",
#              "PetraleBC_MRE_LessAge","PetraleBC_Renv","PetraleBC_NoRecentAge_Renv",
#              "PetraleBC_GapsInAge_Renv","PetraleBC_LessAge_Renv")

# Scenarios<-c("PetraleBC_IncreaseAlpha","PetraleBC_IncreaseAlpha_NoRecentAge",
#              "PetraleBC_IncreaseAlpha_GapsInAge","PetraleBC_IncreaseAlpha_LessAge",
#              "PetraleBC_IncreaseAlpha_MRE","PetraleBC_IncreaseAlpha_NoRecentAge_MRE",
#              "PetraleBC_IncreaseAlpha_GapsInAge_MRE",
#              "PetraleBC_IncreaseAlpha_LessAge_MRE","PetraleBC_IncreaseAlpha_Renv",
#              "PetraleBC_IncreaseAlpha_NoRecentAge_Renv",
#              "PetraleBC_IncreaseAlpha_GapsInAge_Renv","PetraleBC_IncreaseAlpha_LessAge_Renv")

Scenarios<-c("PetraleBC_IncreaseM","PetraleBC_IncreaseM_NoRecentAge",
             "PetraleBC_IncreaseM_GapsInAge","PetraleBC_IncreaseM_LessAge",
             "PetraleBC_IncreaseM_MRE","PetraleBC_IncreaseM_NoRecentAge_MRE",
             "PetraleBC_IncreaseM_GapsInAge_MRE",
             "PetraleBC_IncreaseM_LessAge_MRE","PetraleBC_IncreaseM_Renv",
             "PetraleBC_IncreaseM_NoRecentAge_Renv",
             "PetraleBC_IncreaseM_GapsInAge_Renv","PetraleBC_IncreaseM_LessAge_Renv")

for (i in Scenarios){
  setwd(paste("C:/Users/mazurm/Documents/groundfish-MSE/",i,sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  IAVCatch<-matrix(NA,nrow=1,ncol=length(sims))
  Catch<-matrix(NA,nrow=1,ncol=length(sims))
  ProbSSBLRP<-matrix(NA,nrow=1,ncol=length(sims))
  ProbSSBUSR<-matrix(NA,nrow=1,ncol=length(sims))
  ProbFFMSY<-matrix(NA,nrow=1,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    Catches<-omvalGlobal[[1]]$SSB[186:195]
    catchdiff<-rep(NA,length(Catches)-1)
    for (j in 1:(length(Catches)-1)){
      catchdiff[j]<-(Catches[j+1]-Catches[j])
    }
    IAVCatch[,k]<-sqrt((1/(length(Catches)-1))*sum(catchdiff)^2)/((1/(length(Catches)))*sum(Catches))
    Catch[,k]<-median(Catches)
    SSBoverLRP<-omvalGlobal[[1]]$SSB[186:195]/(omvalGlobal[[1]]$SSBPROXYT[186:195]*0.4)
    SSBoverLRP[SSBoverLRP>1]<-1
    SSBoverLRP[SSBoverLRP<1]<-0
    ProbSSBLRP[,k]<-mean(SSBoverLRP)
    SSBoverUSR<-omvalGlobal[[1]]$SSB[186:195]/(omvalGlobal[[1]]$SSBPROXYT[186:195]*0.8)
    SSBoverUSR[SSBoverUSR>1]<-1
    SSBoverUSR[SSBoverUSR<1]<-0
    ProbSSBUSR[,k]<-mean(SSBoverUSR)
    FoverFMSY<-omvalGlobal[[1]]$F_full[186:195]/omvalGlobal[[1]]$FPROXYT[186:195]
    FoverFMSY[FoverFMSY<1]<-1
    FoverFMSY[FoverFMSY>1]<-0
    ProbFFMSY[,k]<-mean(FoverFMSY)
  }
  
  if(i=='PetraleBCBase'){name<-'Base'}
  if(i=='PetraleBC_NoRecentAge'){name<-'No Recent Age'}
  if(i=='PetraleBC_GapsInAge'){name<-'Gaps In Age'}
  if(i=='PetraleBC_LessAge'){name<-'Less Age'}
  if(i=='PetraleBC_MRE'){name<-'M RE'}
  if(i=='PetraleBC_MRE_NoRecentAge'){name<-'No Recent Age, M RE'}
  if(i=='PetraleBC_MRE_GapsInAge'){name<-'Gaps In Age, M RE'}
  if(i=='PetraleBC_MRE_LessAge'){name<-'Less Age, M RE'}
  if(i=='PetraleBC_Renv'){name<-'R Env.'}
  if(i=='PetraleBC_NoRecentAge_Renv'){name<-'No Recent Age, R Env.'}
  if(i=='PetraleBC_GapsInAge_Renv'){name<-'Gaps In Age, R Env.'}
  if(i=='PetraleBC_LessAge_Renv'){name<-'Less Age, R Env.'}
  
  if(i=='PetraleBC_IncreaseAlpha'){name<-'Base'}
  if(i=='PetraleBC_IncreaseAlpha_NoRecentAge'){name<-'No Recent Age'}
  if(i=='PetraleBC_IncreaseAlpha_GapsInAge'){name<-'Gaps In Age'}
  if(i=='PetraleBC_IncreaseAlpha_LessAge'){name<-'Less Age'}
  if(i=='PetraleBC_IncreaseAlpha_MRE'){name<-'M RE'}
  if(i=='PetraleBC_IncreaseAlpha_NoRecentAge_MRE'){name<-'No Recent Age, M RE'}
  if(i=='PetraleBC_IncreaseAlpha_GapsInAge_MRE'){name<-'Gaps In Age, M RE'}
  if(i=='PetraleBC_IncreaseAlpha_LessAge_MRE'){name<-'Less Age, M RE'}
  if(i=='PetraleBC_IncreaseAlpha_Renv'){name<-'R Env.'}
  if(i=='PetraleBC_IncreaseAlpha_NoRecentAge_Renv'){name<-'No Recent Age, R Env.'}
  if(i=='PetraleBC_IncreaseAlpha_GapsInAge_Renv'){name<-'Gaps In Age, R Env.'}
  if(i=='PetraleBC_IncreaseAlpha_LessAge_Renv'){name<-'Less Age, R Env.'}
  
  if(i=='PetraleBC_IncreaseM'){name<-'Base'}
  if(i=='PetraleBC_IncreaseM_NoRecentAge'){name<-'No Recent Age'}
  if(i=='PetraleBC_IncreaseM_GapsInAge'){name<-'Gaps In Age'}
  if(i=='PetraleBC_IncreaseM_LessAge'){name<-'Less Age'}
  if(i=='PetraleBC_IncreaseM_MRE'){name<-'M RE'}
  if(i=='PetraleBC_IncreaseM_NoRecentAge_MRE'){name<-'No Recent Age, M RE'}
  if(i=='PetraleBC_IncreaseM_GapsInAge_MRE'){name<-'Gaps In Age, M RE'}
  if(i=='PetraleBC_IncreaseM_LessAge_MRE'){name<-'Less Age, M RE'}
  if(i=='PetraleBC_IncreaseM_Renv'){name<-'R Env.'}
  if(i=='PetraleBC_IncreaseM_NoRecentAge_Renv'){name<-'No Recent Age, R Env.'}
  if(i=='PetraleBC_IncreaseM_GapsInAge_Renv'){name<-'Gaps In Age, R Env.'}
  if(i=='PetraleBC_IncreaseM_LessAge_Renv'){name<-'Less Age, R Env.'}
  
  if(i==Scenarios[1]){
    d <- data.frame(
      Value = c(IAVCatch, Catch, ProbSSBLRP, ProbSSBUSR, ProbFFMSY),
      Metric = rep(c("Interannual Variability in Catch", "Catch", 
                    "Probability of SSB over LRP", "Probability of SSB over USR",
                     "Probability of F under FMSY"), each = length(sims))
    ) 
    d$Scenario<-name
  }
  if (i!=Scenarios[1]){
    d2 <- data.frame(
      Value = c(IAVCatch, Catch, ProbSSBLRP, ProbSSBUSR, ProbFFMSY),
      Metric = rep(c("Interannual Variability in Catch", "Catch", 
                     "Probability of SSB over LRP", "Probability of SSB over USR",
                     "Probability of F under FMSY"), each = length(sims))
    ) 
    d2$Scenario<-name
    d<-full_join(d,d2)}
}

####Plot####
df<-d

# Create model category
df$Category <- "Base Model"

df$Category[grepl("R Env\\.", df$Scenario)] <- "R Env."
df$Category[grepl("M RE", df$Scenario)] <- "M RE"

# Ensure standalone model scenarios are placed correctly
df$Category[df$Scenario == "R Env."] <- "R Env."
df$Category[df$Scenario == "M RE"] <- "M RE"

# Create age scenario
df$AgeScenario <- df$Scenario

df$AgeScenario <- gsub(", R Env\\.", "", df$AgeScenario)
df$AgeScenario <- gsub(", M RE", "", df$AgeScenario)

# Rename standalone model scenarios
df$AgeScenario[df$Scenario == "R Env."] <- "Base Age"
df$AgeScenario[df$Scenario == "M RE"] <- "Base Age"
df$AgeScenario[df$Scenario == "Base"] <- "Base Age"

# Ordering
df$AgeScenario <- factor(
  df$AgeScenario,
  levels = c(
    "Base Age",
    "No Recent Age",
    "Gaps In Age",
    "Less Age"
  ))

df$Category <- factor(
  df$Category,
  levels = c(
    "Base Model",
    "R Env.",
    "M RE"
  )
)

ggplot(
  df,
  aes(
    x = AgeScenario,
    y = Value,
    fill = AgeScenario
  )
) +
  geom_boxplot() +
  facet_grid2(
    Category ~ Metric,
    scales = "free_y",
    independent = "y"
  ) +
  scale_fill_manual(
    values = c(
      "Base Age" = "grey60",
      "No Recent Age" = "#6a3d9a",
      "Gaps In Age" = "#ff7f00",
      "Less Age" = "#1f78b4"
    )
  ) +
  labs(
    x = NULL,
    y = NULL
  ) +
  theme_classic(base_size = 12) +
  theme(
    legend.position = "none",
    strip.placement = "outside",
    strip.background = element_rect(fill = "white"),
    panel.spacing.y = unit(0.5, "lines"),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 1
    )
  )
