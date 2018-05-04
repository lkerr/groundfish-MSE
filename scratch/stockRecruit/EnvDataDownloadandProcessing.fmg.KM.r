############## Working with environmental data in R

##### Function to go out and grab data from the web and store it as raster
env_data_extract<- function(dat.set, dates, box, out.dir) {
  
  # Function details
  # dat.set = Env data to extract (options = ERSST, OISST, ...)
  # dates = If !NULL, subset full time series to specific dates c("YYYY-MM-DD", "YYYY-MM-DD")
  # box = If !NULL, crop rasters to sepcific box for easier post-processing, specify as xmin, xmax, ymin, ymax.
  # out.dir = Directory to store files downloaded to and results saved
  # All data from: http://oceanwatch.pfeg.noaa.gov/thredds/catalog.html
  
  # A few preliminaries
  library(tidyverse)
  library(curl)
  library(ncdf4)
  library(raster)
  library(sp)
  
  # For debugging
  if(FALSE){
    dat.set<- "ERSST"
    dates<- NULL # For ERSST need to be in YYYY-MM format. If NULL, downloads all available files
    box<- c(-77, -65, 35, 45)
    out.dir<- "~/Dropbox/Andrew/Work/GMRI/EnvData/"
  }
  
  ######################
  ##### Get the data from the web
  #####################
  #### ERSST
  if(dat.set == "ERSST") {
    # Set data path
    dat.path<- "https://www.esrl.noaa.gov/psd/thredds/fileServer/Datasets/noaa.ersst/sst.mnmean.v4.nc"
    
    # Download 
    temp.dest<- paste(out.dir, "sst.mnmean.v4.nc", sep = "")
    temp <- curl_download(dat.path, destfile = temp.dest)
    
    # Read it back in as a raster
    stack.full<- raster::rotate(raster::stack(temp.dest))
    
    # Dates split?
    if(!is.null(dates)){
      # Subset raster stack
      date.partial<- gsub("X", "", names(stack.full))
      dates.full<- as.Date(gsub("[.]", "-", date.partial))
      stack.full<- stack.full[[which(dates.full >= dates[1] & dates.full<= dates[2])]]
    }
  }
  
  #### OISST
  if(dat.set == "OISST") {
    # Stem directory for data download
    dat.stem<- "https://www.esrl.noaa.gov/psd/thredds/fileServer/Datasets/noaa.oisst.v2.highres/"
    
    # Dates split?
    if(is.null(dates)){
      # Get the full time series file extensions
      files.list<- paste("sst.day.mean.", seq(from = 1981, to = 2017, by = 1), ".v2.nc", sep = "")
    } else {
      # Get time series subset
      files.list<- paste("sst.day.mean.", seq(from = dates[1], to = dates[2], by = 1), ".v2.nc", sep = "")
    }
    
    stack.full<- stack()
    
    # Loop through, add to stack
    for(i in seq_along(files.ext)){
      
      # Full data path
      dat.path<- paste(dat.stem, files.list[i], sep = "")
      # Download 
      temp.dest<- paste(out.dir, files.list[i], sep = "")
      temp<- curl_download(dat.path, destfile = temp.dest) 
      
      # Bring in as raster and add to stack
      rast.temp<- raster::rotate(raster::stack(temp.dest))
      stack.full<- stack(stack.full, rast.temp)
    }
  }
  
  #### Ocean Chlorophyll
  if(dat.set == "MODIS"){
    
    # Data url
    dat.url<- "http://oceanwatch.pfeg.noaa.gov/thredds/dodsC/satellite/MH1/chla/mday"
    
    # Open connection, get information
    my.nc<- nc_open(dat.url)
    lon.nc<- ncvar_get(my.nc, varid = "lon")
    nlons<- dim(lon.nc)
    lat.nc<- ncvar_get(my.nc, varid = "lat")
    nlats<- dim(lat.nc)
    
    # Extract available dates from netCDF file
    ncdates<- my.nc$dim$time$vals
    ncdates<- as.Date(as.POSIXct(ncdates, origin="1970-01-01", tz = "GMT"), "GMT", "%Y-%m-%d")
    
    # Get variable data -- not working
    variable<- "chlor_a"
    var.fvcom<- ncvar_get(nc = my.nc, varid = variable, count = c(8640, 4320, 169))
    
    if(!is.null(dates)){
      # Subset dates
      
    }
    
    
  }
  
  ######################
  ##### Crop raster?
  #####################
  if(!is.null(box)){
    e<- raster::extent(box[1], box[2], box[3], box[4])
    stack.out<- raster::crop(stack.full, e)
  } else {
    stack.out<- stack.full
  }
  
  ####################
  ##### Write out raster
  ####################
  writeRaster(stack.out, filename = paste(out.dir, dat.set, ".grd", sep = ""), overwrite = TRUE)
  return(stack.out)
}




#############################################################################################################################################
#############################################################################################################################################



##### Alright, now we've got a function, lets run it and then look at a schmorgasboard of stuff that you could do with the extracted raster data
#working directory
# wd<-readLines(n=1)
# C:\Users\fmassiotgranier\Research\Andrew
# setwd(wd)
wd <- "C:/Users/struesdell/Desktop/testFun"
setwd(wd)

## Deffine the 1 area of interest & extract the mean monthly mean values
ersst.stack1<- env_data_extract(dat.set = "ERSST", 
                                dates = NULL, 
                                box = c(-75, -62, 35, 45), 
                                out.dir = wd)


nelme.mean.t<- as.vector(cellStats(ersst.stack1, stat = "mean"))
dates.t<- as.Date(gsub("[.]", "-", gsub("X", "", names(ersst.stack1))))
plot.dat1<- data.frame("Temp" = nelme.mean.t, "Date" = dates.t)
