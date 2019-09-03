# Read in Economic Production Data. These are relatively lists of data.tables. So it makes sense to read in once and then list-subset [[]] later on.

multipliers<-readRDS(file.path(econdatapath,multiplier_loc))
outputprices<-readRDS(file.path(econdatapath,output_price_loc))
inputprices<-readRDS(file.path(econdatapath,input_price_loc))






