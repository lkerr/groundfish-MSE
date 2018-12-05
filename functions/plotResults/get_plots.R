

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
                           "ginipaaCN", "ginipaaIN", "OFdStatus"))
  
  rpidx <- which(nm %in% c("FPROXY", "SSBPROXY"))
  
  # index for trajectories to plot
  trajidx <- which(nm %in% c("SSB", "R", "F_full", "sumCW", 
                             "ginipaaCN", "ginipaaIN", "OFdStatus"))
  
  # Year names
  yridx <- which(nm %in% "YEAR")
  
  # Performance measures using all the years
  for(i in bxidx){
    
    jpeg(paste0(dirOut, nm[i], '.jpg.'))

      # If you just have a bunch of NAs for some reason make an
      # empty plot as a place-holder
      if(all(is.na(x[[i]]))){
        plot(0)
      }else{
        get_box(x=x[[i]])
      }
    
    dev.off()
      
  }
  
  # Performance measures using first 15 years
  for(i in bxidx){
    
    jpeg(paste0(dirOut, nm[i], 'First15.jpg.'))
    
    # If you just have a bunch of NAs for some reason make an
    # empty plot as a place-holder
    if(all(is.na(x[[i]][,,1:15]))){
      plot(0)
    }else{
      get_box(x=x[[i]][,,1:15])
    }
    
    dev.off()
    
  }
  
  # Performance measures using last 15 years
  for(i in bxidx){
    
    jpeg(paste0(dirOut, nm[i], 'Last15.jpg.'))
    
    # If you just have a bunch of NAs for some reason make an
    # empty plot as a place-holder
    ny <- dim(x[[i]])[3]
    if(all(is.na(x[[i]][,,(ny-14):ny]))){
      plot(0)
    }else{
      get_box(x=x[[i]][,,(ny-14):ny])
    }
    
    dev.off()
    
  }
  
    
  dir.create(file.path(dirOut, 'RP'), showWarnings=FALSE)
  for(i in 1:dim(omval$FPROXY)[2]){
  
    jpeg(paste0(dirOut, 'RP/', 'mp', i, '.jpg.'))
 
      get_rptrend(x=omval$FPROXY[,i,], y=omval$SSBPROXY[,i,])
    
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
    get_tempTSPlot(tempts = temp, yrs = yrs,
                   fmyear=fmyear, anomStd = anomStd)
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
  
  # Trajectory plots
  dir.create(file.path(dirOut, 'Traj'), showWarnings=FALSE)
  for(i in trajidx){

    tempPM <- omval[[i]]
    PMname <- nm[i]
    
    dir.create(file.path(dirOut, 'Traj', PMname), showWarnings=FALSE)
    for(mp in 1:dim(tempPM)[2]){
      
      for(r in 1:dim(tempPM)[1]){
    
        jpeg(paste0(dirOut, 'Traj/', PMname, '/mp', mp, 'rep', r, '.jpg.'),
             width=480*1.75, height=480, pointsize=12*1.5)
        
          get_tplot(x=tempPM[r,mp,], yrs = omval$YEAR, 
                    mpName=paste('MP', mp), 
                    PMname=PMname)
          # plot(tempPM[r,mp,], type='o')
        
        dev.off()
        
      }
    }
    
    #yridx -- label
    
  }
  
  
}







