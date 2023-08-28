#' @title get_ASAP
#' @description Run Age Structured Assessment Program (ASAP) executable and produce results object
#' 
#' @param stock A storage object for a single species
#'
#' @return #' @return A revised storage object (out) with updated:
#' \itemize{
#'  \item{asapEst}
#'  \item{res - Assessment results, also saved in 'assessment/ASAP/stockNAME_rep_year.rdat' where stockName, rep, and year vary by simulation}
#' }

get_ASAP <- function(stock){

  out <- within(stock, {

    if (Sys.info()['sysname'] == "Windows") {

      # Run the ASAP assessment model
      asapEst <- try(system('assessment/ASAP/ASAP3.exe', show.output.on.console = FALSE))

      # Read in results
      res <- dget('assessment/ASAP/ASAP3.rdat')

      # save .Rdata results from each run
      saveRDS(res, file = paste('assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))

      # save .par file
      #file.copy("asap3.par", paste('assessment/ASAP/', stockName, '_', r, '_', y,'.par', sep = ""), overwrite = TRUE)

    } else if (Sys.info()['sysname'] == "Linux") {

      tempwd <- getwd()
      setwd(rundir)
      asapEst<- try(system("singularity exec $WINEIMG wine ASAP3.EXE", wait = TRUE))

      while (!file.exists('asap3.rdat')) {
        Sys.sleep(1)
      }

      # Read in results
      res <- dget('asap3.rdat')
      
      # save .Rdata results from each run
      saveRDS(res, file = paste(rundir, '/', stockName, '_', r, '_', y,'.rdat', sep = ''))
      
      #save .par file
      #file.copy("asap3.par", paste(rundir, '/', stockName, '_', r, '_', y,'.par', sep = ""), overwrite = TRUE)

      setwd(tempwd)

    } # End of Linux run

  }) # Close stock object
  
  return(out)

}
