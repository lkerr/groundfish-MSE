# Average and sd F before the management period begins. Mean on real scale
# but distribution is lognormal. SD is lognormal SD.                                              
burnFmsyScalar <- 0.001
burnFsd <- 0.001

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
 waa_par <- c(0.04845265, 0.12533195, 0.23074473, 0.35297167, 0.48134230, 0.60778080, 0.72692352, 0.83567592, 0.93263337, 1.01754813, 1.09090322,
              1.15359889, 1.20673547, 1.25147118, 1.28893435, 1.32017373, 1.34613396, 1.36764744, 1.38543585, 1.40011744, 1.41221689, 1.42217633) #Modeled from data
 waa_typ <- 'input'
waa_mis<-FALSE

# maturity-length parameters
#mat_par <- c(0.171, 32.1) # O'brien GOM cod female
#mat_typ <- 'logistic'
mat_par <- c(0.02741665, 0.05805145, 0.11901313, 0.22911408, 0.39659936, 0.59373549 ,
             0.76519328, 0.87895670, 0.94164284, 0.97278050, 0.98748479, 0.99427511,
             1, 1, 1, 1, 1, 1, 1, 1, 1, 1) 
mat_typ <- 'input'

# natural mortality
M  <- 0.154
M_typ <- 'const'
init_M <- 0.154 #same for M = 0.2 and M-ramp scenarios
# M <- 0.4
#M_typ <- 'ramp'
M_mis<-FALSE #If there is a M misspecification, set to TRUE
M_mis_val<-0.154 #The misspecified M value
MRE<-FALSE
FixMRE<-FALSE

# initial numbers at-age parameters
#initN_par <- c(15000, 17000, 6000, 3500, 2000, 200, 300, 150, 100)
#initN_type <- 'input'
initN_par <- c(nage = page, N0 = 10301040, F_full = 0, M = 0.154)
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
selC <- c(4.634206e-08, 8.296989e-08, 2.207619e-07, 2.033618e-04,5.634182e-02, 6.569636e-01, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) #Average of female and male fishery selectivities from stock assessment
selC_typ <- 'input'

#### Recruitment Options ####
##For BH Steepness Option##
 Rpar <- c(a = 0.785,
           b = 0.0000596,
           g = 0) # calculated as S0/R0 (81202.9/4456870) (arbitrary because h = 1)
 R_typ <- 'BH'
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
Rpar_mis <- c(a = 0.785,
              b = 0.0000596,
           g = 0,
          Rinc='FALSE')
h<-0.6
RER<-TRUE
# Rpar_mis<-c(a=5.1479515,b=0.0002547,g=0)

#### Survey parameters ####

## Survey information
#selI <- c(1)
#selI_typ <- 'const'

selI <- c(0.009265183, 0.042394141, 0.148155827, 0.387229989, 0.706563698, 0.869181081, 0.946835011, 0.991949298, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 1) #Average of estimated index selectivities
selI_typ <- 'input'
timeI <- 0.5 # when is the survey (as a proportion of the year)

#### Stock assessment model parameters ####

# number of years in assessment model
ncaayear <- 87

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
oe_paaCN <- 200 #base is 400
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.2
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 300 #base is 600
oe_paaIN_typ <- 'multinomial'
gapinage<-FALSE
norecentage<-FALSE

# process error levels  #####o##############################  !!!!!!!!!!!!!!
pe_R <- 0.636 # cannot be zero #0.5 for Beverton Holt
pe_RSA<- 0.636 #recruitment process error assumed in the stock assessment 
pe_IA <- 0.2 #mean of index CV from assessment

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



