
## Code from Andrew that digs into the raster stack so you can subset and save
## temperature values.


library(raster)
library(tidyverse)
library(sf)
library(rts)

# Preliminary stuff
# Spatial projections
proj.wgs84<- CRS("+init=epsg:4326") #WGS84
proj.utm<- CRS("+init=epsg:2960") #UTM 19

# Read in full stack
oisst.dir<- "J:/Research/Mills Lab/All/Data/" # Update path as needed
oisst.stack<- raster::stack(paste(oisst.dir, "OISST.grd", sep = "")) 

# Read in all physioregion boundary shapefile
sp.dir<- "J:/Research/Mills Lab/All/GIS/" # Update path as needed
#all.regs<- sf::st_read(dsn = 
#                        paste(sp.dir, "PhysioRegions_Maine/", sep = ""), 
#                        layer = "PhysioRegions_WGS84", crs = "+init=epsg:4326")
all.regs<- sf::st_read(dsn = 
                         paste(sp.dir, 
                               "PhysioRegions_Maine/PhysioRegions_WGS84.shp", 
                               sep = ""), crs = "+init=epsg:4326")


# Get regions of interest
unique(all.regs$Region)
# Change to edit "regions" included in GoM analysis -- note they 
# spelled "Wilkinson" incorrectly as "Wikinson"
gom.regs<- c("Eastern Coastal Shelf", "Bay of Fundy", 
             "Northern Coastal Shelf", "Southern Coastal Shelf", 
             "Wikinson Basin", "Georges Basin", "Jordan Basin", 
             "Browns Bank", "Central Gulf of Maine") 
gom<- all.regs[all.regs$Region %in% gom.regs,] %>%
  st_union() %>%
  st_sf()
gb<- all.regs[all.regs$Region == "Georges Bank",] %>%
  st_union() %>%
  st_sf()

# Check
plot(st_geometry(all.regs), col = NA, main = "GoM Physio Regions")
plot(st_geometry(gom), col = "blue", add = T)
plot(st_geometry(gb), col = "red", add = T)

# Looks good. Moving on to isolate regions of interest...
gom.stack<- raster::mask(oisst.stack, st_zm(gom))
gb.stack<- raster::mask(oisst.stack, st_zm(gb))

# From there, can move on to getting time series statistics. 
# Example: monthly means
# Preliminaries
month.conv<- data.frame("Month.Chr" = c("January", "February", "March", 
                                        "April", "May", "June", 
                                        "July", "August", "September", 
                                        "October", "November", "December"), 
                        "Month.Num" = c("01", "02", "03", "04", "05", "06", 
                                        "07", "08", "09", "10", "11", "12"))

oisst.min.date<- as.Date(gsub("[.]", "-", gsub("X", "", 
                                               min(names(oisst.stack)))))
oisst.max.date<- as.Date(gsub("[.]", "-", gsub("X", "", 
                                               max(names(oisst.stack)))))
oisst.dates<- seq.Date(from = oisst.min.date, to = oisst.max.date, by = "day")

# Convert raster stack to time series
gom.z<- rts(gom.stack, oisst.dates)
gb.z<- rts(gb.stack, oisst.dates)

# Aggregate to monthly averages
gom.z.mm<- rts::apply.monthly(gom.z, mean)@raster
gb.z.mm<- rts::apply.monthly(gb.z, mean)@raster

# Rename layers
month.dates<- seq(from = oisst.min.date, to = oisst.max.date, by = "month")
names(gom.z.mm)<- month.dates
names(gb.z.mm)<- month.dates

# Out as a data.frame
gom.df<- as.data.frame(gom.z.mm, xy = T) %>%
  gather(., "Date", "Temp", -x, -y) %>%
  separate(., Date, into = c("Year", "Month", "Day"), drop = F) %>%
  mutate(., "Year.Clean" = gsub("X", "", Year)) %>%
  dplyr::select(., x, y, Year.Clean, Month, Day, Temp)
gb.df<- as.data.frame(gb.z.mm, xy = T) %>%
  gather(., "Date", "Temp", -x, -y) %>%
  separate(., Date, into = c("Year", "Month", "Day"), drop = F) %>%
  mutate(., "Year.Clean" = gsub("X", "", Year)) %>%
  dplyr::select(., x, y, Year.Clean, Month, Day, Temp)

# Note, there will be a lot of NAs there -- can drop em easily and save that 
# if you want.





