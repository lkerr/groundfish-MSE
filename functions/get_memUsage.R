#' @title Report Memory Usage
#' @description Extract HPCC memory usage information from .o output files and save to a .txt file.
#' 
#' @param runClass A string specifying the runclass, options: ??? Why is there only an HPCC runClass option?
#' \itemize{
#'   \item{"HPCC" - MSE runs performed on High Performance Computing Cluster}
#' }
#' 
#' @return A text table written to the memUsage.txt file in the working directory, nothing returned to R environment.
#' 
#' @family postprocess
#' 

get_memUsage <- function(runClass){
  
  if(runClass == 'HPCC'){
  
    # list all the files in the folder
    flist <- list.files('..')
  
    # convoluted approach to get at the file extensions -- split out all the
    # letters in the file names, reverse them, then paste them back together
    revflist <- sapply(sapply(sapply(flist, strsplit, split=''), rev), 
                       paste, collapse='')
    
    # identify which files have extension .o (reversed because reversed the
    # file names in the previous step)
    whicho <- which(substr(revflist, start=1, stop=2) == 'o.')

    # read in the .o files
    rl <- sapply(whicho, function(x) readLines(file.path('../', flist[x])))
    rlv <- unlist(rl)
    
    # identify which entries refer to the maximum memory that was used
    whichmm <- grep(rlv, pattern = 'Max Memory')
    
    if(length(whichmm) > 0){
    
      # Just the max memory values as strings
      mmtxt <- rlv[whichmm]
      
      # extract just the numbers
      mm <- sapply(1:length(mmtxt), 
                   function(x) as.numeric(gsub('\\D', '', mmtxt[x])))
  
      mmStats <- quantile(mm, na.rm=TRUE)
      
      write.table(mmStats, file='../memUsage.txt', row.names=TRUE)
      cat('Quantiles for memory usage (MB)\n',
          names(mmStats), 
          '\n',
          mmStats,
          file='../memUsage.txt')
      
    }
    
  }
  
  return(NULL)
}
