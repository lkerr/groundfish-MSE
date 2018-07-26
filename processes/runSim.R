
setwd('C:/Users/struesdell/OneDrive - Gulf of Maine Research Institute/GMRI/COCA/')


# empty the environment
rm(list=ls())
set.seed(2)

# load all the functions
ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


# prepare directories
#prepFiles()


# load the required libraries
source('processes/loadLibs.R')

# load the list of management procedures
source('processes/generateMP.R')

# get the operating model parameters
source('processes/set_om_parameters.R')


# get all the necessary containers for the simulation
source('processes/get_containers.R')

# Load specific recruitment functions for simulation-based approach
# to Bproxy reference points
source('processes/Rfun_BmsySim.R')

# Load in the baseline projected temperature data to use
cmip_base <- cmip5[,c('year', cmip5model)]
names(cmip_base) <- c('YEAR', 'T')

# Load in the GB temperature data for downscaling
load('data/data_raw/mqt_oisst.Rdata')
gbT <- mqt_oisst[,c('Year', 'q1')]
names(gbT) <- c('YEAR', 'T')

# Downscale from NELME to GB
cmip_dwn <- get_temperatureProj(prj_data = cmip_base, 
                                obs_data = gbT, 
                                ref_yrs = c(1982, 2018))
# cmip_dwn <- head(cmip_dwn, 100)
# Get the temperature vector
msyears <- cmip_dwn$YEAR < 2000
temp <- c(rep(median(cmip_dwn[msyears,'T']), nburn), 
          cmip_dwn$T)


# Remove any files in the results directories
unlink('results/*', recursive=TRUE)
# create a results & sim directories
dir.create('results', showWarnings = FALSE)
dir.create('results/sim')
dir.create('results/fig')

# if on windows (i.e., not hpcc) must compile the tmb code
if(platform == 'Windows'){
  source('processes/runPre.R')
}

# Set up a sink for debugging
if(debugSink){
  dbf <- 'results/debugInfo.txt'
  cat('############  Debug results:  ############\n',
      file=dbf, sep='')
}


