

library(tabulizer)


## GB cod


pth <- file.path('C:/Users/struesdell',
                 'OneDrive - Gulf of Maine Research Institute/GMRI/',
                 'groundfish-MSE/background/assessment2015GBcod/partb.pdf')

out <- extract_tables(file = pth,
                      pages = 103)

yearBase <- out[[1]][,2]
year <- as.numeric(yearBase[!yearBase == ''])

FBase <- out[[1]][,4]
F <- FBase[!FBase == '']
F <- as.numeric(F[3:length(F)])

RBase <- out[[1]][,5]
RBase[31] <- out[[1]][31,1]
R <- RBase[!RBase == '']
R <- as.numeric(R[3:length(R)])

df <- data.frame(Year = year,
                 F = F,
                 R = R * 1000)

pthOut <- file.path('C:/Users/struesdell',
                    'OneDrive - Gulf of Maine Research Institute/GMRI/',
                    'groundfish-MSE/data/data_raw/AssessmentHistory/',
                    'codGB_Error.csv')

write.csv(df, file = pthOut, row.names = FALSE, quote = FALSE)
