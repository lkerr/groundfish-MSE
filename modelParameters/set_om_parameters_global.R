


## ---- SIMULATION PARAMETERS ---- ##


#### Debugging ####

# Debug using simple temperature trend that reduces variance? (T/F)
simpleTemperature <- FALSE

# Testing run which uses mprocTest.txt instead of mproc.txt? (T/F)
mprocTest <- FALSE #TRUE #AEW


#### Stock parameters ####

# If you have files in the modelParameters folder for stocks but you don't
# want to include them in a run you can write them in here in the
# stockExclude variable. Do not include the extension.R. For example,
# stockExclude <- 'haddockGB' (string) will leave haddockGB.R out of the analysis.
# stockExclude <- NULL indludes all stocks.
stockExclude <- c()


#### Structural parameters ####

# number of times to repeat this analysis
nrep <- 1

# First year to begin actual management
fmyear <- 2000

# first year after the initial condition period. The initial condition period
# simply fills up the arrays as necessary even before the burn-in period
# begins. This is rather arbitrary but should be larger than the number of
# years in the assessment model and greater than the first age in the model.
fyear <- 35

# maximum year predicted into the future
mxyear <- 2050


#### Burn-in parameters ####

# number of burn-in years (before the pre-2000 non-assessment period)
nburn <- 50


#### Temperature information ####

## Do you want to include temperature projections (in S-R, growth, etc.)
useTemp <- TRUE

## Do you want to use particular models from the cmip data series? If so
## tmods should be a vector of column names (see 
## data/data_raw/NEUS_CMIP5_annual_meansLong.csv'). If NULL use all data
tmods <- NULL

## The temperature quantile of the cmip data series to use. 0.5 for median.
tq <- 0.5

## Representative concentration pathway to use. Currently only 8.5 available.
trcp <- 8.5

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


#### Helpful parameters ####
# Scalars to convert things
pounds_per_kg<-2.20462
kg_per_mt<-1000
# Set the economic years that we'll use for simulation.  Right now, we'll pass  in 1 year.
#baseEconYrs<-c(2009,2010)
baseEconYrs<-c(2009)


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




