# Read in Economic info.  
# Sector Catch, sector sub-ACL, total ACLs 

# file paths for the raw and final directories

savepath <- 'data/data_processed/econ/'

acls<-"catch_acls.csv" 

# read in the estimated coefficients from txt files
econ_setup <- read.csv(file.path(savepath,acls), sep=",", header=TRUE,stringsAsFactors=FALSE)

# For stocks that are not modeled explicitly, we want to set the "fake" catch limit for the sector vessels
# Equal to "what they have historically used. This means we either use their "levels" or fraction of the total

econ_setup$sector_total_util_frac<-econ_setup$sectorCatch/econ_setup$totalACL
econ_setup$sector_util_frac<-econ_setup$sectorCatch/econ_setup$sectorACL

econ_setup<-econ_setup[c("spstock2","totalACL","sectorACL","otherCatch","sectorCatch","otherACL","sector_total_util_frac","sector_util_frac")]



