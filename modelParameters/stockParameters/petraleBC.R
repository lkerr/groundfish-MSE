# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.                                              
burnFmsyScalar <- 0.098
burnFsd <- 0.07

# first age and plus age
fage <- 1
page <- 22

#### Life history parameters ####

# length-at-age parameters -- see get_lengthAtAge for including covariates
laa_par <- c(Linf = 49.315, K = 0.20, t0 = -1.098, beta1=0) #Average of male and female pars from stock assessment 
laa_typ <- 'vonB'

# weight-length parameters
# waa_par <- c(5.95e-06, 3.185) #Averages of male and female parameters from the stock assessment
# waa_typ <- 'aLb'
waa_par <- c(0.04465863, 0.11729380, 0.21728040, 0.33341664, 0.45553204, 0.57593700, 0.68951956, 0.79331939, 0.88597832, 0.96723643, 1.03752976,
             1.09769401, 1.14875906, 1.19181382, 1.22792259, 1.25807722, 1.28317321, 1.30400128, 1.32124843, 1.33550423, 1.34727002, 1.35696896) #Modeled from data
waa_typ <- 'input'
waa_mis<-FALSE

# maturity-length parameters
#mat_par <- c(0.171, 32.1) # O'brien GOM cod female
#mat_typ <- 'logistic'
mat_par <- c(0.00784631, 0.01829243, 0.04205639, 0.09374444, 0.19596285, 0.36477656,
             0.57501366, 0.76121738, 0.88250762, 0.94651687, 0.97657965, 0.98992408,
             1, 1, 1, 1, 1, 1, 1, 1, 1, 1) 
mat_typ <- 'input'

# natural mortality
M  <- 0.354
M_typ <- 'ramp'
init_M <- 0.154 #same for M = 0.2 and M-ramp scenarios
# M <- 0.4
#M_typ <- 'ramp'
M_mis<-TRUE #If there is a M misspecification, set to TRUE
M_mis_val<-0.154 #The misspecified M value
MRE<-TRUE

# initial numbers at-age parameters
#initN_par <- c(15000, 17000, 6000, 3500, 2000, 200, 300, 150, 100)
#initN_type <- 'input'
initN_par <- c(nage = page, N0 = 8790430, F_full = 0.0013172, M = 0.154)
initN_type <- 'expDecline'

#### Fishery parameters ####

# fishery and survey catchabilities
qC <- 0.01
qI <- 0.01

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE. 

IncCatch<-FALSE

# fishery selectivity
# ### change select to L50 paramaterization like maturity
#selC <- c(s0 = 3, s1 = 0.5)
#selC_typ <- 'Logistic'
#selC <- c(0.013, 0.066, 0.271, 0.663, 0.912, 0.982, 0.997, 1, 1) #GOM cod AGEPRO M=0.2
selC <- c(8.296989e-08, 2.207619e-07, 2.033618e-04, 5.634182e-02,6.569636e-01, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) #Average of female and male fishery selectivities from stock assessment
selC_typ <- 'input'

#### Recruitment Options ####
##For BH Steepness Option##
Rpar <- c(h = 0.7,
          R0 = 10301.04,
          SSBRF0 = 1.757298) # calculated as S0/R0 (81202.9/4456870) (arbitrary because h = 1)
R_typ <- 'BHSteep'
##For Hockey-stick (Default) Option##
# Rpar <- c(SSB_star = 6300, #mt  #from GOM COD 2019 AGEPRO M=0.2
#     cR = 1,# dont need to convert
#      Rnyr= 20)#recruitment is drawn from the recruitment distribution of the last X years (x=Rnyr)
#Rpar <- c(SSB_star = 2900,
#          cR = 1,
#          Rnyr=20,
#         Rinc='FALSE') # dont need to convert
#R_typ <- 'HS'
###For BH SR with relationship with temperature###
# R_typ <- 'BH'
#Rpar<-c(a=5.1698169,b=0.0002892,g=-1.423)
# Rpar<-c(a=5.1479515,b=0.0002547,g=-0.8996322)
R_mis<-FALSE #If BRPs and projections assume a 'wrong' SRR, set to TRUE.
Rpar_mis <- c(h = 0.6,
              R0 = 10509.13,
              SSBRF0 = 1.722502,
              Rinc='TRUE')
h<-0.6
RER<-FALSE
# Rpar_mis<-c(a=5.1479515,b=0.0002547,g=0)

#### Survey parameters ####

## Survey information
#selI <- c(1)
#selI_typ <- 'const'

selI <- c(0.01877326, 0.09209844, 0.30161157, 0.65936678, 0.96233337, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 1) #Average of estimated index selectivities
selI_typ <- 'input'
timeI <- 0.5 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 86

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
oe_paaCN <- 600 #base is 600
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.15
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 700 #base is 700
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.01
oe_effort_typ <- 'lognorm'
gapinage<-FALSE
norecentage<-FALSE

# process error levels  #####o##############################  !!!!!!!!!!!!!!
pe_R <- 0.636 # cannot be zero #0.5 for Beverton Holt
pe_RSA<- 0.636 #recruitment process error assumed in the stock assessment 
pe_IA <- 0.15 #mean of index CV from assessment

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





