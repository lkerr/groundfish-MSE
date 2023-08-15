# SDM-MSE specific simulation settings

# NOTE: This chunk of code will pull the fmyearIdx and ncaayear from the most recently loaded stock so it will only work for a single stock at a time (otherwise SDManom and ncaayear years may not match assessment years which could cause problems)
# NOTE: Currently assumes only a spring survey index

# Source project specific functions
source('SDM_MSE/sdm_q.R')

# Load SDManom data used to adjust catchability
SDManom <- sdm_q(METRIC = "COG", SEASON = "Spring", SCENARIO = "SSP5_85", YEAR_RANGE = (fmyear - stock[[1]]$ncaayear-1):mxyear)
  # fmyearIdx and ncaayear from stock parameter file
  # mxyear in set_om_parameters_global.R file



