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
acls<-"annual_sector_catch_limits.csv"

non_sector_data<-"catch_limits_2010_2017.csv" 

# Read in fraction of ACL that goes to the non-sector and rec fisheries
# read in the non-sector info from from csv files
non_sector_econ_baseline <- read.csv(file.path(sourcepath,non_sector_data), sep=",", header=TRUE,stringsAsFactors=FALSE)

#Just keep the spstock2,nonsector_nonrec_fraction,rec_fraction,	sector_frac
ns_keep=c("spstock2","nonsector_nonrec_fraction","rec_fraction","sector_frac")
non_sector_econ_baseline<-non_sector_econ_baseline[, ns_keep]




# read in the estimated coefficients from txt files
econ_baseline <- read.csv(file.path(sourcepath,acls), sep=",", header=TRUE,stringsAsFactors=FALSE)

#set anything na to 1,000,000 mt
econ_baseline$totalACL_mt[is.na(econ_baseline$totalACL_mt)] <- 1e6
econ_baseline$sectorACL_mt[is.na(econ_baseline$sectorACL_mt)] <- 1e6

#econ_baseline$totalACL_mt<- econ_baseline$totalACL_mt*1000

colnames(econ_baseline)[colnames(econ_baseline) == 'totalACL_mt'] <- 'baselineACL_mt'

econ_baseline$spstock2<-tolower(econ_baseline$spstock2)

econ_baseline$spstock2<- gsub("gb","GB",econ_baseline$spstock2)
econ_baseline$spstock2<- gsub("ccgom","CCGOM",econ_baseline$spstock2)
econ_baseline$spstock2<- gsub("gom","GOM",econ_baseline$spstock2)
econ_baseline$spstock2<- gsub("snema","SNEMA",econ_baseline$spstock2)


econ_baseline<-as.data.table(econ_baseline)
setorder(econ_baseline,spstock2)

# Take the average of the total_ACL_mt, sectorACL_mt by(spstock2) across the 2010-2017 time period
econ_baseline_averages <- econ_baseline %>%
  group_by(spstock2) %>%
  summarize(mean_baselineACL_mt = mean(baselineACL_mt),
            mean_sectorACL_mt = mean(sectorACL_mt),
            mults_allocated = max(mults_allocated),
            mults_nonalloc = max(mults_nonalloc),
            stockarea = max(stockarea),
            ) 

# Bring in the columns from non_sector
econ_baseline <- left_join(econ_baseline, non_sector_econ_baseline, by="spstock2")
econ_baseline_averages <- left_join(econ_baseline_averages, non_sector_econ_baseline, by="spstock2")




#econ_baseline has: 
  # spstock2, gffishingyear, baselineACL_mt, sectorACL_mt, 
  # mults_allocated, mults_nonalloc, non_mult, stockarea
  # nonsector_rec_fraction, rec_fraction, sector_frac columns