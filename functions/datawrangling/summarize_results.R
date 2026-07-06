############# Summarize results for easier plotting

########### Only tested for running a single stock at a time
##### Need to generalize for multiple stocks. 
### Do this by making an insidde function that takes a stock name and mapping over the list?

##### HP starts in 131
##### Forward projection (stochastic recruitment) begins in year 174
##### First assessment simualted and stored in 174


summarize_results <- function(omvalGlobal, whamGlobal, hcr, stamp, dir){
  
  s<- names(omvalGlobal)
  years <- omvalGlobal[[s]]$YEAR
  
  # Remove the "estimated" containers becuase they have a different structure
  len <- sapply(omvalGlobal[[s]], dim) %>% sapply(length)
  om <- omvalGlobal[[s]][len==3]

  # Restructure Operating model trajectories for N, SSB, R, F_Full, 
  om.df <- reshape2::melt(om) %>% 
    mutate(across(starts_with("Var"), ~ as.numeric(gsub(".*?([0-9]+).*", "\\1", .x)))) %>%
    rename(rep = Var1, mproc = Var2, year_i = Var3, metric = L1) %>%
    pivot_wider(names_from = "metric", values_from = "value") %>%
    left_join(data.frame(year = years) %>% mutate(year_i = row_number()),
              by = "year_i") %>% relocate(year)
  
#  ggplot(data = om.df, aes(year_i, SSB, group = rep)) +
#    geom_line() +
#    xlim(131, NA) +
#    geom_vline(xintercept = 173.5, lty = 2)
  
  
  
  
  ########################################## Load and look at EM results
  
  # if there is a lag, terminal estimates are 2 years behind when the assessment is run
  # with no lag they are one year behind when the assessment is run
  terminal_lag <- if(mproc[1,'Lag']){2}else{1} #### Need to make this more robust (pull estimate year directly from wham model). Currently only works if lag is the same across all mproc rows
  
  ################### Trajectories
  ##### Function for matrics that estimate a single value in each year (e.g., SSB, F)
  ##### Converts inner lists into a dataframe
  traj.df <- function(x, y){
    val <- if(length(dim(x)) == 0){x} else{x[,1]}
    data.frame(val = val) %>% 
      mutate(year_i_assessment = as.numeric(str_replace(y, "year", "")),
             year_i_estimate = year_i_assessment + row_number() - length(val) - terminal_lag,
             .before = everything())}
  
  ##### Apply to SSB, F, R, Catch
  if(nfleet == 2){
    traj <- list(SSB = NA,
                 F = NA,
                 comF = NA,
                 recF = NA,
                 R = NA,
                 Catch = NA,
                 comCatch = NA,
                 recCatch = NA)
    
  }else{
    traj <- list(SSB = NA,
                 F = NA,
                 R = NA,
                 Catch = NA)
  }
  
  
  for(t in names(traj)){
    ls <- whamGlobal[[s]][[t]]
    reps <- 1:length(ls)
    
    for(r in reps){
      yi <- length(ls[[r]])
      names(ls[[r]]) <- paste0("year", 1:yi)
      ls[[r]] <- map2(ls[[r]], names(ls[[r]]), traj.df) %>% 
        bind_rows() %>% mutate(metric = t) %>%
        mutate(rep = r, .before = everything())
    }
    
    traj[[t]] <- bind_rows(ls)
  }
  
  em_traj <- bind_rows(traj) ### add static estimates (e.g., SSBmsy) to this
  
#  ggplot(data = em_traj, aes(year_i_estimate, val, col = year_i_assessment,
#                             group = interaction(rep, year_i_assessment))) +
#    geom_line() +
#    facet_wrap("metric", scales = "free") +
#    xlim(131, NA) +
#    geom_vline(xintercept = 173.5, lty = 2)
  
  
  ################### Metrics that estimate a single value for each assessment (e.g., SSBmsy)
  ##### Function to convert inner lists into a dataframe
  to.df <- function(nm, ls){
    ls1 <- ls[[nm]]
    reps <- 1:length(ls1)
    
    for(r in reps){
      ls1[[r]] <- data.frame(val = ls1[[r]]) %>%
        mutate(rep = r, year_i_assessment = row_number(),
               metric = nm, .before = everything())
    }
    return(bind_rows(ls1) %>% drop_na)
  }
  
  ##### Apply to appropriate metrics and combine into a single dataframe
  nms <- c("SSBMSY", "FMSY", "MSY", "checkConvergence", "MohnsRho_SSB", "MohnsRho_F")
  single_est <- map(nms, to.df, whamGlobal[[s]]) %>% bind_rows()
  
  ########## Combine traj and single estimates by assessment
  traj_wide <- pivot_wider(em_traj, names_from = "metric", values_from = "val") 
  single_wide <- pivot_wider(single_est, names_from = "metric", values_from = "val") 
  
  em <- left_join(traj_wide, single_wide, by = c("rep", "year_i_assessment")) %>%
    rowwise() %>% mutate(ssb_ratio = SSB/SSBMSY, f_ratio = F/FMSY, .before = "SSB")
  
  
  ##### add selectivies when 2 fleets are used, these are by age so need to do some adjusting
if(nfleet ==2){  sels <- c("comSelAA", "recSelAA", "IndSelAA")
  
  sellist_full <- list()
  
  for(t in sels){
    ls <- whamGlobal[[s]][[t]]
    reps <- 1:length(ls)
    
    rep_list <- list()
    for(r in reps){
      yi <- length(ls[[r]])
      names(ls[[r]]) <- paste0("year", 1:yi)
      
      sellist1 <- list()
      
      for(f in 1:yi){
        
        if(!is.null(ls[[r]][[f]]) && length(ls[[r]][[f]]) > 0){
          
          df <- data.frame(ls[[r]][f])
          df$yri <- str_split_i(colnames(df), "\\.", 1)[1]
          names(df) <- c( paste0("Age",rep(1:(dim(df)[2]-1))), "year_i_assessement")
          sellist1[[f]] <- df
        }
        
        }
      stacked_df <- do.call(rbind, sellist1)
      stacked_df$rep <- paste0("rep",r)
      
      rep_list[[r]] <- stacked_df 
    }
    final_stacked_df <- do.call(rbind, rep_list)
    final_stacked_df$sel_typ <- t
    
    sellist_full[[t]] <- final_stacked_df 
    
  }
  
  full_sel <- do.call(rbind, sellist_full)
}
  
  
  ################################# Risk Policy
  
  hcr1 <- hcr$hcr
  reps <- 1:length(hcr)
  
#  combine <- function(r, ls){bind_rows(ls[[r]]) %>% mutate(rep = r, .before = everything())}
  combine <- function(r, ls){bind_rows(ls[[r]])}
  
  hcr.df <- map(reps, combine, hcr) %>% bind_rows()
  
  ## Need to add this. Currently just saving the hcr list as it is stored
  
  ################################ Save restructured results
  if(nfleet ==2){  
    saveRDS(list(om = mutate(om.df, date_stamp = stamp, .before = everything()),
                                em = mutate(em, date_stamp = stamp, .before = everything()), 
                                hcr = mutate(hcr.df, date_stamp = stamp, .before = everything()),
                 sel = mutate(full_sel, date_stamp = stamp, .before = everything())), 
                           file = paste0(dir, "res_for_plots.rds"))}
  else{
  saveRDS(list(om = mutate(om.df, date_stamp = stamp, .before = everything()),
               em = mutate(em, date_stamp = stamp, .before = everything()), 
               hcr = mutate(hcr.df, date_stamp = stamp, .before = everything())), 
          file = paste0(dir, "res_for_plots.rds"))
  }

}

