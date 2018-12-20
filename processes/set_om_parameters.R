

## ---- SIMULATION PARAMETERS ---- ##


#### Debugging ####

# Debug? (windows only for now...)
debugSink <- FALSE

# Debug using simple temperature trend that reduces variance?
simpleTemperature <- TRUE


#### Structural parameters ####

# number of times to repeat this analysis
nrep <- 2

# first age and plus age
fage <- 1
page <- 15

# First year to begin actual management
fmyear <- 2000

# first year after the initial condition period  !!!! DEFINE THIS BETTER !!!!
fyear <- 5

# maximum year predicted into the future
mxyear <- 2050

# number of years in assessment model
ncaayear <- 30 


#### Burn-in parameters ####

# number of burn-in years (before the pre-2000 non-assessment period)
nburn <- 50

# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.                                              
burnFmean <- 0.5
burnFsd <- 0.2


#### Temperature information ####

## Do you want to include temperature projections (in S-R, growth, etc.)
useTemp <- TRUE

## Temperature information ##
cmip5model <- 'CMCC_CM'

## Reference years for temperature downscale
ref0 <- 1982
ref1 <- 2018
  
  # Number of model years to run are defined by the length of the burn-in
  # period and the dimension of the CMIP5 data set.
  # Load the cmip5 temperature data
  # cmip5 <- read.table(file='data/data_raw/NEUS_CMIP5_annual_means.txt',
  #                     header=TRUE, skip=2)
  # cmip5 <- subset(cmip5, year <= mxyear)

  # nyear <- nrow(cmip5) + nburn


#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
laa_par <- c(Linf=114.1, K=0.22, t0=0.17, beta1=5)
laa_typ <- 'vonB'

# weight-length parameters
waa_par <- c(exp(-11.6913), 3.0219) #SAW 55 p.659
waa_typ <- 'aLb'

# maturity-length parameters
mat_par <- c(0.127, 38.8) # O'brien GB cod female
mat_typ <- 'logistic'

# natural mortality
M <- 0.2

# Recruitment
load('data/data_processed/SR/cod/BHTS.Rdata') #srpar
# include stochasticity in recruitment parameter estimates?
Rstoch_par <- FALSE
# include stochasticity in annual recruitment estimate?
Rstoch_ann <- FALSE


#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.01
qI <- 1.0

# fishery selectivity
# ### change select to L50 paramaterization like maturity
selC <- c(s0=5, s1=0.08)
selC_typ <- 'Logistic'

# Recruitment
Rpar <- c(a = 1.953864e+07,
          b = 3.631550e+04,
          c = 0.3,
          rho = 0,
          sigR = 1.0)


# load('data/data_processed/SR/cod/BHTS.Rdata') #srpar

## REMOVED parameters relating to R stochasticity -- prefer to adjust this
## using the parameters.
# include stochasticity in recruitment parameter estimates?
# Rstoch_par <- FALSE
# include stochasticity in annual recruitment estimate?
# Rstoch_ann <- FALSE

#### Survey parameters ####

## Survey information
# slxI <- matrix(1, nrow=nyear, ncol=nage)
selI <- c(1)
selI_typ <- 'const'
timeI <- 0.5 # when is the survey (as a proportion of the year)


#### Error parameters ####

# observation error levels
oe_sumCW <- 0.05
oe_sumCW_typ <- 'lognorm'
oe_paaCN <- 100
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.2
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 100
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 1.5

# implementation error of fishing mortality
ie_F <- 0

# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.)
ob_sumCW <- 1
ob_sumIN <- 1


#### BRPs and HCRs ####

# reference point calculation types
# Fmsy proxy type
fbrpTyp <- c('YPR')
# Bmsy proxy type
bbrpTyp <- c('RSSBR')

# Fmsy proxy level
fbrpLevel <- c(0.1)
# Bmsy proxy level
bbrpLevel <- c(1)

# Fmsy proxy types and levels
fbrp <- rbind(
  list('YPR', 0.1),
  list('RSSBR', 1)
)
pol <- data.frame(
  FmsyT = c('YPR'  ,   'SPR'        ),
  FmsyV = c(0.1    ,     1          ),
  BmsyT = c('RSSBR' ,   'dummy'      ),
  hcrT  = c('ns1'  ,  'simpleThresh')
)


FmsyT <- list('YPR', 'SPR')
FmsyV <- list(c(0.1, 0.15),
              c(0.3, 0.4))
# i1 <- lapply(1:length(a1), function(x) expand.grid(a1[[x]], a2[[x]]))

BmsyT <- list('RSSBR', 'BmsySim')
BmsyV <- list(c(1, 0.8),
              c(NA, NA))
i2 <- lapply(1:length(BmsyT), function(x) expand.grid(BmsyT[[x]], BmsyV[[x]]))

# Harvest control rule types
i3 <- list('ns1', 'simpleThresh')


hrcTyp <- list('ns1', 'simpleThresh')








