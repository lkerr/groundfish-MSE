


# almat: age length matrix (or data frame) where
#        ages are the first column and lengths are the
#        second column
#        
# lint: sequence interval for length classification
# 
# roundBase: level of rounding for length classification
#            (e.g., if 5 round to nearest 5)


get_alk <- function(almat,
                    lint,
                    roundBase
                    ){

  # separate out the ages and lengths into vectors
  ages <- almat[,1]
  lengths <- almat[,2]
  
  ## determine the length bins
  # get sequence endpoints over the set of lenghts rounded to
  # roundBase
  lbmin <- roundBase * floor(min(lengths) / roundBase)
  lbmax <- roundBase * floor((max(lengths)+roundBase) / roundBase)
  
  ## get the bins
  lbin <- seq(lbmin, lbmax, lint)
  # ensure that the range will include all values
  if(any(lengths > tail(lbin, 1))){
    lbin <- c(lbin, tail(lbin, 1)+lint)
  }
  
  ## put the lengths into bins
  # name the bins
  midpts <- lbin[-length(lbin)] + lint/2
  # categorize the lengths into bins
  lengthsCat <- cut(lengths, breaks=lbin, labels=midpts)

  ## put ages into bins - necessary in case there are missing
  ## ages
  agelab <- min(ages):max(ages)
  ageBreaks <- seq(min(ages)-0.5, max(ages)+0.5, 1)
  agesCat <- cut(ages, breaks=ageBreaks, labels=agelab)
  
  # classify the ages and lengths into a table
  altabRaw <- table(agesCat, lengthsCat)
  alk <- prop.table(altabRaw, 2)
  
  # use unclass to turn into a matrix and convert any NaN to 0
  alk <- unclass(alk)
  alk[is.nan(alk)] <- 0

  ret <- list(alk=alk,
              lbin=lbin,
              midpts=midpts,
              ages=agelab)
  return(ret)
}
