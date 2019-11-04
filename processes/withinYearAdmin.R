#This takes care of within-year counters and indexing. These are needed/useful for the economic model.

yearcounter<-yearcounter+1
calyear<-yrs[y]
ebd<-random_sim_draw[manage_counter,]
chunk_flag<-yearcounter %% savechunksize

econ_base_draw<-ebd[,join_econbase_yr]
econ_base_idx_draw<-ebd[,join_econbase_idx]
econ_outputprice_idx_draw<-ebd[,join_outputprice_idx]
econ_mult_idx_draw<-ebd[,join_mult_idx]
econ_inputprice_idx_draw<-ebd[,join_inputprice_idx]