# begin the model loop
for(r in 1:nrep){

  if(debugSink){
    cat('r = ', r, '\n', file=dbf, append=TRUE)
  }
  
  # Use the same random numbers for each of the management strategies
  # set.seed(NULL)
  # rsd <- rnorm()
  
  for(m in 1:nrow(mproc)){
    
    if(debugSink){
      cat('  m =', m, '\n', file=dbf, append=TRUE)
    }
    
    # set.seed(rsd)
    
    # First few years of fishery information
    F_full[1:(ncaayear + fyear + nburn +1)] <- rlnorm(ncaayear + 
                                                      fyear + nburn + 1, 
                                                      log(0.2), 0.1)
  
    # initialize the model with numbers and mortality rates
    # in the first n (fyear-1) years.
    
    
    initN <- get_init(nage=nage, N0=2e7, F_full=F_full[1], M=M)
    J1N[1:(fyear-1),] <- rep(initN, each=(fyear-1))
    laa[1:(fyear-1),] <- rep(get_lengthAtAge(type='vonB', par=laa_par, 
                                         ages=fage:page),
                             each=(fyear-1))
    waa[1:(fyear-1),] <- get_weightAtAge(type='aLb', par=waa_par, 
                                         laa=laa[1:(fyear-1),],
                                         inputUnit='kg')
    Z[1:(fyear-1),] <- rep(F_full[1]+M, each=(fyear-1))
  
  
  
    for(y in fyear:nyear){

      if(debugSink){
        cat('    y =', y, '\n', file=dbf, append=TRUE)
      }
      
      # calculate length-at-age in year y
      laa[y,] <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                                 ages=fage:page)
      # other option here is get_size which tries to take temperature
      # into account. Needs some work there though.
      
      # calculate weight-at-age in year y
      waa[y,] <- get_weightAtAge(type=waa_typ, par=waa_par, 
                                 laa=laa[y,], inputUnit='kg')
      
      # calculate maturity in year y
      mat[y,] <- get_maturity(type=mat_typ, par=mat_par, laa=laa[y,])
      
      # calculate recruits in year y based on the SSB in years previous
      # (depending on the lag) and temperature
      SSB[y] <- sum(J1N[y-fage,] * mat[y,] * waa[y-fage,])  

      Rpar <- get_recruitment_par(par=srpar, stochastic=FALSE)
      Rout <- get_recruits(type=Rpar$type, par=Rpar, S=SSB[y],
                           tempY=temp[y])

      R[y] <- Rout['R']
      residR[y] <- Rout['resid']
      R[y] <- ifelse(R[y] < 0, 0, R[y])
      
      # calculate the selectivity in year y (changes if the laa changes)
      slxC[y,] <- get_slx(type=selC_typ, par=selC, laa=laa[y,])
      
      # get Z for the current year
      Z[y,] <- F_full[y]*slxC[y,] + M
      
      # calculate what the Jan 1 population numbers are for year y, which
      # depend on the numbers and mortality rate in the previous year and
      # on the recruitment this year
      J1N[y,] <- get_J1Ny(J1Ny0=J1N[y-1,], Zy0=Z[y-1,], R[y])
    
      # calculate the predicted catch in year y, the catch weight and the
      # proportions of catch numbers-at-age. Add small number in case F=0
      CN[y,] <- get_catch(F_full=F_full[y], M=M, 
                          N=J1N[y,], selC=slxC[y,]) + 1e-3
      sumCW[y] <- CN[y,] %*% waa[y,]    # (dot product)
      paaCN[y,] <- (CN[y,]) / sum(CN[y,])
 
      # calculate the predicted survey index in year y and the predicted
      # survey proportions-at-age
      IN[y,] <- get_survey(F_full=F_full[y], M=M, N=J1N[y,], slxC[y,], 
                           slxI=1, timeI=timeI, qI=qI)
      sumIN[y] <- sum(IN[y,])
      paaIN[y,] <- IN[y,] / sum(IN[y,])
      
      # calculate effort based on catchability and the implemented fishing
      # mortality. Effort not typically derived ... could go the other way
      # around and implement E as a policy and calculate F.
      effort[y] <- F_full[y] / qC
      obs_effort[y] <- get_error_idx(type=oe_effort_typ, idx=effort[y], 
                                     par=oe_effort)
      
      # Get observation error data for the assessment model
      obs_sumCW[y] <- get_error_idx(type=oe_sumCW_typ, idx=sumCW[y], 
                                    par=oe_sumCW)
      obs_paaCN[y,] <- get_error_paa(type=oe_paaCN_typ, paa=paaCN[y,], 
                                     par=oe_paaCN)
      obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, idx=sumIN[y], 
                                    par=oe_sumIN)
      obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], 
                                     par=oe_paaIN)

      # if burn-in period is over...
      if(y > nburn){
        # if(debugSink){
        #   sty <- y-ncaayear+1
        #   cat('====== J1N ======\n', file=dbf, append=TRUE)
        #   write.table(get_dwindow(J1N,sty,y), file=dbf, append=TRUE)
        #   cat('====== CN ======\n', file=dbf, append=TRUE)
        #   write.table(get_dwindow(CN,sty,y), file=dbf, append=TRUE)
        #   cat('====== R ======\n', file=dbf, append=TRUE)
        #   write.table(get_dwindow(R,sty,y), file=dbf, append=TRUE)
        #   cat('====== paaIN ======\n', file=dbf, append=TRUE)
        #   write.table(get_dwindow(paaIN,sty,y), file=dbf, append=TRUE)
        # }
        # prepare data & run assessment model
        source('processes/get_tmb_setup.R')
# if(m == 2 & y == 102){ save.image(file='test.Rdata')}
        # include sink file just to keep the console output clean
        sink(file='results/rsink.txt')
        if(debugSink){
          cat('      trying assessment...', file=dbf, append=TRUE)
        }
        tryfit <- try(source('assessment/caa.R'))
        if(debugSink){
          cat('/...assessment complete\n', file=dbf, append=TRUE)
        }
        sink(file=NULL)
        if(class(tryfit) != 'try-error'){
        
          # Fill the arrays with results
          source('processes/fill_repArrays.R')
          # Get fishing mortality for next year's management
          # fbrpy <- get_FBRP(type=fbrpTyp, par=mproc[m,],
                            # sel=endv(rep$slxC), waa=endv(rep$waa), 
                            # M=M[1])
          # note must convert matrices to vectors when using tail() function
          # to get the appropriate behavior
          # bbrpy <- get_BBRP(type=bbrpTyp, par=mproc[m,],
                            # sel=endv(rep$slxC), waa=endv(rep$waa), 
                            # M=endv(rep$M), mat=mat[y,], 
                            # R=rep$R, B=SSBhat, Rfun=mean)
          # apply the harvest control rule
          parpop <- list(waa = tail(rep$waa, 1), 
                         sel = tail(rep$slxC, 1), 
                         M = tail(rep$M, 1), 
                         mat = mat[y,],
                         R = rep$R,
                         B = SSBhat)
          nextF <- get_nextF(parmgt = mproc[m,], parpop = parpop)
          if(y < nyear){
            F_full[y+1] <- rlnorm(1, log(0.02), 0.3)#nextF
          }
        
        }else{
          
          # if the assessment model didn't work then fill the
          # array with NAs
          for(i in 2:length(oacomp)){
            # Determine the dimensionality of each oacomp list component
            # and create a character object with the appropriate
            # number of commas and then evaluate to fill arrays
            # with NAs
            d <- dim(oacomp[[i]])
            commas <- paste0(rep(',', length(d)-1), collapse='')
            eval(parse(text=paste0('oacomp[[i]][', commas, '] <- NA')))
          }
          
          # After filling the arrays with NA values, break out of
          # the loop and move on to the next management strategy
          break
          
        }
          
        # Get fishing mortality for next year's management
        # fbrpy <- get_FBRP(type=fbrpTyp, par=mgtproc[m,],
                          # sel=endv(rep$slxC), waa=endv(rep$waa), 
                          # M=M[1])
        # note must convert matrices to vectors when using tail() function
        # to get the appropriate behavior
        # bbrpy <- get_BBRP(type=bbrpTyp, par=mgtproc[m,],
                          # sel=endv(rep$slxC), waa=endv(rep$waa), 
                          # M=endv(rep$M), mat=mat[y,], 
                          # R=rep$R, B=SSBhat, Rfun=mean)
  
        # # apply the harvest control rule
        # parpop <- list(waa = tail(rep$waa, 1), 
        #                sel = tail(rep$slxC, 1), 
        #                M = tail(rep$M, 1), 
        #                mat = mat[y,],
        #                R = rep$R,
        #                B = SSBhat)
        # 
        # # recommended level of fishing mortality for the next year
        # nextF_rec <- get_nextF(parmgt = mproc[m,], parpop = parpop)
        # nextF <- get_ieF(type='lognormal', F, par=ie_F)
        # 
        # if(y < nyear){
        #   F_full[y+1] <- nextF
        # }
  
      }
      

     
      
    }
  }
}


# Output run time / date information and OM inputs. The random number is
# just ensuring that no simulations will be overwritten because the hpcc
# might finish some in the same second. td is used for uniquely naming the
# output file as well as for listing in the output results.
td <- as.character(Sys.time())
td2 <- gsub(':', '', td)
td2 <- paste(gsub(' ', '_', td2), round(runif(1, 0, 10000)), sep='_')



# save results
save(omval, file=paste0('results/sim/omval', td2, '.Rdata'))

# Create figures
# get_plots(x=omval, dir='results/fig/')


ompar <- readLines('processes/set_om_parameters.R')
cat('\n\nFin.\n\n',
    'Completion at: ',
    td,
    file='results/runInfo.txt', sep='')
cat('\n\n\n\n\n\n\n\n  ##### OM Parameters ##### \n\n',
    ompar,
    file='results/runInfo.txt', sep='\n', append=TRUE)

if(platform == 'Windows'){
  # get_plots(omval, dirOut='results/fig/')
  source('processes/runPost.R')
}
  
print(' ---- Fin ----')
