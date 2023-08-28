#' @title Calculate Mohn's Rho
#' 
#' @param stock A storage object for a single species
#' 
#' @return A revised storage object (out) with updated SSB, F, and R Mohn's rho values.

get_MohnsRho <- function(stock){
  
  out <- within(stock, {
    
    if(mproc[m,'ASSESSCLASS'] == 'WHAM'){
      Mohns_Rho_SSB[y] <- wham_storage$MohnsRho_SSB[[r]][[y]] # Indexing changes before this is calculated
      Mohns_Rho_F[y] <- wham_storage$MohnsRho_F[[r]][[y]]
      Mohns_Rho_R[y] <- wham_storage$MohnsRho_R[[r]][[y]]
      Mohns_Rho_N[y] <- wham_storage$MohnsRho_N[[r]][[y]]
    } else{
      peels<-y-fmyearIdx
      if(peels>7){peels<-7}
      if (Sys.info()['sysname'] == "Windows"){
        
        #SSB Mohn's Rho
        tempwd<-getwd()
        SSBnew1<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))$SSB
        idx<-length(SSBnew1)-peels
        SSBnew<-SSBnew1[idx]
        for (p in (y-peels):(y-1)){
          SSBold<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', p,'.rdat', sep = ''))$SSB[idx]
          assign(paste('rhoSSB',p,sep=''),(SSBold-SSBnew)/SSBnew)
        }
        
        #Abundance Mohn's Rho
        Nnew1<-rowSums(readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))$N.age)
        idx<-length(Nnew1)-peels
        Nnew<-Nnew1[idx]
        for (p in (y-peels):(y-1)){
          Nold<-sum(readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', p,'.rdat', sep = ''))$N.age[idx,])
          assign(paste('rhoN',p,sep=''),(Nold-Nnew)/Nnew)
        }
        
        #F Mohn's Rho
        Fnew1<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))$F.report
        idx<-length(Fnew1)-peels
        Fnew<-Fnew1[idx-1]
        for (p in (y-peels):(y-1)){
          Fold<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', p,'.rdat', sep = ''))$F.report[idx]
          assign(paste('rhoF',p,sep=''),(Fold-Fnew)/Fnew)
        }
        
        #Recruitment Mohn's Rho
        Rnew1<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))$N.age[,1]
        Rnew<-Rnew1[idx]
        for (p in (y-peels):(y-1)){
          Rold<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', p,'.rdat', sep = ''))$N.age[idx,1]
          assign(paste('rhoR',p,sep=''),(Rold-Rnew)/Rnew)
        }
      }
      if (Sys.info()['sysname'] == "Linux"){
        
        #SSB Mohn's Rho
        SSBnew1<-readRDS(paste(rundir,'/', stockName, '_', r, '_', y,'.rdat', sep = ''))$SSB
        idx<-length(SSBnew1)-peels
        SSBnew<-SSBnew1[idx]
        for (p in (y-peels):(y-1)){
          SSBold<-readRDS(paste(rundir,'/', stockName, '_', r, '_', p,'.rdat', sep = ''))$SSB[idx]
          assign(paste('rhoSSB',p,sep=''),(SSBold-SSBnew)/SSBnew)
        }
        
        #Abundance Mohn's Rho
        Nnew1<-rowSums(readRDS(paste(rundir,'/', stockName, '_', r, '_', y,'.rdat', sep = ''))$N.age)
        idx<-length(Nnew1)-peels
        Nnew<-Nnew1[idx]
        for (p in (y-peels):(y-1)){
          Nold<-sum(readRDS(paste(rundir,'/', stockName, '_', r, '_', p,'.rdat', sep = ''))$N.age[idx,])
          assign(paste('rhoN',p,sep=''),(Nold-Nnew)/Nnew)
        }
        
        #Fishing Mortality Mohn's Rho
        Fnew1<-readRDS(paste(rundir,'/', stockName, '_', r, '_', y,'.rdat', sep = ''))$F.report
        idx<-length(Fnew1)-peels
        Fnew<-Fnew1[idx]
        for (p in (y-peels):(y-1)){
          Fold<-readRDS(paste(rundir,'/', stockName, '_', r, '_', p,'.rdat', sep = ''))$F.report[idx]
          assign(paste('rhoF',p,sep=''),(Fold-Fnew)/Fnew)
        }
        
        #Recruitment Mohn's Rho
        Rnew1<-readRDS(paste(rundir,'/', stockName, '_', r, '_', y,'.rdat', sep = ''))$N.age[,1]
        idx<-length(Rnew1)-peels
        Rnew<-Rnew1[idx]
        for (p in (y-peels):(y-1)){
          Rold<-readRDS(paste(rundir,'/', stockName, '_', r, '_', p,'.rdat', sep = ''))$N.age[idx,1]
          assign(paste('rhoR',p,sep=''),(Rold-Rnew)/Rnew)
        }
      }
      
      plist <- mget(paste('rhoSSB',(y-peels):(y-1),sep=''))
      pcols <- do.call('cbind', plist)
      Mohns_Rho_SSB[y] <- rowSums(pcols) / peels
      plist <- mget(paste('rhoN',(y-peels):(y-1),sep=''))
      pcols <- do.call('cbind', plist)
      Mohns_Rho_N[y] <- rowSums(pcols) / peels
      plist <- mget(paste('rhoF',(y-peels):(y-1),sep=''))
      pcols <- do.call('cbind', plist)
      Mohns_Rho_F[y] <- rowSums(pcols) / peels
      plist <- mget(paste('rhoR',(y-peels):(y-1),sep=''))
      pcols <- do.call('cbind', plist)
      Mohns_Rho_R[y] <- rowSums(pcols) / peels
    } # End Mohn's rho calculations for non-WHAM EMs
    
  })
  
  return(out)
  
}
