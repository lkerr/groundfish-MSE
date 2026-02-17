## ---- SIMULATION PARAMETERS ---- ##

# Which management procedures csv do you want to read:
mprocfile<-"mproc.csv"

#### Stock parameters ####

# If you have files in the modelParameters folder for stocks but you don't
# want to include them in a run you can write them in here in the
# stockExclude variable. Do not include the extension.R. For example,
# stockExclude <- 'haddockGB' (string) will leave haddockGB.R out of the analysis.
# stockExclude <- NULL indludes all stocks.
# Available stocks: haddockGB, codGOM, codGB_Error, pollock, yellowtailflounderGB, petraleBC
stockExclude <- c('haddockGB','codGOM', 'codGB_Error', 'pollock', 'yellowtailflounderGB')

#### historic assessment values #### AEW
# if you want to use an input of historic assessment data 

histAssess <- TRUE

#### Structural parameters ####
# First year to begin actual management
fmyear <- 2025

# first year after the initial condition period. The initial condition period
# simply fills up the arrays as necessary even before the burn-in period
# begins. This is rather arbitrary but should be larger than the number of
# years in the assessment model and greater than the first age in the model.
fyear <- 87

# maximum year predicted into the future
mxyear <- 2045

#### Burn-in parameters ####

# number of burn-in years 
nburn <- 50

#### Management ####

# Scalars to relate the calculated values of reference points to the
# threshold values. Typically this will be 0.4 and 0.8 for B msy and 1 for F (DFO 
# precautionary approach) but
# these can be changed.
USRScalar<- 0.8
BrefScalar <- 0.4
FrefScalar <- 1

#### Helpful parameters ####
# Scalars to convert things
pounds_per_kg<-2.20462
kg_per_mt<-1000

#Set up a counter for every year that has been simulated
yearcounter<-0