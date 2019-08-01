

cmip5Wide <- read.table('data/data_raw/NEUS_CMIP5_annual_means.txt', 
                        header=TRUE, skip=2)


cmip5Long <- reshape(data = cmip5Wide,
                     varying = names(cmip5Wide)[-1],
                     v.names = 'Temperature',
                     timevar = 'Model',
                     idvar = 'year',
                     times = names(cmip5Wide)[-1],
                     direction = 'long')
row.names(cmip5Long) <- NULL
                     
cmip5Long$RCP <- 8.5

write.csv(cmip5Long,
          file = 'data/data_raw/NEUS_CMIP5_annual_meansLong.csv',
          row.names = FALSE)
