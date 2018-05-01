



set.seed(40)

## Simulation information

# number of times to repeat this analysis
nrep <- 1

# first age and plus age
fage <- 1
page <- 15
nage <- length(fage:page)

# number of years to run the simulation
nyear <- 450

# first year after the initial condition period
fyear <- 5

# number of burn-in years
nburn <- 400

# number of years in assessment model
ncaayear <- 30 


## Life history parameters ##

# length-at-age parameters
laa_par <- c(114.1, 0.22, 0.17) #SAW 55 p.667
laa_typ <- 'vonB'

# weight-length parameters
waa_par <- c(exp(-11.6913), 3.0219) #SAW 55 p.659
waa_typ <- 'aLb'

# maturity-length parameters
mat_par <- c(0.127, 38.8) # O'brien GB cod female
mat_typ <- 'logistic'



## Population information
# natural mortality
M <- 0.1


## Fishery information

# for now!
F_full <- rlnorm(nyear, log(0.2), 0.1)
temp <- rep(15, nyear)

# fishery and survey catchabilities
qC <- 0.01
qI <- 0.001

# fishery selectivity
# ### change select to L50 paramaterization like maturity
selC <- c(s0=5, s1=0.08)
selC_typ <- 'Logistic'

# Recruitment
load('data/data_processed/SR/cod/BHTS.Rdata') #srpar


## Survey information
slxI <- matrix(1, nrow=nyear, ncol=nage)
timeI <- 0.5


## Error parameters ##

# observation error levels
oe_sumCW <- 0.05
oe_sumCW_typ <- 'lognorm'
oe_paaCN <- 25
oe_paaCN_typ <- 'multinomial'
oe_sumIN <- 0.2
oe_sumIN_typ <- 'lognorm'
oe_paaIN <- 25
oe_paaIN_typ <- 'multinomial'
oe_effort <- 0.01
oe_effort_typ <- 'lognorm'

# process error levels
pe_R <- 1.5












