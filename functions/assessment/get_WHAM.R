get_WHAM <- function(stock...){
  

    # Run the wham model
    #devtools::install_github("timjmiller/wham", dependencies=TRUE, ref="devel")
    library(wham)
    #read in saved ASAP file with wham function 
    wham_dat_file <- read_asap3_dat()
    input <- prepare_wham_input(wham_dat_file) #more settings here, testing needed
    whamEst <- fit_wham(input, do.osa=T)
    
    #save results from wham
    saveRDS(whamEst, file = paste("Assessment/WHAM/", stock,'_', t, '_', y, '.rdat', sep = ''))
    
    #pull data for wham (modified from wham github R/wham_plots_tables.R)
    std <-summary(whamEst$sdrep)
    years_full <- whamEst$years_full
    ssb.ind <- which(rownames(std) == "log_SSB")
    log.ssb <- std[ssb.ind,1]
    SSBhat = cbind(exp(log.ssb),years_full)
    
    n_ages <- whamEst$env$data$n_ages
    years_full <- whamEst$years_full
    faa.ind <- which(rownames(std)=="log_FAA_tot")
    log.faa <-matrix(std[faa.ind,1], length(years_full),n_ages)
    age.full.f <- apply(log.faa,1, function(x) max(which(x==max(x))))
    full.f.ind <- cbind(1:length(years_full), age.full.f)
    log.full.f <- log.faa[full.f.ind]
    Fhat <- cbind(exp(log.full.f), years_full)
    
    #Ref pt names pulled from: summary(mod$sdrep, "report")  
    # "log_Y_FXSPR" = log yield at F40%
    # "log_FXSPR" = log F40%
    # “log_SSB_FXSPR" = log SSB at F40%
    
    #The plot script for ref pts pulls only years 1:years_ful
    std <- summary(whamEst$sdrep, "report")
    F.t <- which(rownames(std) == "log_FXSPR")
    SSB.t <- which(rownames(std) == "log_SSB_FXSPR")
    ssb <- which(rownames(std) == "log_SSB")
    
    years_full = whamEst$years_full
    n_years_full = length(years_full)
    log.f40 <- std[F.t,1][1:n_years_full]
    F40 <-cbind(exp(log.f40), years_full)
    
    log.ssb.f40 <- std[SSB.t,1][1:n_years_full]
    SSBF40 <- cbind(exp(log.ssb.f40),years_full)
  
  #check convergence
  
  #determine stock status
  FrefScalar <- 0.75
  FThresh <- tail(F40,1)[1] * FrefScalar
  BrefScalar <- 0.5
  BThresh <- tail(Bthresh,1)[1] * BrefScalar
  
  overfished <- ifelse(tail(SSBhat,1)[1] < BThresh, 1, 0)
  
  overfishing <- ifelse(tail(Fhat,1)[1] > tail(F40,1)[1], 1, 0) 
  
  #apply HCR for advice F
  #start with constant F 
  F <- FThresh
  
  #catch projections
  
  
}