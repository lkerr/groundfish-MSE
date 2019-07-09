# Read in ACL info. This constructs a dataframe that contains:
  # totalACL in metric tons, 
  # the fraction that is allocated to sectors, 
  # The fraction that is allocated to non-sector "commercial",
  # the fraction that is allocated to recreational.

# For the non-modeled stocks, we'll use these data to construct catch limits.
# For the modeled stocks, we'll use these "sector_frac" to adjust the catch advice to form the 
# sector ACL.


# file paths for the raw and final directories
sourcepath <- 'data/data_processed/econ/'
acls<-"catch_limits_2010_2017.csv" 

# read in the estimated coefficients from txt files
econ_baseline <- read.csv(file.path(sourcepath,acls), sep=",", header=TRUE,stringsAsFactors=FALSE)

#set anything na to 100,000,000 mt
econ_baseline$totalACL_mt[is.na(econ_baseline$totalACL_mt)] <- 1e8


