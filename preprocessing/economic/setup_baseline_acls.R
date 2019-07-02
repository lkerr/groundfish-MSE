# Read in Economic info.  
# Sector Catch, sector sub-ACL, total ACLs 

# file paths for the raw and final directories

savepath <- 'data/data_processed/econ/'

acls<-"catch_acls.csv" 

# read in the estimated coefficients from txt files
econ_baseline <- read.csv(file.path(savepath,acls), sep=",", header=TRUE,stringsAsFactors=FALSE)

# For stocks that are not modeled explicitly, we want to set the "fake" catch limit for the sector vessels
# Equal to "what they have historically used. This means we either use their "levels" or fraction of the total

econ_baseline$sector_total_util_frac<-econ_baseline$sectorCatch/econ_baseline$totalACL
econ_baseline$sector_util_frac<-econ_baseline$sectorCatch/econ_baseline$sectorACL

econ_baseline<-econ_baseline[c("spstock2","totalACL","sectorACL","otherCatch","sectorCatch","otherACL","sector_total_util_frac","sector_util_frac")]

####Still need to add "ACLs" for
# RedSilverOffshoreHake
# Other
# SummerFlounder
# Monkfish
# SquidMackerelButterfishHerring
# SeaScallop
# Skates
# SpinyDogfish
#####
#This needs to be run "at the beginning."
# Every year, we'll set ACLs as 'default' based on these.  
# Then we'll pull in from the stock assessments with a merge/overwrite?
# May be useful to have an inputs and outputs setup, like with the containers 
# --these are essentially OM parameters
