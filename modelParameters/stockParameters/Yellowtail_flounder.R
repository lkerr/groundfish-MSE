# Fmsy scalar and sd for F before the management period begins. Distribution is lognormal. SD is lognormal SD.                                              
burnFmsyScalar <- 1.5
burnFsd <- 0.5

# first age and plus age
fage <- 1
page <- 6

#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
laa_par <- c(Linf=50, K=0.335, t0=0.26, beta1=5)  
laa_typ <- 'vonB'

# weight-length parameters
waa_par <- c(0.356,0.859,1.511,2.597,5.074,7.062) 
waa_typ <- 'input'

# maturity-length parameters
mat_par <- c(0.09,0.32,0.7,0.92,0.98,1) 
mat_typ <- 'input'

# natural mortality
M <- 0.2
M_typ <- 'const'
init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios

# initial numbers at-age parameters
initN_par <- c(nage = page, N0 = 2e7, F_full = 0.05, M = 0.2)
initN_type <- 'expDecline'

# Recruitment (parameters need updating!!!)
Rpar <- c(h = 6.286813e-01,      #update all
          R0 = 8.062700e+07,
          c = -0.540,
          SSBRF0 = 0.01972,
          sigR = 0.56,
          beta3 = -2.501400e-01)

R_typ <- 'BHSteep'


#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001
qI <- 0.0001

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE.

# fishery selectivity
# ### change select to L50 paramaterization like maturity
selC <- c(s0=5, s1=0.08)
selC_typ <- 'Logistic'

#### Survey parameters ####

## Survey information
# slxI <- matrix(1, nrow=nyear, ncol=nage)
selI <- c(1)
selI_typ <- 'const'
timeI <- 0.5 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 42

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5

# CV for starting values for the assessment model
startCV <- 1.5

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1000  

# stock assessment misspecifications
M_mis<- FALSE
M_mis_val<-0.2
R_mis<- FALSE
Rpar_mis <- c(SSB_star = 6300, #the 'wrong' SRR parameters that will be used in BRP estimation and projections
              cR = 1,
              Rnyr= 20)
waa_mis<- FALSE


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
pe_RSA<- 0.5 #recruitment process error assumed in the stock assessment
pe_IA <- 0.18

# implementation error of fishing mortality
ie_F <- 0
ie_typ <- 'lognorm'
ie_bias <- 0 # % bias in implementation error

# Observation bias (1 is no bias, 0.9 is a -10% bias, etc.)
ob_sumCW <- 1
ob_sumIN <- 1

#### -- Errors and warnings -- ####
if(1.0 %in% c(qI, qC)){
  stop('catchability (qI and qC) must not be exactly one (you can make it
        however close you want though')
  }
