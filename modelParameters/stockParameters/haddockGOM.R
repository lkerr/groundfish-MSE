# GOM haddock updated 4/10/2026 - jrb
# Uses 2024 GOM haddock WHAM model. Assessment inputs from dat file, assessment results scraped from figures or tables.

# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.

burnFmsyScalar <- 4 #GOM cod carryover
burnFsd <- 0.3 # GOM cod carryover
burnFsd <- 0  # Remove stochasticity on F in the Burn-in


# first age and plus age
fage <- 1
page <- 9

#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
# this LAA is not for GOM haddock, it is carried over from haddock GB - however all the GOM haddock
# functions that could use LAA don't (all inputs), just a place holder so functions run
### Need to confirm/convert that LAA is not used and all are WAA input-based
laa_par <- c(Linf=73.8, K=0.3763, t0=0.1649, beta1=5)  #AEW
laa_typ <- 'vonB'

# weight-length parameters. Can be based on equation or input.
# avrg last 5 years 2024 management track assessment input for SSB and NEFSC Spring survey. WAA Matrix 2 in dat file.
##### Haddock growth has declined over time. Mostly attributed to density dependence, but not completely.
waa_par <- c(0.204, 0.422, 0.614, 0.748, 0.828, 0.946, 1.136, 1.188, 1.396)
waa_typ <- 'input'
waa_mis<-FALSE

# maturity-length parameters. From 2024 management track assessment, which uses a static maturity-at-age vector
mat_par <- c(0.092064612, 0.301772678, 0.648155463, 0.887029651, 0.970986882, 0.993038516, 0.998357986, 0.999614275, 0.999909477) 

mat_typ <- 'input'

# natural mortality. From 2024 management track assessment, which uses a static lifetime M=0.2
M  <- 0.2
M_typ <- 'const'
init_M <- 0.2

# initial numbers at-age parameters. Can be input or based on exponential decline.
# from 2024 management track assessment. GOM haddock dat file N1_ini
initN_par <- c(6599, 1377, 1888, 2204, 588, 463, 1, 5, 20)
initN_type <- 'input'
# initN_par <- c(nage = page, N0 = 2e7, F_full = 0.05, M = 0.2)
# initN_type <- 'expDecline'


#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001 ## HASNT BEEN UPDATED
qI <- 0.0001  # value from bigelow fall + spring (albatross is higher)

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE.

# fishery selectivity. From 2024 management track assessment, which has a single aggregate fleet. Using most recent selectivity time block.
selC <- c(0.02, 0.12, 0.33, 0.54, 0.73, 1, 1, 1, 1) # scraped from figures
selC_typ <- 'input'

#### Recruitment Options ####

###For BH SR with relationship with temperature###
R_typ <- 'BH'

# Haddock GOM BH with temp (r increases w/ temp):
Rpar<-c(a = 1.5193511, b = 0.0004695, g = -1.3659508) #### THESE ARE W/ TEMP IS IN DENOMINATOR. CHECK TO MAKE SUREIN IT IS IN OM

# No temperature (appeared to underestimate R at high SSB)
Rpar<-c(a=0.6956046,b=0.0001242,g=0)

R_mis<-FALSE # If BRPs and projections assume a wrong SRR, set to TRUE.
# these are place holders, because R_mis = FALSE
# will need to update for GOM haddock if using
R_mis_typ<- 'HS' 
Rpar_mis <- c(SSB_star = 6300, #the 'wrong' SRR parameters that will be used in BRP estimation and projections
cR = 1,
Rnyr= 20)

#### Survey parameters ####

## Survey information
#selI <- c(1)
#selI_typ <- 'const'
selI <- c(0.6, 0.62, 0.91, 1, 1, 1, 1, 1, 1) #Spring survey from 2024 management track, most recent time block
selI_typ <- 'input'
timeI <- 0.5 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 47 # from GOM haddock 2024 management track

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5 # HAVENT CHANGED

# CV for starting values for the assessment model
startCV <- 1.5 # HAVENT CHANGED

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1 # HAVENT CHANGED

#### Error parameters ####

# observation error levels
oe_sumCW <- 0.1 # from GOM haddock 2024 management track dat file. Most recent 20 or so years use this.
oe_sumCW_typ <- 'lognorm'

oe_paaCN <- 140 # from GOM haddock 2024 management track dat file. Most recent 20 or so years use this.
oe_paaCN_typ <- 'multinomial'


##########
oe_sumIN <- 0.43 # from GOM haddock 2024 management track dat file. Mean of all CVs for Spring BTS. Fall is 0.40
oe_sumIN <- 0.33 # from GOM haddock 2024 management track dat file. Mean of 10 most recent CVs for Spring BTS. Fall is 0.36
oe_sumIN_typ <- 'lognorm'

oe_paaIN <- 25 # from GOM haddock 2024 management track dat file. Most recent 20 or so years use this. Fall uses 12.
oe_paaIN_typ <- 'multinomial'

oe_effort <- 0.01  #### DID NOT CHANGE
oe_effort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.25 # cannot be zero # 0.5 for Beverton Holt # DID NOT CHANGE THIS, SHOULD BE INFORMED BY SR MODEL ESTIMATION
pe_RSA<- 1 # recruitment process error assumed in the stock assessment. Recruitment CV from 2024 GOM haddock management track dat file.
pe_IA <- 0.18 #### DID NOT CHANGE. DON'T KNOW WHERE THIS VALUE IS FROM

############### Implementation and bias settings. Did not change any, all should be off.
# implementation error of fishing mortality
ie_F <- 0
ie_typ <- 'lognorm'
ie_bias <- 0 # % bias in implementation error (F_Full + F_Full*ie_bias)

# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.) (sumCW*ob_sumCW) (range 0.01-1)
ob_sumCW <- 1 #0.44 for bias
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
