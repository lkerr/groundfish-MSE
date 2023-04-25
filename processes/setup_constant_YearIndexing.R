# This forces the economic year to be constant. 
 


eyears<-nyear-fyear+1
num_eyears<-econ_data_end-econ_data_start+1

random_sim_draw<-as_tibble(yrs) %>%
  rename(cal_year=value) %>%
  mutate(sim_year_idx=row_number(),
         manage_year_idx=cal_year-fmyear+1) %>%
  dplyr::filter(sim_year_idx >=fyear & sim_year_idx<=nyear)# %>%


#Expand to the same number of rows as we have years*nrep. Arrange.
random_sim_draw<-random_sim_draw %>%
  slice(rep(1:n(), each=nrep)) %>%
  group_by(cal_year,sim_year_idx,manage_year_idx) %>%
  mutate(replicate=row_number()) %>%
  ungroup() %>%
  relocate(replicate) %>%
  arrange(replicate, cal_year)

# randomly create an econbase_yr vector to join. Make it too long.
join_econbase_yr=matrix(constant_econ_year, nrow=nrow(random_sim_draw), ncol=1)
  
  
random_sim_draw<-cbind(random_sim_draw, constant_econ_year)


names(random_sim_draw)[length(names(random_sim_draw))]<-"join_econbase_yr" 


#  We use the join_econ_yr, join_econ_idx, join_outputprice, join_inputpprice, join_mult columns to pull in economic data. Right now, it's identical to the calendar year and manage_year_idx, but it may be advantageous to "cross" or "randomly" cross data.   
#  set the index position
random_sim_draw<-random_sim_draw %>%
  mutate(join_econbase_idx=join_econbase_yr-econ_data_start+1) %>%
  mutate(join_outputprice_idx=join_econbase_idx,
         join_inputprice_idx=join_econbase_idx,
         join_mult_idx=join_econbase_idx,
         join_quarterly_price_idx=join_econbase_idx)
random_sim_draw<-as.data.table(random_sim_draw)
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
