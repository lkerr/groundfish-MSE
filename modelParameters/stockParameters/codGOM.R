


# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.                                              
burnFmsyScalar <- 5
burnFsd <- 0.3


# first age and plus age
fage <- 1
page <- 9


#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
laa_par <- c(Linf = 150.93, K = 0.11, t0 = 0.13, beta1=0) #SAW 55
laa_typ <- 'vonB'

# weight-length parameters
#waa_par <- c(exp(-12.18002), 3.1625) #SAW 55 #kg
#waa_typ <- 'aLb'
waa_par <- c(0.057, 0.365, 0.908, 1.662, 2.426, 3.307, 4.09, 5.928, 10.375) #GOM cod ADAPT projection Jan1 M=0.2
waa_typ <- 'input'


# maturity-length parameters
#mat_par <- c(0.171, 32.1) # O'brien GOM cod female
#mat_typ <- 'logistic'
mat_par <- c(0.087, 0.318, 0.697, 0.919, 0.982, 0.996, 0.999, 1, 1) # GOM cod ADAPT projection M=0.2
mat_typ <- 'input'


# natural mortality
M <- 0.2
M_typ <- 'const'
init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios
M_mis<- 'FALSE'
#M <- 0.4
#M_typ <- 'ramp'

# initial numbers at-age parameters
#initN_par <- c(15000, 17000, 6000, 3500, 2000, 200, 300, 150, 100)
#initN_type <- 'input'
initN_par <- c(nage = page, N0 = 2e7, F_full = 0.05, M = 0.2)
initN_type <- 'expDecline'



#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001
qI <- 0.0001

# fishery selectivity
# ### change select to L50 paramaterization like maturity
#selC <- c(s0 = 3, s1 = 0.5)
#selC_typ <- 'Logistic'
selC <- c(0.013, 0.066, 0.271, 0.663, 0.912, 0.982, 0.997, 1, 1) #GOM cod AGEPRO M=0.2
selC <- c(0.3, 0.3, 0.3, 0.663, 0.912, 0.982, 0.997, 1, 1) #GOM cod AGEPRO M=0.2!!!!!!!<<<<
#selC <- c(0.009, 0.051, 0.241, 0.651, 0.917, 0.985, 0.997, 1, 1) #GOM cod AGEPRO M-ramp
selC_typ <- 'input'


# Recruitment #AEW from GOM COD 2019 Update M0.2 .rep
# Rpar <- c(h = 1,
#           R0 = 4456870,
#           SSBRF0 = 0.01822) # calculated as S0/R0 (81202.9/4456870) (arbitrary because h = 1)
# R_typ <- 'BHSteep'
# Rpar <- c(SSB_star = 6300, #mt  #from GOM COD 2019 AGEPRO M=0.2
          # cR = 1) # dont need to convert
#Rpar <- c(SSB_star = 7900, #mt  #from GOM COD 2019 MRAMP 
#          cR = 1) # dont need to convert
# R_typ <- 'HS'

Rpar <- c(a = 2.904e+03, # see meetings/2021-03-25_lisaMackenzie
          b = 6.615e-05, # 6.615e-05,
          c = -2)#-1.825e+00)
R_typ <- 'BH'
# SSBUnitScalar <- 0.001


 



#### Survey parameters ####

## Survey information
#selI <- c(1)
#selI_typ <- 'const'
selI <- c(0.0384337, 0.13369, 0.288846, 0.531086, 0.778406, 1, 1, 1, 1) #Spring survey fit from 2019 assessment .rep
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
caaInScalar <- 1 


#### Error parameters ####

# observation error levels
oe_sumCW <- 0.05
oe_sumCW_typ <- 'lognorm'
oe_paaCN <- 80
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.05
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 100 #15
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.01 # cannot be zero 

# implementation error of fishing mortality
ie_F <- 0
ie_typ <- 'lognorm'
ie_bias <- 0 # % bias in implementation error (F_Full + F_Full*ie_bias)


# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.) (sumCW*ob_sumCW) (range 0.01-1)
ob_sumCW <- 1
ob_sumIN <- 1

# catch observation bias (codCW + codCW*C_mult)
C_mult <- 0

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



