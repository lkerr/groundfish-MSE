


# Ensure that TMB will use the Rtools compiler (only windows ... and 
# not necessary on all machines)
if(platform != 'Linux'){
  path0 <- Sys.getenv('PATH')
  path1 <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                  path_current)
  Sys.setenv(PATH=path1)
}



sty <- y-ncaayear+1

# get the random walk deviations
R_dev <- get_RWdevs(get_dwindow(R, sty, y))

# get the initial population mean and deviations
ipopInfo <- get_LMdevs(J1N[sty,])
log_ipop_mean <- ipopInfo$lmean
ipop_dev <- ipopInfo$lLMdevs


tmb_dat <- list(

                  # index bounds
                  ncaayear = ncaayear,
                  nage = nage,
                  
                  # Catch
                  obs_sumCW = get_dwindow(obs_sumCW, sty, y),
                  obs_paaCN = get_dwindow(obs_paaCN, sty, y),
                
                  # Index
                  obs_sumIN = get_dwindow(obs_sumIN, sty, y),
                  obs_paaIN = get_dwindow(obs_paaIN, sty, y),
                  
                  # Fishing effort
                  obs_effort = get_dwindow(obs_effort, sty, y),
                  
                  # ESS
                  oe_paaCN = oe_paaCN,
                  oe_paaIN = oe_paaIN,
                  
                  # len/wt-at-age
                  laa = get_dwindow(laa, sty, y),
                  waa = get_dwindow(waa, sty, y),
                  
                  # Survey info
                  slxI = get_dwindow(slxI, sty, y),
                  timeI = timeI
)

# file.remove('results/caasink.txt')
# sapply(1:length(tmb_dat), function(x){
#   # cat(names(tmb_dat[[x]]), '\n', file='results/caasink.txt', append=TRUE)
#   write.table(tmb_dat[[x]], file='results/caasink.txt', append=TRUE)
# })




tmb_par <- list(log_M = log(M),
                R_dev = R_dev,
                log_ipop_mean = log_ipop_mean,
                ipop_dev = ipop_dev,
                log_qC = log(qC),
                log_qI = log(qI),
                log_selC = log(selC),
                log_oe_sumCW = log(oe_sumCW),
                log_oe_sumIN = log(oe_sumIN),
                # oe_effort = oe_effort,
                log_pe_R = log(pe_R)
)

# tmb_par will be used, although starting values may be altered for
# the model; base is for an easy comparison to the true values
# (i.e., tmb_par_base is not used later in the code)
tmb_par_base <- tmb_par

# get the lower and upper bounds
tmb_lb <- lapply(tmb_par, get_bounds, type='lower', p=1)
tmb_ub <- lapply(tmb_par, get_bounds, type='upper', p=1)




