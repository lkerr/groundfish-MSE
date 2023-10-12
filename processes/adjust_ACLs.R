# small bit of code to adjust the ACLs for Gom Cod to simulate a rebuilt stock 
# Assume B=BMSY of about 85000
# Assume this would have produced an ACL of ~12000mt, and a sector ACL of 7000mt. All guesses.

econ_baseline_averages[econ_baseline_averages$spstock2=="codGOM",]$mean_baselineACL_mt<-12000
econ_baseline_averages[econ_baseline_averages$spstock2=="codGOM",]$mean_sectorACL_mt<-7000
  
econ_baseline_averages[econ_baseline_averages$spstock2=="americanplaiceflounder",]$mean_baselineACL_mt<-3000
econ_baseline_averages[econ_baseline_averages$spstock2=="americanplaiceflounder",]$mean_sectorACL_mt<-3000

