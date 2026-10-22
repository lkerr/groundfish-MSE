# BSB N created July 2026 - aks
# draft based on wham .dat

# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.

burnFmsyScalar <- 0 
burnFsd <- 0.3
burnFsd <- 0  # Test removing stochasticity on F in the Burn-in

# first age and plus age
fage <- 1
page <- 8


### 2 fleets
pcom <- 0.45 # percent commercial, based on 2023 MAFMC decision

#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
#laa_par <- c(Linf = 58.9, K = 0.22, t0 = 0.207, beta1=0) #SAW 62 fig A3
laa_par <- c(Linf = 54, K = 0.25, t0 = .28, beta1=0) #estimated from TOR1 figures, 23 research track
laa_typ <- 'vonB'

# weight-length parameters. Can be based on equation or input.
# avrg last 5 years
waa_par <- c(0.0988, 0.1860, 0.3248, 0.4744, 0.6852, 0.9000, 1.0682, 1.3240)
waa_typ <- 'input'
waa_mis<-FALSE

# maturity-length parameters
# avrg last 5 years .dat 
mat_par <- c(0, 0.4834835, 0.9844720, 1.000000,    1,    1,    1,    1) 
mat_typ <- 'input'

# natural mortality
M  <- 0.4
M_typ <- 'const'
init_M <- 0.4

# init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios
# M <- 0.4
# M_typ <- 'ramp'
# M_mis<-TRUE #If there is a M misspecification, set to TRUE
# M_mis_val<-0.2 #The misspecified M value


# initial numbers at-age parameters. Can be input or based on exponential decline.
initN_par <- c(45000, 16000,  8300,  5600,  2500,   400,   370,   100)
initN_type <- 'input'



#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001 ## HASNT BEEN UPDATED
qR <- 0.0001 ## HASNT BEEN UPDATED
qI <- 0.0001  # value from bigelow fall + spring (albatross is higher)

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE.

# fishery selectivity (Commerical)
## Commerical fishery selectivity last 5 years
selC <- c(0.08732325, 0.39798565, 0.60005253, 1, 1, 1, 1, 1) 
selC_typ <- 'input'

# fishery selectivity (Recreational)
## Recreational fishery selectivity last 5 years
selR <- c(0.03896097, 0.19076104, 0.20717187, 0.24516709, 0.35263215, 0.58156985, 1, 1)
selR_typ <- 'input'

#### Recruitment Options #### 
###For BH SR with relationship with temperature### 
# UPDATED FOR BSB - BUT NEED TO CONSIDER TEMP STILL
# f parameter is temperature effect placed on alpha in the numerator
# g parameter is temperature effect placed on beta parameter in the denominator
R_typ <- 'BH'
# only f or g should be used, depending on which BH parameter temperature modifies
Rpar<-c(a = 70760.39, b = 0.003769120, f = 0,  g = 0) 


R_mis<-FALSE # If BRPs and projections assume a wrong SRR, set to TRUE.
# these are place holders, because R_mis = FALSE
R_mis_typ<- 'HS' 
Rpar_mis <- c(SSB_star = 6300, #the 'wrong' SRR parameters that will be used in BRP estimation and projections
              cR = 1,
              Rnyr= 20)

#### Survey parameters ####

## Survey information 2025 MNGMNT , spring vast index (fall not used)
selI <- c(0.100, 0.513, 0.904, 0.979, 1, 1, 1, 1)
selI_typ <- 'input'
timeI <- 0.5 # when is the survey (as a proportion of the year)


#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 36 # from bsb management track 2025 (1989-2024)

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5 # HAVENT CHANGED

# CV for starting values for the assessment model
startCV <- 1.5 # HAVENT CHANGED

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1 # HAVENT CHANGED

#### Error parameters ####
#### HAVENT UPDATED JUST WANT TO KNOW IF IT RUNS
# STILL COD VALUES

if(nfleet == 1){
  oe_sumCW <- 0.05
  oe_sumCW_typ <- 'lognorm'
  
  oe_paaCN <- 100
  oe_paaCN_typ <- 'multinomial'
  
}



# observation error levels - Comm catch
oe_sumcomCW <- 0.05
oe_sumcomCW_typ <- 'lognorm'

oe_paacomCN <- 50
oe_paacomCN_typ <- 'multinomial'


### observation levels for the EM, used in get_WHAM if mproc CatchOEMis == TRUE, if FALSE oe_sumCW and oe_paaCW are used
oe_sumcomCW_EM <- 0.05
oe_paacomCN_EM <- 50

# observation error levels - Rec catch
oe_sumrecCW <- 0.1
oe_sumrecCW_typ <- 'lognorm'

oe_paarecCN <- 50
oe_paarecCN_typ <- 'multinomial'

### observation levels for the EM, used in get_WHAM if mproc CatchOEMis == TRUE, if FALSE oe_sumCW and oe_paaCW are used
oe_sumrecCW_EM <- 0.1
oe_paarecCN_EM <- 50

##########
oe_sumIN <- 0.25
oe_sumIN_typ <- 'lognorm'

oe_paaIN <- 50  #15 or 60 across surveys?
oe_paaIN_typ <- 'multinomial'

oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

oe_comeffort <- 0.01
oe_comeffort_typ <- 'lognorm'

oe_receffort <- 0.01
oe_receffort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 1 # cannot be zero # 0.68 is the sigma from lognormal BH w/du Pontavice BT anomaly on Beta
pe_RSA<- 1 #recruitment process error assumed in the stock assessment
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
