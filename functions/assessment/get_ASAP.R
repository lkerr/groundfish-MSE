##################################################################################
### function to modify ASAP .dat file, run executable, and produce results object
###



get_ASAP <- function(stock){

  out <- within(stock, {

      
# read in assessment .dat file and modify accordingly
    dat_file <- ReadASAP3DatFile(paste('assessment/ASAP/', stockName, ".dat", sep = ''))


### modify for each simulation/year

    #start year; (adding years with changepoint adjustment for codGOM)
    #dat_file$dat$year1 <- fmyearIdx - ncaayear
    #styear <- fmyearIdx - ncaayear
    
    #Change start years below to use moving window
    dat_file$dat$year1 <- y - ncaayear
    styear <- y - ncaayear
    
    #end year 
    endyear <- y-1
    
    #number of years in assessment
    N_rows <- length(styear:endyear)
    dat_file$dat$n_years <- N_rows
    
    #natural mortality
    dat_file$dat$M <- matrix(get_dwindow(natM, styear, endyear), nrow = N_rows, ncol = page)
    
    
    #maturity-at-age
    dat_file$dat$maturity <- matrix(get_dwindow(mat, styear, endyear), nrow = N_rows)
    
    #WAA matrix
    dat_file$dat$WAA_mats <-matrix(get_dwindow(waa, styear, endyear), nrow = N_rows)
    
    #selectivity block (single block setup)
    dat_file$dat$sel_block_assign <- matrix(1, nrow = N_rows, 1)

    #catch-at-age proportions and sum catch weight
    dat_file$dat$CAA_mats <- cbind(get_dwindow(obs_paaCN, styear, endyear), get_dwindow(obs_sumCW, styear, endyear))
    
    # discards - need additional rows even if not using
    dat_file$dat$DAA_mats <- matrix(0, nrow = N_rows, ncol = page + 1)
    
    # release - also need additional rows if not using
    dat_file$dat$prop_rel_mats <- matrix(0, nrow = N_rows, ncol = page)
    
    # #index data; sum index value, observation error, proportions-at-age, sample size
    dat_file$dat$IAA_mats <- cbind(seq(styear,endyear), get_dwindow(obs_sumIN, styear, endyear), rep(0.5, N_rows), get_dwindow(obs_paaIN, styear, endyear), rep(oe_paaIN, N_rows)) #year, value, CV, by-age, sample size
    
    # Recruitment CV
    dat_file$dat$recruit_cv <- matrix(0.5, nrow = N_rows, 1)
    
    #catch CV
     dat_file$dat$catch_cv <- matrix(0.05, nrow = N_rows, 1)
     
    #discard CV - need additional years even if not using
     dat_file$dat$discard_cv <- matrix(0, nrow = N_rows, 1)
     
    #catch effective sample size
     dat_file$dat$catch_Neff <- matrix(oe_paaCN, nrow = N_rows, 1)
     
     #discard ESS (even if not using)
     dat_file$dat$discard_Neff <- matrix(0, nrow = N_rows, 1)
     
    #end year
     dat_file$dat$nfinalyear <- y
     dat_file$dat$proj_ini <- c((y), -1, 3, -99, 1)
    # 
     dat_file$dat$R_avg_start <- styear
     dat_file$dat$R_avg_end <- endyear - 10
    # 
    # 
     
     if (Sys.info()['sysname'] == "Windows") {
       
    # save copy of .dat file by stock name, nrep, and sim year
    WriteASAP3DatFile(fname = paste('assessment/ASAP/', stockName, '_', r, '_', y,'.dat', sep = ''),
                      dat.object = dat_file,
                      header.text = paste(stockName, 'Simulation', r, 'Year', y, sep = '_'))
    
    # write .dat file needs to have same name as exe file
    WriteASAP3DatFile(fname = paste('assessment/ASAP/ASAP3.dat', sep = ''),
                      dat.object = dat_file,
                      header.text = paste(stockName, 'Simulation', r, 'Year', y, sep = '_'))

    
    # Run the ASAP assessment model
    asapEst <- try(system('assessment/ASAP/ASAP3.exe', show.output.on.console = FALSE))
    
    # Read in results
    res <- dget('assessment/ASAP/ASAP3.rdat')
    
    # save .Rdata results from each run
    saveRDS(res, file = paste('assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))
    
    # save .par file
    #file.copy("asap3.par", paste('assessment/ASAP/', stockName, '_', r, '_', y,'.par', sep = ""), overwrite = TRUE)
    
    }
    
    
    
    if (Sys.info()['sysname'] == "Linux") { 
      
      # save copy of .dat file by stock name, nrep, and sim year
      WriteASAP3DatFile(fname = paste(rundir, '/', stockName, '_', r, '_', y,'.dat', sep = ''),
                         dat.object = dat_file,
                         header.text = paste(stockName, 'Simulation', r, 'Year', y, sep = '_'))
      
      # write .dat file needs to have same name as exe file
      WriteASAP3DatFile(fname = paste(rundir, '/ASAP3.dat', sep = ''),
                        dat.object = dat_file,
                        header.text = paste(stockName, 'Simulation', r, 'Year', y, sep = '_'))
      
    tempwd <- getwd() 
    setwd(rundir)
    system("singularity exec $WINEIMG wine ASAP3.EXE", wait = TRUE)

    while (!file.exists('asap3.rdat')) {
      Sys.sleep(1)
    }
    
    # Read in results
    res <- dget('asap3.rdat')
    
    asapEst <- try(res)
    
    # save .Rdata results from each run
    saveRDS(res, file = paste(rundir, '/', stockName, '_', r, '_', y,'.rdat', sep = ''))
    #save .par file
    #file.copy("asap3.par", paste(rundir, '/', stockName, '_', r, '_', y,'.par', sep = ""), overwrite = TRUE)
    
    setwd(tempwd)
    
    }

    

  })

  return(out)

}







### scratch code to create new ASAP .dat file 
    # #start year of moving window
    # styear <- y - ncaayear
    # #end year moving window
    # endyear <- y - 1
    # #number of fleets
    # nfleet <- 1
    # #number of indices
    # nI <- 1 # keep as 1 for now
    # #maturity ogive
    # mat <- c(0.09, 0.32, 0.70, 0.92, 0.98, 1.00, 1.00, 1.00, 1.00)
    # # weight-at-age is constant from OM; assessment has time-varying (fishery and commercial)
    # waa <- c(0.0000205400, 0.0001949514, 0.0006397598, 0.0013986774, 0.0024653603, 0.0038040098, 0.0053642530, 0.0070910365,
    #          0.0089307624) *1000
    # # weight-at-age pointer
    # waa_pt <- c(1,1,1,1,2,2)
    # #selectivity block assignment - 1 block for now
    # sel_sq <- rep(1, ncaayear)
    # #selectivity Block data (1)
    # sel_blk_1 <- matrix (data =
    #                      #selectivity by age pars
    #                   #initial guess, phase, lambda, CV
    #                 c(0.1, 1, 0, 1,
    #                   0.3, 1, 0, 1,
    #                   0.5, 1, 0, 1,
    #                   0.8, 1, 0, 1,
    #                   1, -1, 0, 1,
    #                   1, 2, 0, 1,
    #                   0.9, 2, 0, 1,
    #                   0.8, 2, 0, 1,
    #                   0.8, 2, 0, 1,
    #                       #single logistic pars
    #                   3, 3, 0, 1,
    #                   0.5, 3, 0, 1,
    #                       #double logistic pars
    #                   0, 0, 0, 0,
    #                   0, 0, 0, 0,
    #                   0, 0, 0, 0,
    #                   0, 0, 0, 0), nrow = 15, ncol = 4, byrow = TRUE)
    #
    # #index selectivity (need matrix for each index)
    # ind_sel_blk <- matrix(data =
    #                         #by-age
    #                 c(0.05, 1, 0, 1,
    #                   0.2, 1, 0, 1,
    #                   0.4, 1, 0, 1,
    #                   0.79, 1, 0, 1,
    #                   0.9, 1, 0, 1,
    #                   1, -2, 0, 1,
    #                   1, -2, 0, 1,
    #                   1, -2, 0, 1,
    #                   1, -2, 0, 1,
    #                         #single logistic
    #                   1.5, 1, 0, 1,
    #                   1, 2, 0, 1,
    #                         #double logistic
    #                   0, 0, 0, 0,
    #                   0, 0, 0, 0,
    #                   0, 0, 0, 0,
    #                   0, 0, 0, 0), nrow = 15, ncol = 4, byrow = TRUE)
    #
    # Icv <- 0.45 #AEW find CV for index sumIN
    # #initial numbers
    # initN <- c(15000, 17000, 6000, 3500, 2000, 200, 300, 150, 100)
    #
    #
    # dat <- list(
    #   n_year <- ncaayear,
    #   year1 <- styear,
    #   n_ages <- page,
    #   n_fleets <- nfleet,
    #   n_fleet_sel_blocks <- 1, #keep for now
    #   n_indices <- nI,
    #   M <- matrix(M, nrow = ncaayear, ncol = page),
    #   fec_opt <- 0,
    #   frac_yr_spawn <- 0.25,
    #   maturity <- matrix(mat, nrow = ncaayear, ncol = page, byrow = TRUE),
    #   n_WAA_mats <- 1, #assessment has 2
    #   WAA_mats <- matrix(waa, nrow = ncaayear, ncol = page, byrow = TRUE), #needs to be updated
    #   WAA_pointers <- waa_pt,
    #   sel_block_assign <- sel_sq,
    #   sel_block_option <- 2, #logistic, by block (1 for now)
    #   sel_ini <- sel_blk_1,
    #   fleet_sel_start_age <- 1,
    #   fleet_sel_end_age <- page,
    #   Frep_ages <- c(page-1, page-1),
    #   Frep_type <- 1,
    #   use_like_const <- 0,
    #   release_mort <- 1,
    #   CAA_mats <- cbind(get_dwindow(obs_paaCN, styear, endyear), get_dwindow(obs_sumCW, styear, endyear)), #AEW catch-at-age and then sum column
    #   DAA_mats <- matrix(0, nrow = ncaayear, ncol = page + 1),
    #   prop_rel_mats <- matrix(0, nrow = ncaayear, ncol = page + 1),
    #   index_units <- rep(2, nI),         # 1 biomass, 2 numbers
    #   index_acomp_units <- rep(2, nI),   # 1 biomass, 2 numbers
    #   index_WAA_pointers <- rep(1, nI), #which WAA matrix to use
    #   index_month <- c(1), #AEW check
    #   index_sel_choice <- rep(-1, nI),
    #   index_sel_option <- rep(1, nI), # by age(1) or logistic (2)?
    #   index_sel_start_age <- rep(1, nI),
    #   index_sel_end_age <- rep(page, nI),
    #   use_index_acomp <- rep(1, nI),
    #   use_index <- rep(1, nI),
    #   index_sel_ini <- ind_sel_blk,
    #   IAA_mats <- cbind(seq(styear,endyear), get_dwindow(obs_sumIN, styear, endyear), get_dwindow(obs_paaIN, styear, endyear), oe_paaIN), #year, value, CV, by-age, sample size
    #   phase_F1 <- 1,
    #   phase_F_devs <- 3,
    #   phase_rec_devs <- 2,
    #   phase_N1_devs <- 1,
    #   phase_q <- 1,
    #   phase_q_devs <- -3,
    #   phase_SR_scalar <- 2,
    #   phase_steepness <- -3,
    #   recruit_cv <- rep(pe_R, ncaayear),
    #   lambda_index <- rep(1, nI),
    #   lambda_catch <- rep(1, nfleet),
    #   lambda_discard <- rep(0, nfleet),
    #   catch_cv <- matrix(oe_sumCW, nrow = ncaayear, ncol = nfleet),
    #   discard_cv <- matrix(0, nrow = ncaayear, ncol = nfleet),
    #   catch_Neff <- matrix(oe_paaCN, nrow = ncaayear, ncol = nfleet),
    #   discard_Neff <- matrix(0, nrow = ncaayear, ncol = nfleet),
    #   lambda_F1 <- rep(0, nfleet),
    #   cv_F1 <- rep(1, nfleet),
    #   lambda_F_devs <- rep(0, nfleet),
    #   cv_F_devs <- rep(1, nfleet),
    #   lambda_N1_devs <- 0,
    #   cv_N1_devs <- 1,
    #   lambda_rec_devs <- 0.2,
    #   lambda_q <- rep(0, nI),
    #   cv_q <- rep(1, nI),
    #   lambda_q_devs <- rep(0, nI),
    #   cv_q_devs <- rep(1, nI),
    #   lambda_steepness <- 0,
    #   cv_steepness <- 1,
    #   lambda_SR_scalar <- 0,
    #   cv_SR_scalar <- 1,
    #   N1_flag <- 1,
    #   N1_ini <- initN,
    #   F1_ini <- 0.05,
    #   q_ini <- 0.3,
    #   SR_scalar_type <- 0,
    #   SR_scalar_ini <- 200000,
    #   steepness_ini <- 1,
    #   Fmax <- 3,
    #   ignore_guesses <- 0,
    #   do_proj <- 0,
    #   dir_fleet <- 1,
    #   nfinalyear <- styear + ncaayear + 1,
    #   proj_ini <- c((styear + ncaayear + 1), -1, 3, -99),
    #   doMCMC <- 0,
    #   MCMC_nyear_opt <- 1,
    #   MCMC_nboot <- 10000,
    #   MCMC_nthin <- 10,
    #   MCMC_nseed <- 548623,
    #   fill_R_opt <- 2,
    #   R_avg_start <- styear,
    #   R_avg_end = styear + 26,
    #   make_R_file = 1,
    #   testval = -23456
    # )
    #
    #
    #
    # #comments
    # comm <- c(
    # "# Number of Years",
    # "# First Year",
    # "# Number of Ages",
    # "# Number of Fleets",
    # "# Number of Sensitivity Blocks",
    # "# Number of Available Survey Indices",
    # "# Natural Mortality",
    # "# Fecundity Option" ,
    # "# Fraction of year that elapses prior to SSB calculation (0=Jan-1)",
    # "# Maturity",
    # "# Number of Weights at Age Matrices",
    # "# Weight Matrix - 1 <tag-waa>",
    # "# Weights at Age Pointers",
    # "# Fleet 1 Selectivity Block Assignment <tag-selBlock>",
    # "# Selectivity Options for each block 1=by age, 2=logisitic, 3=double logistic",
    # "# Selectivity Block #1 Data <tag-selBlockDat>",
    # "# Fleet Start Age",
    # "# Fleet End Age",
    # "# Age Range for Average F",
    # "# Average F report option (1=unweighted, 2=Nweighted, 3=Bweighted)",
    # "# Use Likelihood constants? (1=yes)",
    # "# Release Mortality by Fleet",
    # "# Fleet-1 Catch Data <tag-catchData>",
    # "# Fleet-1 Discards Data <tag-discardsData>",
    # "# Fleet-1 Release Data <tag-releaseData>",
    # "# Aggregate Index Units",
    # "# Age Proportion Index Units",
    # "# Weight at Age Matrix",
    # "# Index Month",
    # "# Index Selectivity Link to Fleet",
    # "# Index Selectivity Options 1=by age, 2=logisitic, 3=double logistic",
    # "# Index Start Age",
    # "# Index End Age",
    # "# Estimate Proportion (Yes=1)",
    # "# Use Index (Yes=1)",
    # "# Index-1 Selectivity Data <tag-indexSelData>",
    # "# Index-1 Data <tag-indexData>",
    # "# Phase for F mult in 1st Year",
    # "# Phase for F mult Deviations",
    # "# Phase for Recruitment Deviations",
    # "# Phase for N in 1st Year",
    # "# Phase for Catchability in 1st Year",
    # "# Phase for Catchability Deviations",
    # "# Phase for Stock Recruitment Relationship",
    # "# Phase for Steepness",
    # "# Recruitment CV by Year",
    # "# Lambdas by Index",
    # "# Lambda for Total Catch in Weight by Fleet",
    # "# Lambda for Total Discards at Age by Fleet",
    # "# Catch Total CV by Year and Fleet",
    # "# Discard Total CV by Year and Fleet",
    # "# Catch Effective Sample Size by Year and Fleet",
    # "# Discard Effective Sample Size by Year and Fleet",
    # "# Lambda for F Mult in First year by Fleet",
    # "# CV for F Mult in First year by Fleet",
    # "# Lambda for F Mult Deviations by Fleet",
    # "# CV for F Mult Deviations by Fleet",
    # "# Lambda for N in 1st Year Deviations",
    # "# CV for N in 1st Year Deviations",
    # "# Lambda for Recruitment Deviations",
    # "# Lambda for Catchability in First year by Index",
    # "# CV for Catchability in First year by Index",
    # "# Lambda for Catchability Deviations by Index",
    # "# CV for Catchability Deviations by Index",
    # "# Lambda for Deviation from Initial Steepness",
    # "# CV for Deviation from Initial Steepness",
    # "# Lambda for Deviation from Unexploited Stock Size",
    # "# CV for Deviation from Unexploited Stock Size",
    # "# NAA Deviations Flag",
    # "# Initial Numbers at Age in 1st Year",
    # "# Initial F Mult in 1st Year by Fleet",
    # "# Initial Catchabilty by Index",
    # "# Stock Recruitment Flag",
    # "# Initial Unexploited Stock",
    # "# Initial Steepness",
    # "# Maximum F",
    # "# Ignore Guesses (Yes=1)",
    # "# Do Projections (Yes=1)",
    # "# Fleet Directed Flag",
    # "# Final Year in Projection",
    # "# Projection Data by Year",
    # "# Do MCMC (Yes=1)",
    # "# MCMC Year Option",
    # "# MCMC Iterations",
    # "# MCMC Thinning Factor",
    # "# MCMC Random Seed",
    # "# Agepro R Option",
    # "# Agepro R Option Start Year",
    # "# Agepro R Option End Year",
    # "# Export R Flag",
    # "# Test Value",
    # "#")
    #
    #
    #
    # # Create a .dat file object
    # datFileObj <- list(dat = dat,
    #                    comments = comm,
    #                    fleet.names = c('Fleet1'),
    #                    survey.names = c('Index1'))
    #
    # Write out the .dat file
    # WriteASAP3DatFile(fname = 'assessment/ASAP/ASAP.dat',
    #                   dat.object = datFileObj,
    #                   header.text = 'GOM Cod sim')
