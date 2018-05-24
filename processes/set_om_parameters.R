



# set.seed(40)

## Simulation information

# number of times to repeat this analysis
nrep <- 2

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
# F_full <- rlnorm(nyear, log(0.2), 0.1)
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



## Biological reference point and harvest control rule options

# reference point calculation types
# Fmsy proxy type
fbrpTyp <- c('YPR')
# Bmsy proxy type
bbrpTyp <- c('RSPR')

# Fmsy proxy level
fbrpLevel <- c(0.1)
# Bmsy proxy level
bbrpLevel <- c(1)

# Fmsy proxy types and levels
fbrp <- rbind(
  list('YPR', 0.1),
  list('RSPR', 1)
)
pol <- data.frame(
  FmsyT = c('YPR'  ,   'SPR'        ),
  FmsyV = c(0.1    ,     1          ),
  BmsyT = c('RSPR' ,   'dummy'      ),
  hcrT  = c('ns1'  ,  'simpleThresh')
)


FmsyT <- list('YPR', 'SPR')
FmsyV <- list(c(0.1, 0.15),
              c(0.3, 0.4))
# i1 <- lapply(1:length(a1), function(x) expand.grid(a1[[x]], a2[[x]]))

BmsyT <- list('RSPR', 'BmsySim')
BmsyV <- list(c(1, 0.8),
              c(NA, NA))
i2 <- lapply(1:length(BmsyT), function(x) expand.grid(BmsyT[[x]], BmsyV[[x]]))

# Harvest control rule types
i3 <- list('ns1', 'simpleThresh')


hrcTyp <- list('ns1', 'simpleThresh')








