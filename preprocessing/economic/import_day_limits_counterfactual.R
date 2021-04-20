#importing trip limits data and index fishing year and day of fishing year 
#includes pre-processing code to add a dl_primary to the targetting dataset 
# Adjust day limits to be the same as the prevailing day limits at the end of the 2009 fishing year.

day_limits = read.dta13("data/data_raw/econ/trip_limits_forsim.dta")

spstock2s<-c("americanlobster","americanplaiceflounder","codGB","codGOM","haddockGB","haddockGOM","monkfish", "other","pollock","redsilveroffshorehake","redfish","seascallop","skates","spinydogfish","squidmackerelbutterfishherring","summerflounder","whitehake","winterflounderGB","winterflounderGOM","witchflounder","yellowtailflounderCCGOM", "yellowtailflounderGB","yellowtailflounderSNEMA")

daylimits <-paste0("dl_",spstock2s)
#https://stackoverflow.com/questions/37376398/how-to-create-an-empty-datatable-with-columns-names-and-then-append-datatables-t
dl <- setNames(data.table(matrix(nrow = 0, ncol = length(daylimits))), c(daylimits))

#dl = data.table ()
#dl [,(daylimits):=NA]

fishing_yr <- function(dates, start_month=5) {
  # Convert dates into POSIXlt
  dates.posix = as.POSIXlt(dates)
  # Year offset
  offset = ifelse(dates.posix$mon >= start_month - 1, 0, 1)
  # fishing year
  f.year = dates.posix$year + 1900 - offset
  # Return the fishing year
  f.year
}

day_limits$gffishingyear = fishing_yr(day_limits$date)

day_limits = day_limits %>%
  group_by(gffishingyear)%>%
  mutate(doffy = ifelse(gffishingyear==2003, 306:366, 1:n()))
 
day_limits = day_limits[, !(colnames(day_limits) %in% c("date"))]
mer = names(day_limits [1:13])
day_limits = merge(day_limits, dl, by=mer, all=T)


day_limits$dl_codGB[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_codGB))]<-1000
day_limits$dl_codGOM[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_codGOM))]<-800
day_limits$dl_whitehake[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_whitehake))]<-1000
day_limits$dl_yellowtailflounderCCGOM[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_yellowtailflounderCCGOM))]<-250
day_limits$dl_yellowtailflounderSNEMA[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_yellowtailflounderSNEMA))]<-250
 
day_limits$dl_winterflounderGB[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_winterflounderGB))]<-5000
day_limits$dl_yellowtailflounderGB[which(day_limits$gffishingyear>=2010 & is.na(day_limits$dl_yellowtailflounderGB))]<-5000

# GB cod - 1000
# GOM cod 800
# white hake 1000
# yellowtail CCGOM 250
# yellowtail SNEMA 250



# creating a dl_primary variable 
primary = gather (day_limits, key = "spstock2", value="dl_primary", -c("gffishingyear", "doffy"))
primary$spstock2 = gsub("dl_", "", primary$spstock2)

day_limits = merge(primary, day_limits)
day_limits = as.data.table(day_limits)
setorderv(day_limits,c("gffishingyear","doffy","spstock2"))