

# Retrieves and processes the stock, recruit and
# temperature data to get a nice input file to go
# into the stock-recruit model file


# BBH temperature series
load('data/data_processed/bbhT.Rdata') # bbhT

# GB buoy temperature series
load('data/data_processed/gbT.Rdata') # gbT

# SAW55 stock-recruit
srcodGB <- read.csv('data/data_raw/SAW55SR_codGB.csv')
srcodGOM <- read.csv('data/data_raw/SAW55SR_codGOM.csv')



# alter the column names to clarify source
names(bbhT)[-1] <- paste0('bbh_', names(bbhT[-1]))
names(gbT)[-1] <- paste0('gb_', names(gbT[-1]))
names(srcodGB)[-1] <- paste0('codGB_', names(srcodGB[-1]))
names(srcodGOM)[-1] <- paste0('codGOM_', names(srcodGOM[-1]))

sr <- merge(merge(merge(bbhT, gbT, all=TRUE), 
                  srcodGB, all=TRUE), srcodGOM, all=TRUE)
sr$Year <- as.numeric(as.character(sr$Year))

save(sr, file='data/data_processed/sr.Rdata')




