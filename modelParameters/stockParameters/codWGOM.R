# WGOM Cod updated 12/12/2025 - aks

# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.

burnFmsyScalar <- 4 #GOM cod
burnFsd <- 0.3 # GOM cod

# first age and plus age
fage <- 1
page <- 9

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
qI <- 0.0001  # value from bigelow fall + spring (albatross is higher)

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE.

# fishery selectivity
## aggregate fishery selectivity from most recent selectivity time block
selC <- c(0.042904915, 0.259597199, 0.540257864, 0.805060898, 1, 1, 1, 0.696886527, 0.468064162) #
# selC <- c(0.015, 0.147, 0.402, 0.746, 1, 1, 1, 0.738, 0.45) #### TESTING DIFFERENT SELECTIVITY
# selC <- c(0.009, 0.051, 0.241, 0.651, 0.917, 0.985, 0.997, 1, 1) #### Testing GOM cod values


selC_typ <- 'input'

#### Recruitment Options ####
###For BH SR with relationship with temperature###
R_typ <- 'BH'
Rpar<-c(a=1.24,b=0.00005679,g=0)

# WGOM BH with temp:
Rpar<-c(a = 0.7074441, b = 0.00002080295, g = -0.778952)

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
selI <- c(0.105426149, 0.356746855, 0.352910758, 0.353555439, 0.441094096, 0.524837583, 0.691394876, 1, 1) #Spring survey from 2024 management track, most recent time block
# selI <- c(0.227, 0.373, 0.291, 0.254, 0.291, 0.300, 0.384, 1, 1) #### TESTING DIFFERENT SELECTIVITY
# selI <- c(0.038, 0.134, 0.289, 0.531, 0.778, 1, 1, 1, 1) # testing GOM Cod values

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

# observation error levels
oe_sumCW <- 0.05
oe_sumCW_typ <- 'lognorm'

oe_paaCN <- 100
oe_paaCN_typ <- 'multinomial'


##########
oe_sumIN <- 0.25
oe_sumIN_typ <- 'lognorm'

oe_paaIN <- 100 #15 or 60 across surveys?
oe_paaIN_typ <- 'multinomial'

oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.25 # cannot be zero #0.5 for Beverton Holt
pe_RSA<- 0.5 #recruitment process error assumed in the stock assessment
pe_IA <- 0.18

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
