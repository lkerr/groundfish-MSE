



get_WAA_pointers <- function(nfleet){
  x <- rep(1, nfleet*2 + 4)
  return(x)
}


get_sel_block_assign <- function(nfleet, nyear){
  x <- lapply(1:nfleet, function(x) rep(x, nyear))
  return(x)
}

get_sel_ini <- function(nage, nfleet){
  # Set up selectivity matrix ... ages + 2 par for log + 4 par for dblLog
  slxTpl <- rbind(matrix(c(0, -1, 0, 0), ncol=4, nrow=nage, byrow=TRUE),
                  matrix(c(nage/2, 0.5, 1, 1, 1, 1, 0.2, 0.2), ncol=4),
                  # matrix(c(5, 0.5, -1, 1, 1, 1, 0.2, 0.2), ncol=4),
                  matrix(c(0, -1, 0, 0), ncol=4, nrow=4, byrow=TRUE))
  slxBlockData <- replicate(nfleet, slxTpl, simplify=FALSE)
  return(slxBlockData)
}

get_prop_rel_mats <- function(nfleet, nage, nyear){
  m <- matrix(0, nrow = nyear, ncol = nage)
  replicate(nfleet, m, simplify = FALSE)
}


# Function to edit the comment files to align with the number of
# fisheries and surveys.
editComments <- function(comVec, tag, n){
    
  wIdx <- grep(pattern = tag, x = comVec, ignore.case = TRUE)

  if(length(wIdx) < 1){
    stop('tag not found')
  }
  cat('found tag:', tag, '... index:', wIdx, '\n')
  baseCom <- sub(pattern = paste0('(', tag, ')'),
                 replacement = '', 
                 x = comVec[wIdx])
  # browser()
  ins <- paste(baseCom, '-', 1:n)
  comVec <- comVec[-wIdx]
  comVec <- append(comVec, ins[1:n], after = wIdx[1]-1)
  return(comVec)
}



