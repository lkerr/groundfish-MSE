
# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.                                              
burnFmsyScalar <- 4
burnFsd <- 0.3

# first age and plus age- wF
fage <- 1
page <- 7

#### Life history parameters ####

# length-at-age parameters-WF
laa_par <- c(Linf = 57.9, K = 0.2829, t0 = 0.13, beta1=0) #SAW 52, update t0 and beta1?
laa_typ <- 'vonB'

# weight-length parameters-WF
waa_par <- c(0.301, 0.373, 0.5799, 0.7979, 0.9801, 1.0672, 1.2618)# stock weight agrepro 
waa_typ <- 'input'

# maturity-at-age parameters- WF
mat_par <- c(0.002, 0.122, 0.9358, 1, 1, 1, 1) 
mat_typ <- 'input'

# natural mortality- WF
M  <- 0.3 #2020 assessment
M_typ <- 'const'
init_M <- 0.3
#M <- 0.6
#M_typ='ramp'


# initial numbers at-age parameters
initN_par <- c(13810, 21704,15683, 8440, 3016, 1897, 2066) #Jan-1 population- estimation results base run output
initN_type <- 'input'


#### Fishery parameters ####
# fishery and survey catchabilities *have not found reported*
qC <- 0.0001
qI <- 0.0001

DecCatch<-FALSE #If survey catchability decreases with temperature, set to TRUE. 

# fishery selectivity- WF
selC <- c(0.0171, 0.3123, 0.636, 1,1,1,1) #AGEPRO
selC_typ <- 'input'

#### Recruitment Options ####
#For BH Steepness Option## 
Rpar <- c(h = 0.78,
          R0 = 17337,
          SSBRF0 = 0.019) # calculated as S0/R0 (/17337)
R_typ <- 'BHSteep'

##For BH SR with relationship with temperature###
# R_typ <- 'BH'
# Rpar<-c(a=5.1698169,b=0.0002892,g=-1.423)


#### Survey parameters ####

## Survey information- 
#selI <- c(1)
#selI_typ <- 'const'
selI <- c(0.007512, 0.029473, 0.070987, 0.144857, 0.199013, 0.217423, 0.2248) #Spring survey fit from 2019 assessment .rep
selI_typ <- 'input'
timeI <- 0 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 42

# Expansion range for setting limits on parameter bounds
boundRgLev <- 1.5

# CV for starting values for the assessment model
startCV <- 1.5

# scalar to bring pop numbers closer to zero (necessary
# for model fitting)
caaInScalar <- 1 

# stock assessment misspecifications
M_mis<- FALSE
M_mis_val<-0.3
R_mis<- FALSE
Rpar_mis <- c(SSB_star = 6300, #the 'wrong' SRR parameters that will be used in BRP estimation and projections
              cR = 1,
              Rnyr= 20)
waa_mis<- FALSE

#### Error parameters ####

# observation error levels
oe_sumCW <- 0.2
oe_sumCW_typ <- 'lognorm'
oe_paaCN <- 80
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.2
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 100 
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.2
oe_effort_typ <- 'lognorm'

# process error levels  ###################################  
pe_R <- 0.5 # cannot be zero #0.5 for Beverton Holt
pe_RSA<- 0.5 #recruitment process error assumed in the stock assessment 
pe_IA <- 0.1 

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
