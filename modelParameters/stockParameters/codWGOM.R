# WGOM Cod updated 12/12/2025 - aks

# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.

burnFmsyScalar <- 3.5 #GOM cod
burnFsd <- 0.3 # GOM cod
burnFsd <- 0  # Test removing stochasticity on F in the Burn-in

# first age and plus age
fage <- 1
page <- 9


### 2 fleets
pcom <- 0.725 # percent commercial

#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
# this LAA is not for WGOM cod, its from cod GOM - however all of the WGOM cod
# functions that could use LAA don't (all inputs), just a place holder so functions run
laa_par <- c(Linf = 150.93, K = 0.11, t0 = 0.13, beta1=0) #SAW 55
laa_typ <- 'vonB'

# weight-length parameters. Can be based on equation or input.
# avrg last 5 years 2024 management track assessment 
waa_par <- c(0.27888, 0.80764, 1.623, 2.58782, 3.69784, 5.07036, 6.34034, 6.77516, 9.36218)
waa_typ <- 'input'
waa_mis<-FALSE

# maturity-length parameters
# avrg last 5 years 2024 management track assessment 
#mat_par <- c(0.034097519, 0.194696978, 0.607443981, 0.868295767, 0.962022784, 0.990081819, 0.996724229, 0.999177172, 0.999812963) 
mat_par <- c(0.034097519, 0.194696978, 0.607443981, 0.868295767, 0.962022784, 1, 1, 1, 1) 

mat_typ <- 'input'

# natural mortality
M  <- 0.2
M_typ <- 'const'
init_M <- 0.2

# init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios
# M <- 0.4
# M_typ <- 'ramp'
# M_mis<-TRUE #If there is a M misspecification, set to TRUE
# M_mis_val<-0.2 #The misspecified M value


# initial numbers at-age parameters. Can be input or based on exponential decline.
# from WGOM input file N1_ini
initN_par <- c(15000, 17000, 6000, 3500, 2000, 200, 300, 150, 100)
initN_type <- 'input'
# initN_par <- c(nage = page, N0 = 2e7, F_full = 0.05, M = 0.2)
# initN_type <- 'expDecline'


#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001 ## HASNT BEEN UPDATED
qR <- 0.0001 ## HASNT BEEN UPDATED
qI <- 0.0001  # value from bigelow fall + spring (albatross is higher)

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE.

# fishery selectivity (Commerical)
## Commerical fishery selectivity from most recent selectivity time block
selC <- c(0.015224423, 0.146546166, 0.401664391, 0.746294723, 1, 1, 1, 0.737578292, 0.449978784) #

selC_typ <- 'input'

# fishery selectivity (Recreational)
## Recreational fishery selectivity from most recent selectivity time block
selR <- c(0.134726614, 0.634609979, 1, 1, 1, 1, 1, 0.561903842, 0.528056961) #
selR_typ <- 'input'

#### Recruitment Options ####
###For BH SR with relationship with temperature###
# f parameter is temperature effect placed on alpha in the numerator
# g parameter is temperature effect placed on beta parameter in the denominator
R_typ <- 'BH'
Rpar<-c(a=1.24,b=0.00005679, f =0, g=0) # no temperature effect

# WGOM BH with temp:
# only f or g should be used, depending on which BH parameter temperature modifies
Rpar<-c(a = 1366.812, b = 0.0001553159, f = 0,  g = 1.310604) # du Pontavice BT anomaly on the beta parameter in denominator


R_mis<-FALSE # If BRPs and projections assume a wrong SRR, set to TRUE.
# these are place holders, because R_mis = FALSE
# will need to update for WGOM COD
R_mis_typ<- 'HS' 
Rpar_mis <- c(SSB_star = 6300, #the 'wrong' SRR parameters that will be used in BRP estimation and projections
cR = 1,
Rnyr= 20)

#### Survey parameters ####

## Survey information
#selI <- c(1)
#selI_typ <- 'const'

selI <- c(0.167246964, 0.326401638, 0.398368285, 0.48120414, 0.683119399, 0.706269025, 0.768877092, 1, 1) #TESTING DIFF SELECTIVITY - MEAN OF ALL NEFSC BTS SELECTIVITIES
selI_typ <- 'input'
timeI <- 0.5 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 43 # from WGOM management track

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5 # HAVENT CHANGED

# CV for starting values for the assessment model
startCV <- 1.5 # HAVENT CHANGED

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1 # HAVENT CHANGED

#### Error parameters ####


if(nfleet == 1){
  oe_sumCW <- 0.05
  oe_sumCW_typ <- 'lognorm'
  
  oe_paaCN <- 100
  oe_paaCN_typ <- 'multinomial'
  
  
}



# observation error levels - Comm catch
oe_sumcomCW <- 0.05
oe_sumcomCW_typ <- 'lognorm'

oe_paacomCN <- 120
oe_paacomCN_typ <- 'multinomial'


### observation levels for the EM, used in get_WHAM if mproc CatchOEMis == TRUE, if FALSE oe_sumCW and oe_paaCW are used
oe_sumcomCW_EM <- 0.05
oe_paacomCN_EM <- 80

# observation error levels - Rec catch
oe_sumrecCW <- 0.25
oe_sumrecCW_typ <- 'lognorm'

oe_paarecCN <- 80
oe_paarecCN_typ <- 'multinomial'

### observation levels for the EM, used in get_WHAM if mproc CatchOEMis == TRUE, if FALSE oe_sumCW and oe_paaCW are used
oe_sumrecCW_EM <- 0.25
oe_paarecCN_EM <- 80

##########
oe_sumIN <- 0.25
oe_sumIN_typ <- 'lognorm'

oe_paaIN <- 80  #15 or 60 across surveys?
oe_paaIN_typ <- 'multinomial'

oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

oe_comeffort <- 0.01
oe_comeffort_typ <- 'lognorm'

oe_receffort <- 0.01
oe_receffort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.20 # cannot be zero # 0.68 is the sigma from lognormal BH w/du Pontavice BT anomaly on Beta
pe_RSA<- 0.20 #recruitment process error assumed in the stock assessment
pe_IA <- 0.18

# implementation error of fishing mortality
#!!!! right now in get_implementation there are not fleet specific biases, they all use the same biasses 
ie_F <- 0
ie_typ <- 'lognorm'
ie_bias <- 0 # % bias in implementation error (F_Full + F_Full*ie_bias)

# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.) (sumCW*ob_sumCW) (range 0.01-1)
ob_sumCW <- 1 #0.44 for bias
ob_sumcomCW <- 1 #0.44 for bias
ob_sumrecCW <- 1 #0.44 for bias

ob_sumIN <- 1

# catch observation bias (codCW + codCW*C_mult)
C_mult <-  0 #1.25 for bias, 0 for no bias

#bias change points
Change_point2<-FALSE #If TRUE, catch bias changes in the MP period
Change_point_yr<-2025 #year where catch bias changes
Change_point3<-FALSE #If TRUE, catch bias changes twice in the MP period
Change_point_yr1<-2020 #year where catch bias first changes
Change_point_yr2<-2022 #year where catch bias changes again

#### -- Errors and warnings -- ####
if(1.0 %in% c(qI, qC)){
  stop('catchability (qI and qC) must not be exactly one (you can make it
        however close you want though')
}
