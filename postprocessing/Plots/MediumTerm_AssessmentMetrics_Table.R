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
  RelESSBs<-matrix(NA,nrow=21,ncol=1)
  RelESSB<-matrix(NA,nrow=1,ncol=length(sims))
  RelEFs<-matrix(NA,nrow=21,ncol=1)
  RelEF<-matrix(NA,nrow=1,ncol=length(sims))
  RelEBMSY<-matrix(NA,nrow=1,ncol=length(sims))
  RelEFMSY<-matrix(NA,nrow=1,ncol=length(sims))
  MohnsRhoSSB<-matrix(NA,nrow=1,ncol=length(sims))
  MohnsRhoF<-matrix(NA,nrow=1,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSBtrue<-omvalGlobal[[1]]$SSB[175:195]
    for (l in seq(175,195,1)){
      SSBest<-omvalGlobal[[1]]$SSBest[l,]
      SSBest<-na.omit(SSBest)
      SSBest<-tail(SSBest,1)
      RelESSBs[l-174,1]<-((SSBest-SSBtrue[l-174])/SSBtrue[l-174])*100
    }
    RelESSB[,k]<-median(RelESSBs[6:10,])
    Ftrue<-omvalGlobal[[1]]$F_full[175:195]
    for (l in seq(175,195,1)){
      Fest<-omvalGlobal[[1]]$Fest[l,]
      Fest<-na.omit(Fest)
      Fest<-tail(Fest,1)
      RelEFs[l-174,1]<-((Fest-Ftrue[l-174])/Ftrue[l-174])*100
    }
    RelEF[,k]<-median(RelEFs[6:10,])
    RelEBMSY[,k]<-median(((omvalGlobal[[1]]$SSBPROXY[180:184]-omvalGlobal[[1]]$SSBPROXYT[180:184])/
                     omvalGlobal[[1]]$SSBPROXYT[180:184])*100)
    RelEFMSY[,k]<-median(((omvalGlobal[[1]]$FPROXY[180:184]-omvalGlobal[[1]]$FPROXYT[180:184])/
                     omvalGlobal[[1]]$FPROXYT[180:184])*100)
    MohnsRhoSSB[,k]<-median(omvalGlobal[[1]]$Mohns_Rho_SSB[180:184])
    MohnsRhoF[,k]<-median(omvalGlobal[[1]]$Mohns_Rho_F[180:184])
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
      Value = c(RelESSB, RelEF, RelEBMSY, RelEFMSY, MohnsRhoSSB, MohnsRhoF),
      Metric = rep(c("% Relative Error in SSB", "% Relative Error in F", 
                     "% Relative Error in BMSY", "% Relative Error in FMSY",
                     "Mohn's Rho in SSB", "Mohn's Rho in F"), each = length(sims))
    )
    d$Scenario<-name
  }
  if (i!=Scenarios[1]){
    d2 <- data.frame(
      Value = c(RelESSB, RelEF, RelEBMSY, RelEFMSY, MohnsRhoSSB, MohnsRhoF),
      Metric = rep(c("% Relative Error in SSB", "% Relative Error in F", 
                     "% Relative Error in BMSY", "% Relative Error in FMSY",
                     "Mohn's Rho in SSB", "Mohn's Rho in F"), each = length(sims))
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

