# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.
burnFmsyScalar <- 4
burnFsd <- 0.3

# first age and plus age
fage <- 1
page <- 9

#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
laa_par <- c(Linf=73.8, K=0.3763, t0=0.1649, beta1=5)  #AEW
laa_typ <- 'vonB'

# weight-at-age parameters
waa_par <- c(0.1774,0.4291,0.6939,0.8887,1.089,1.247,1.396,1.577,1.784) #Average of waa of last 5 years from 2019 assessment
waa_typ <- 'dynamic'
waa_mis <- TRUE
#####

# maturity-length parameters
#mat_par <- c(0.21, 29.7) #AEW
mat_par <- c(0.0338,0.2592,0.7464,0.9532,0.9928,0.9988,1,1,1) # GB haddock, average of recent 5 years (NEFSC 2019)
mat_typ <- 'input'

# natural mortality
M <- 0.2
M_typ <- 'const'
init_M <- 0.2 #same for M = 0.2 and M-ramp scenarios
M_mis<-FALSE
#M_mis_val<-0.4

# initial numbers at-age parameters
initN_par <- c(nage = page, N0 = 1e4, F_full = 1.1, M = M)
initN_type <- 'expDecline'

#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.0001
qI <- 0.0001

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE. 

# fishery selectivity
# ### change select to L50 paramaterization like maturity
selC <- c(0.0114,0.0296,0.1014,0.3002,0.3976,0.6324,0.9574,0.6626,0.6626)#average of last 5 years in stock assessment (2019)
selC_typ <- 'input'

# Recruitment
##HS with all recruitment values (what is used in stock assessment projections)##
Rpar <- c(SSB_star = 75000, #Used in projections (NEFSC 2019)
          cR = 1,
          Rnyr= 20) # dont need to convert
R_typ <- 'HS'
##For regular BH
#R_typ <- 'BH'
#Rpar<-c(a=0.0004313,b=0.000002392,g=0)
R_mis<-FALSE #If BRPs and projections assume a wrong SRR, set to TRUE. 
Rpar_mis <- c(cR = 1,
              Rnyr= 20)

#### Survey parameters ####

## Survey information
selI <- c(0.444,0.697,0.755,0.759,0.779,0.712,0.807,0.772,0.772) #catchabilities from the VPA
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

highobserrec<-FALSE

# process error levels  ###################################  !!!!!!!!!!!!!!
pe_R <- 0.01
pe_RSA<-1.0
pe_IA<-0.378

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


#### -- Errors and warnings -- ####
if(1.0 %in% c(qI, qC)){
  stop('catchability (qI and qC) must not be exactly one (you can make it
        however close you want though')
}
