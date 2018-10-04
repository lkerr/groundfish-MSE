
devtools::install_github("cmlegault/PlanBsmooth")

library(PlanBsmooth)
library(tidyverse)

setwd("C:/Users/struesdell/OneDrive - Gulf of Maine Research Institute/GMRI/COCA/scratch/trialPlanB")
# ffiles <- list.files(path='PlanBsmooth-master/R', full.names=TRUE, recursive=TRUE)
# invisible(sapply(ffiles, source))



ragbk <- ReadADIOS(data.dir = 'PlanBsmooth-master/data',
                   adios.file.name = 'ADIOS_SV_164712_GBK_NONE_strat_mean',
                   standardize = TRUE,
                   usesurvey = NA,
                   saveplots = TRUE)

ragom <- ReadADIOS(data.dir = 'PlanBsmooth-master/data',
                   adios.file.name = 'ADIOS_SV_172909_CCGOM_NONE_strat_mean',
                   standardize = TRUE,
                   usesurvey = NA,
                   saveplots = TRUE)

pbgbk <- ApplyPlanBsmooth(dat = ragbk,
                          od = 'gbk/',
                          my.title = 'gbcod',
                          terminal.year = NA,
                          nyears = 33,
                          saveplots = TRUE,
                          showplots = TRUE)

pbgom <- ApplyPlanBsmooth(dat = ragom,
                          od = 'gom/',
                          my.title = 'gomcod',
                          terminal.year = NA,
                          nyears = 33,
                          saveplots = TRUE,
                          showplots = TRUE)

