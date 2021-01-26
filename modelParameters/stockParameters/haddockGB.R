# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.
burnFmsyScalar <- 1
burnFsd <- 0.4

# first age and plus age
fage <- 1
page <- 9


#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
#laa_par <- c(Linf=73.8, K=0.3763, t0=0.1649, beta1=0)#AEW
laa_par <- c(Linf=64.15, K=0.395, t0=0.285, beta1=0)#MDM (NEFSC 2015; average of spring and fall)
laa_typ <- 'vonB'

# weight-at-age parameters
#waa_par <- c(exp(-11.58571), 3.0205) #MDM (NEFSC 2015; annual length-weight)
#waa_typ <- 'aLb'
waa_par <- c(0.170,0.384,0.595,0.827,1.11,1.38,1.57,1.78,2.25) #Average of last 5 years of weight matrices from 2019 stock assessment 
waa_typ <- 'input'

# maturity-length parameters
#mat_par <- c(0.21, 29.7) #AEW
mat_par <- c(0.04, 0.34, 0.85, 0.98, 1.00, 1.00, 1.00, 1.00, 1.00) # GOM haddock (NEFSC 2019)
mat_typ <- 'input'

# natural mortality
M <- 0.2
M_typ <- 'const'
init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios
M_mis<-FALSE
#M_mis_val<-0.4

# initial numbers at-age parameters
initN_par <- c(nage = page, N0 = 1e4, F_full = 0.2, M = M)
initN_type <- 'expDecline'


#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001
qI <- 0.0001

DecCatch<-FALSE

# fishery selectivity
# ### change select to L50 paramaterization like maturity
selC <- c(0.000001,0.05,0.18,0.34,0.53,0.69,0.87,1,0.79) #NEFSC 2019 Catch block 3
selC_typ <- 'input'

# Recruitment
##HS with all recruitment values (what is used in stock assessment projections)##
Rpar <- c(SSB_star = 0, 
          cR = 1) # dont need to convert
R_typ <- 'HS'

##Ricker with increased frequency of high events with temp.
#Rpar <- c(a = 0.5540445, 
#         b = 0.0000174067) 
#R_typ <- 'IncFreq'
#### Survey parameters ####F

## Survey information
# slxI <- matrix(1, nrow=nyear, ncol=nage)
selI <- c(0.550,0.650,0.910,1,1,1,1,1,1)
selI_typ <- 'input'
timeI <- 0.5 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 33

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5

# CV for starting values for the assessment model
startCV <- 1.5

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1000

#### Error parameters ####

# observation error levels
oe_sumCW <- 0.01
oe_sumCW_typ <- 'lognorm'
oe_paaCN <- 1000
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.05
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 1000
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

highobserrec<-TRUE

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.5
pe_RSA<-1.0
pe_IA<-0.18

# implementation error of fishing mortality
ie_F <- 0
ie_typ <- 'lognorm'
ie_bias <- 0 # % bias in implementation error

# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.) (sumCW*ob_sumCW) (range 0.01-1)
ob_sumCW <- 1 #0.44 is bias
ob_sumIN <- 1

# catch observation bias (codCW + codCW*C_mult)
C_mult <- 0 #0 is no bias

Change_point2<-'FALSE'
Change_point_yr<-2025
Change_point3<-FALSE

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
