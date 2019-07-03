


## ---- SIMULATION PARAMETERS ---- ##


#### Debugging ####

# Debug? (windows only for now...) (T/F)
debugSink <- FALSE

# Debug using simple temperature trend that reduces variance? (T/F)
simpleTemperature <- FALSE

# Testing run which uses mprocTest.txt instead of mproc.txt? (T/F)
mprocTest <- FALSE


#### Stock parameters ####

# If you have files in the modelParameters folder for stocks but you don't
# want to include them in a run you can write them in here in the
# stockExclude variable. Do not include the extension.R. For example,
# stockExclude <- haddockGB will leave haddockGB.R out of the analysis.
# stockExclude <- NULL indludes all stocks.
stockExclude <- c('codGB_R0', 'codGB_Steep', 'haddockGB')


#### Structural parameters ####

# number of times to repeat this analysis
nrep <- 1

# First year to begin actual management
fmyear <- 2000

# first year after the initial condition period  !!!! DEFINE THIS BETTER !!!!
fyear <- 5

# maximum year predicted into the future
mxyear <- 2050


#### Burn-in parameters ####

# number of burn-in years (before the pre-2000 non-assessment period)
nburn <- 50


#### Temperature information ####

## Do you want to include temperature projections (in S-R, growth, etc.)
useTemp <- FALSE

## Temperature information ##
cmip5model <- 'CMCC_CM'

## Reference years for temperature downscale
ref0 <- 1982
ref1 <- 2018

## Reference year and function for anomaly calculation
baseTempYear <- 1985
anomFun <- median

# Number of model years to run are defined by the length of the burn-in
# period and the dimension of the CMIP5 data set.
# Load the cmip5 temperature data
# cmip5 <- read.table(file='data/data_raw/NEUS_CMIP5_annual_means.txt',
#                     header=TRUE, skip=2)
# cmip5 <- subset(cmip5, year <= mxyear)

# nyear <- nrow(cmip5) + nburn


#### Management ####

# Scalars to relate the calculated values of reference points to the
# threshold values. Typically this will be 1/2 for Bmsy and 0.75 for F but
# these can be changed to examine sensitivity.
BrefScalar <- 0.5
FrefScalar <- 0.75


#### Output ####
# Years after the management period begins to break up the results. For
# example, c(10, 20) would result in plots from 0-10 years after the mgmnt
# period begins, 10-20 years and 20 years to the end of the series.
plotBrkYrs <- c(5, 10, 20)

# Which sets of plots should be created? Set these objects to T/F

# Boxplots of performance measures
plotBP <- TRUE

# Extra folder of reference point plots
plotRP <- FALSE

# Population drivers like temperature, recruitment growth histories
# and selectivity plots
plotDrivers <- TRUE

# Trajectories over different metrics
plotTrajInd <- FALSE     # samples of individual trajectories
plotTrajBox <- FALSE     # boxplots of trajectories
plotTrajSummary <- TRUE  # summary statistics




