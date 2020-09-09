


# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.
burnFmsyScalar <- 1.5
burnFsd <- 0.5


# first age and plus age
fage <- 1
page <- 9


#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
laa_par <- c(Linf=73.8, K=0.3763, t0=0.1649, beta1=5)  #AEW
laa_typ <- 'vonB'

# weight-length parameters
waa_par <- c(exp(-11.73233), 3.059) 
waa_typ <- 'aLb'

# maturity-length parameters
mat_par <- c(0.21, 29.7) #AEW
mat_typ <- 'logistic'

# natural mortality
M <- 0.2
M_typ <- 'const'
init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios
M_mis<-FALSE

# initial numbers at-age parameters
initN_par <- c(nage = page, N0 = 2e7, F_full = 0.05, M = M)
initN_type <- 'expDecline'


#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001
qI <- 0.0001

# fishery selectivity
# ### change select to L50 paramaterization like maturity
selC <- c(s0=5, s1=0.08)
selC_typ <- 'Logistic'

# Recruitment (parameters need updating!!!)
##BHSteep###
#Rpar <- c(h = 6.286813e-01,
         # R0 = 8.062700e+07,
        #  c = -0.540,
        #  SSBRF0 = 0.01972,
        #  sigR = 0.56,
         # beta3 = -2.501400e-01)
#R_typ <- 'BHSteep'

##Ricker##
#Rpar<- c(a=0.3591554,b=0.0000006275757,g=0)
#R_typ<-'Ricker'

##GammaDist## (for Georges Bank haddock, randomly drawn from a gamma distribution.
#There are two different distributions that depend on temperature.)
R_typ<-'GammaDist'
Rpar<- NA

#### Survey parameters ####

## Survey information
# slxI <- matrix(1, nrow=nyear, ncol=nage)
selI <- c(1)
selI_typ <- 'const'
timeI <- 0.5 # when is the survey (as a proportion of the year)


#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 30

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5

# CV for starting values for the assessment model
startCV <- 1.5

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1000

#### Error parameters ####

# observation error levels
oe_sumCW <- 0.05
oe_sumCW_typ <- 'lognorm'
oe_paaCN <- 1000
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.2
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 1000
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.5

# implementation error of fishing mortality
ie_F <- 0
ie_typ <- 'lognorm'
ie_bias <- 0 # % bias in implementation error

# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.) (sumCW*ob_sumCW) (range 0.01-1)
ob_sumCW <- 0.44
ob_sumIN <- 1

# catch observation bias (codCW + codCW*C_mult)
C_mult <- 1.25


#### BRPs and HCRs ####

# # reference point calculation types
# # Fmsy proxy type
# fbrpTyp <- c('YPR')
# # Bmsy proxy type
# bbrpTyp <- c('RSSBR')
#
# # Fmsy proxy level
# fbrpLevel <- c(0.1)
# # Bmsy proxy level
# bbrpLevel <- c(1)
#
# # Fmsy proxy types and levels
# fbrp <- rbind(
#   list('YPR', 0.1),
#   list('RSSBR', 1)
# )
# pol <- data.frame(
#   FmsyT = c('YPR'  ,   'SPR'        ),
#   FmsyV = c(0.1    ,     1          ),
#   BmsyT = c('RSSBR' ,   'dummy'      ),
#   hcrT  = c('slide'  ,  'simpleThresh')
# )
#
#
# FmsyT <- list('YPR', 'SPR')
# FmsyV <- list(c(0.1, 0.15),
#               c(0.3, 0.4))
# # i1 <- lapply(1:length(a1), function(x) expand.grid(a1[[x]], a2[[x]]))
#
# BmsyT <- list('RSSBR', 'BmsySim')
# BmsyV <- list(c(1, 0.8),
#               c(NA, NA))
# i2 <- lapply(1:length(BmsyT), function(x) expand.grid(BmsyT[[x]], BmsyV[[x]]))
#
# # Harvest control rule types
# i3 <- list('slide', 'simpleThresh')
#
#
# hrcTyp <- list('slide', 'simpleThresh')




#### -- Errors and warnings -- ####
if(1.0 %in% c(qI, qC)){
  stop('catchability (qI and qC) must not be exactly one (you can make it
        however close you want though')
}
