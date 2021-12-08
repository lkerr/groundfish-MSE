# This file contains the following functions:
  # get_WAA_pointers
  # get_sel_block_assign
  # get_sel_ini
  # get_prop_rel_mats
  # editComments

#' @title Weight-at-age Pointers
#' @description  Get pointers to weight-at-age by fleet
#' 
#' @param nfleet A number specifying the number of fleets
#' 
#' @return A vector of 1s equal in length to 4 + 2*nfleet
#'
#' @family managementProcedure stockAssess
#' 
#' @example 
#' get_WAA_pointers(nfleet = 2)
#' 
#' @export

get_WAA_pointers <- function(nfleet){
  x <- rep(1, nfleet*2 + 4)
  return(x)
}

#' @title Selectivity Block Assignment
#' @description Get selectivity block assignment by fleet
#' 
#' @param nfleet A number specifying the number of fleets
#' @template global_nyear
#' 
#' @return A list of vectors indicating selectivity block assignment by fleet, each vector is of length nyear.
#' 
#' @family managementProcedure stockAssess
#' 
#' @example 
#' get_sel_block_assign(nfleet = 2, nyear = 5)
#' 
#' @export

get_sel_block_assign <- function(nfleet, nyear){
  x <- lapply(1:nfleet, function(x) rep(x, nyear))
  return(x)
}


#' @title Initial Selectivity 
#' @description Get initial selectivity matrix by fleet
#' 
#' @param nage A number specifying the number of ages
#' @param nfleet A number specifying the number of fleets
#' 
#' @return A list of matrices by fleet, each matrix has a row for each age + 6 rows for selectivity parameters (ASAP selectivity block structure)
#' 
#' @family managementProcedure stockAssess
#' 
#' @example 
#' get_sel_block_assign(nfleet = 2, nyear = 5)
#' 
#' @export

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

#' @title Edit Comment Files 
#' @description Edit comment files to align with the number of fisheries and surveys
#' 
#' @param comVec ???
#' @param tag ???
#' @param n ???
#' 
#' @return 
#' 
#' @family managementProcedure stockAssess
#' 
#' @example 
#' get_sel_block_assign(nfleet = 2, nyear = 5)
#' 
#' @export

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



