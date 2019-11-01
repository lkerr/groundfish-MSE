# The simulation model has "calendar years," stored in the vector yrs.  The model loops through the index position (y in fyear:nyear) of yrs.  A small data.table that contains the replicate number, year index position, calendar year, index relative to beginning of management, join_econ_yr, join_econ_idx may be useful to ensure the same "things" are being done across the different mprocs.  
# This will work as long as we're simulating years \in 2010:2015.
# the random_sim_draw table has nrep*(nyear-fyear+1) rows.

eyears<-nyear-fyear+1
random_sim_draw <-as.data.table(cbind(rep(1:nrep,each=eyears), rep(fyear:nyear,nrep))) 
colnames(random_sim_draw)<-c("econ_replicate","sim_year_idx")
random_sim_draw[, cal_year:=yrs[sim_year_idx]]
random_sim_draw[, manage_year_idx:=cal_year-fmyear+1]

#  We use the join_econ_yr, join_econ_idx, join_outputprice, join_inputpprice, join_mult columns to pull in economic data. Right now, it's identical to the calendar year and manage_year_idx, but it may be advantageous to "cross" or "randomly" cross data.   

random_sim_draw[, join_econbase_yr:= cal_year]
random_sim_draw[, join_econbase_idx:= join_econbase_yr-econ_data_start+1]
random_sim_draw[, join_outputprice_idx:= join_econbase_idx]
random_sim_draw[, join_inputprice_idx:= join_econbase_idx]
random_sim_draw[, join_mult_idx:= join_econbase_idx]

maxyc<-nrep*nrow(mproc)*(nyear-fyear+1)

#We have prepared 6 years of economic data (2010-2015), so we need to throw an error if we are out of range for any economic data that we want to import. 

if( any(random_sim_draw$join_econbase_yr <  2010| random_sim_draw$join_econbase_yr > 2015) ) stop('Economic base data not between 2010 and 2015.  Check your parameters ')

if( any(random_sim_draw$join_outputprice_idx <  1| random_sim_draw$join_outputprice_idx > 6) ) stop('Economic output price data invalid (not between 2010 and 2015).  Check your parameters ')

if( any(random_sim_draw$join_inputprice_idx <  1| random_sim_draw$join_inputprice_idx > 6) ) stop('Economic input price data invalid (not between 2010 and 2015).  Check your parameters ')

if( any(random_sim_draw$join_mult_idx <  1| random_sim_draw$join_mult_idx > 6) ) stop('Economic multiplier data invalid (not between 2010 and 2015).  Check your parameters ')
