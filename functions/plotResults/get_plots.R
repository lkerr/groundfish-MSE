

# Driver function to create output plots from the simulation
# 
# x: list of output for plots (i.e., omval)
# 
# dirIn: simulation directory to grab specific examples for
#        particular plots (e.g., temperature time series)




get_plots <- function(x, dirIn, dirOut){
  
  # Load one of the simulation environments
  load(file.path(dirIn, list.files(dirIn)[1]))
  
  nm <- names(x)
  bxidx <- which(nm %in% c("SSB", "R", "F_full", "sumCW", "sumCWcv", 
                           "ginipaaCN", "ginipaaIN", "OFdStatus",
                           "mxGradCAA"))
  
  rpidx <- which(nm %in% c("FPROXY", "SSBPROXY"))
  
  # index for trajectories to plot
  trajidx <- which(nm %in% c("SSB", "R", "F_full", "sumCW", 
                             "ginipaaCN", "ginipaaIN", "OFdStatus",
                             "mxGradCAA",
                             "relE_qI", "relE_qC", "relE_selC",
                             "relE_ipop_mean", "relE_ipop_dev",
                             "relE_R_dev", "FPROXY", "SSBPROXY"))
  
  # Year names
  yridx <- which(nm %in% "YEAR")
  
  # Performance measures: medium term years 10-20
  for(i in bxidx){
    jpeg(paste0(dirOut, nm[i], 'yr10-20.jpg.'))

      # If you just have a bunch of NAs for some reason make an
      # empty plot as a place-holder
      if(all(is.na(x[[i]][,,10:20,drop=FALSE]))){
        plot(0)
      }else{
        get_box(x=x[[i]][,,10:20,drop=FALSE])
      }
    
    dev.off()
      
  }
  
  # Performance measures using first 5 years
  for(i in bxidx){
    
    jpeg(paste0(dirOut, nm[i], 'yr1-5.jpg.'))
    # If you just have a bunch of NAs for some reason make an
    # empty plot as a place-holder
    if(all(is.na(x[[i]][,,1:5,drop=FALSE]))){
      plot(0)
    }else{
      get_box(x=x[[i]][,,1:5,drop=FALSE])
    }
    
    dev.off()
    
  }
  
  # Performance measures: long term 20-50 years
  for(i in bxidx){
    
    jpeg(paste0(dirOut, nm[i], 'yr20-end.jpg.'))
    
    # If you just have a bunch of NAs for some reason make an
    # empty plot as a place-holder
    ny <- dim(x[[i]])[3]
    if(all(is.na(x[[i]][,,20:ny,drop=FALSE]))){
      plot(0)
    }else{
      get_box(x=x[[i]][,,20:ny,drop=FALSE])
    }
    
    dev.off()
    
  }
  
  dir.create(file.path(dirOut, 'RP'), showWarnings=FALSE)
  for(i in 1:dim(x$FPROXY)[2]){
  
    jpeg(paste0(dirOut, 'RP/', 'mp', i, '.jpg.'))
 
      get_rptrend(x=x$FPROXY[,i,], y=x$SSBPROXY[,i,])
    
    dev.off()
    
    # HCR plot not working -- got rid of RP. Not bothering to change
    # back right now because I don't think it was that useful of a plot.
    # jpeg(paste0(dirOut, 'RP/', 'hcr', i, '.jpg.'))
    # 
    #   get_hcrPlot(rp[,i,,])
    # 
    # dev.off()
    
    
  }
 
 
  # Get diagnostic plots that show (1) the temperature history; (2) the
  # growth models (with temperature); and (3) the recruitment models
  # (with temperature)
  source('processes/runSetup.R')

  # Time-series temperature plot
  jpeg(paste0(dirOut, 'tempts.jpg.'),
       width=480*1.75, height=480, pointsize=12*1.5)
    yrs <- (mxyear - length(temp)+1):mxyear
    get_tempTSPlot(tanom = Tanom, yrs = yrs,
                   fmyear=fmyear, tanomStd = anomStd)
  dev.off()
 
  # Plot describing how growth changed over time
  jpeg(paste0(dirOut, 'laa.jpg.'),
       width=480*1.75, height=480, pointsize=12*1.5)
    ptyridx <- fmyear:length(yrs)
    get_laaPlot(laa_par=laa_par, laa_typ=laa_typ, laafun=get_lengthAtAge, 
                ages=fage:(ceiling(1.5*page)), Tanom=Tanom[ptyridx], 
                ptyrs=yrs[ptyridx])
  dev.off()
  
  # # Plot describing how average recruitment changed over time
  # jpeg(paste0(dirOut, 'laa.jpg.'),
  #      width=480*1.75, height=480, pointsize=12*1.5)
  #   ptyridx <- fmyear:length(yrs)
  #   get_laaPlot(rec_par=rec_par, laa_typ=laa_typ, laafun=get_lengthAtAge, 
  #               ages=fage:(ceiling(1.5*page)), Tanom=Tanom[ptyridx], 
  #               ptyrs=yrs[ptyridx])
  # dev.off()
  # 
  
  
  
  ### Trajectory plots
  dir.create(file.path(dirOut, 'Traj'), showWarnings=FALSE)
  
  # only make a few trajectories so you don't get so many plots
  repidx <-sample(1:dim(x[[trajidx[1]]])[1], 
                  size=min(5, dim(x[[trajidx[1]]])[1]))

  
  for(i in trajidx){

    tempPM <- x[[i]]
    PMname <- nm[i]
    
    # Calculate a range for the boxplot y axes. In order to do this need
    # to run through the loop first and calculate all the boxplot stats.
    bpstats <- list()
    for(mp in 1:dim(tempPM)[2]){
      tempPMmp <- tempPM[,mp,]
      bpstats[[mp]] <- boxplot(x = tempPMmp, plot=FALSE)$stats
    }
    
    # Now get the range of the statistics to use in the loop (boxplots).
    yrgbx <- range(unlist(bpstats), na.rm=TRUE)
    
    # Get y range for common axes among the reps (simulation trajectories)
    yrgrsim <- range(tempPM[repidx,,], na.rm=TRUE)
 
    # Account for 0-1 nature of binary variabiles (e.g., overfished status)
    if(is.na(yrgbx[1])){
      yrgbx <- c(0, 1)
    }
    
    dir.create(file.path(dirOut, 'Traj', PMname), showWarnings=FALSE)
    for(mp in 1:dim(tempPM)[2]){
      
      # Simplify the references
      tempPMmp <- tempPM[,mp,]

      # First do a general boxplot of the trajectory over years
      jpeg(paste0(dirOut, 'Traj/', PMname, '/boxmp', mp, '.jpg.'),
           width=480*1.75, height=480, pointsize=12*1.5)
        
        par(mar=c(4,4,1,1))
        get_tbxplot(x = tempPMmp, PMname=PMname, yrs=x$YEAR,
                    printOutliers=FALSE, yrg=yrgbx)
      
      dev.off()
      
     
      # Do (up to) 5 trajectories as examples
      for(r in repidx){

        jpeg(paste0(dirOut, 'Traj/', PMname, '/mp', mp, 'rep', r, '.jpg.'),
             width=480*1.75, height=480, pointsize=12*1.5)
       
          get_tplot(x=tempPMmp[r,], yrs = x$YEAR, 
                    mpName=paste('MP', mp), 
                    PMname=PMname, ylim=yrgrsim)
          # plot(tempPM[r,mp,], type='o')
        
        dev.off()
        
      }
    }
    
    # Trajectories for the medians of each MP over time
    
    # Get the medians of each performance measure over time
    mpMed <- apply(tempPM, c(2,3), median, na.rm=TRUE)
    
    # Make the plot
    jpeg(paste0(dirOut, 'Traj/', PMname, '/MPmedTraj.jpg.'),
         width=480*1.75, height=480, pointsize=12*1.5)
      par(mar=c(4,4,1,1))
      get_mpMedTraj(mpMedMat = mpMed, ylab=nm[i])
    dev.off()
  }
  
  
}







