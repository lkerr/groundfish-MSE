# The simulation model has "calendar years," stored in the vector yrs.  
# The model loops through the index position (y in fyear:nyear) of yrs. 
# A small data.table that contains the replicate number, year index position, calendar year, index
# relative to beginning of management, join_econ_yr, join_econ_idx is useful to ensure the same "things" 
# are being done across the different mprocs.  
# This code is pretty janky, but it only runs 1x per simulation. So there's no reason to speed it up.
 


eyears<-nyear-fyear+1
num_eyears<-econ_data_end-econ_data_start+1

random_sim_draw<-as_tibble(yrs) %>%
  rename(cal_year=value) %>%
  mutate(sim_year_idx=row_number(),
         manage_year_idx=cal_year-fmyear+1) %>%
  dplyr::filter(sim_year_idx >=fyear & sim_year_idx<=nyear)# %>%

# create an econbase_yr vector to join. Make it too long.
join_econbase_yr=rep(econ_data_start:econ_data_end, length.out=nrow(random_sim_draw)+num_eyears)


## Align so that cal_year==econ_data_start <--> join_econbase_yr==econ_data_start
# Look up how far offset things are
# This will break if the econ_data is not somewhere "within the simulation duration" 
if(econ_data_start<=2010 & econ_data_end>=2010){
offset<-random_sim_draw %>%
  dplyr::filter(cal_year==econ_data_start) %>%
  mutate(off=sim_year_idx %%num_eyears)
offset<-offset$off

#Create a longer sequence and subset
join_econbase_yr <-rep(econ_data_start:econ_data_end, length.out=nrow(random_sim_draw)+offset)
join_econbase_yr<-tail(join_econbase_yr, -1*offset)

#cbind and cleanup
random_sim_draw<-cbind(random_sim_draw, join_econbase_yr)
rm(join_econbase_yr)
} else {
  stop('Economic base data does not contain 2010. Economic data not aligned to cal_year')
}


#  We use the join_econ_yr, join_econ_idx, join_outputprice, join_inputpprice, join_mult columns to pull in economic data. Right now, it's identical to the calendar year and manage_year_idx, but it may be advantageous to "cross" or "randomly" cross data.   
#  set the index position
random_sim_draw<-random_sim_draw %>%
  mutate(join_econbase_idx=join_econbase_yr-econ_data_start+1) %>%
  mutate(join_outputprice_idx=join_econbase_idx,
         join_inputprice_idx=join_econbase_idx,
         join_mult_idx=join_econbase_idx,
         join_quarterly_price_idx=join_econbase_idx)
random_sim_draw<-as.data.table(random_sim_draw)


#maximum 'years' (this is total times through innermost loop), a counter, and a progress bar.

yearitercounter<-0
max_yiter<-nrep*nrow(mproc)*(nyear-fyear+1)


iterpb <- txtProgressBar(min = 1, max = max_yiter, style = 3)
# Am I using all of these columns?
# colnames(random_sim_draw)<-c("econrd","price_gfy","other_gfy")

rm(eyears)
rm(num_eyears)






#We have prepared 6 years of economic data (2010-2015), so we need to throw an error if we are out of range for any economic data that we want to import. 

if( any(random_sim_draw$join_econbase_yr <  2010| random_sim_draw$join_econbase_yr > 2015) ) stop('Economic base data not between 2010 and 2015.  Check your parameters ')

if( any(random_sim_draw$join_outputprice_idx <  1| random_sim_draw$join_outputprice_idx > 6) ) stop('Economic output price data invalid (not between 2010 and 2015).  Check your parameters ')

if( any(random_sim_draw$join_inputprice_idx <  1| random_sim_draw$join_inputprice_idx > 6) ) stop('Economic input price data invalid (not between 2010 and 2015).  Check your parameters ')

if( any(random_sim_draw$join_mult_idx <  1| random_sim_draw$join_mult_idx > 6) ) stop('Economic multiplier data invalid (not between 2010 and 2015).  Check your parameters ')
