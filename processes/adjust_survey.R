# small bit of code to adjust the log_trawl_survey_biomass for Gom Cod to simulate a rebuilt stock. 

# Assume B=BMSY of about 85000. This is about 10x higher than 2015.  
# Assume this would have produced an ACL of ~12000mt, and a sector ACL of 7000mt. All guesses.
# assume this turns into a trawl survey that is 5x higher than actual from 2015. 


ts2<-fishery_holder[fishery_holder$spstock2=="codGOM", c('spstock2','ln_trawlsurvey','ln_obs_trawlsurvey','sectorACL')]
                    
#the 2015 value of log_trawl_survey is 1.657561.  un-logged value of trawl survey is 5.2465.  
# I'm going to assume that the trawl survey goes up by a factor of 4
ts2[ts2$spstock2=="codGOM",]$ln_trawlsurvey<-1.657561+log(4)
ts2[ts2$spstock2=="codGOM",]$ln_obs_trawlsurvey<-ts2[ts2$spstock2=="codGOM",]$ln_trawlsurvey
ts<-rbind(ts,ts2)

