#############################################
# reading in NetCDF files into R

install.packages("RNetCDF") 
library(RNetCDF) 

setwd('C:/Users/struesdell/Downloads/RNetCDF') #set working directory
# monthly time steps of SSH data gridded over the Gulf of Alaska 
SSH_historic <- 'GFDL_ESM2G_Historical_regr.nc' #reads in file
historic.nc <- open.nc(SSH_historic) # opens the file
print.nc(historic.nc) # gives general information about the file
historic_dat <- read.nc(historic.nc) # creates an R object that can be manipulated
close.nc(historic.nc) #closes the file

#latitude
lat <- historic_dat$LAT231_304
#longitude 180-250 E
lon <- historic_dat$LON361_500
# monthly steps; 1950-2005 although model begins in the 1861
time <- historic_dat$TIME1
# array of SSH historical data 
SSH_dat_hist <- historic_dat$ZOS
