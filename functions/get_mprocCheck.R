
# Function to check to make sure the values in mproc are part of the set
# of potential values before running the code. This avoids more confusing
# error messages later on.
# 
# mproc: the mproc file *after* it has been read in as a data frame.



get_mprocCheck <- function(mproc){
  
  assessclass <- c('CAA', 'PLANB')
  hcr <- c('slide', 'simplethresh', 'constF', NA)
  fref_typ <- c('YPR', 'SPR', 'Fmed', NA)
  bref_typ <- c('RSSBR', 'SIM', NA)
  # rfun_nm <- c('MEAN', 'L5SAMP', 'recT', NA)
  rfun_nm <- c('forecast', 'hindcastMean', NA)
  
  msg <- c()
  
  # Note: use paste0 when splitting text over multiple lines to get correct-
  #       looking error message output
  
  if(!all(mproc$ASSESSCLASS %in% assessclass)){
    msg <- c(msg, 
             paste0('unrecognized entry in ASSESSCLASS column of mproc.txt:',
              ' check names'))
  }
  
  if(!all(mproc$HCR %in% hcr)){
    msg <- c(msg, 
             paste0('unrecognized entry in HCR column of mproc.txt:',
             ' check names'))
  }
  
  if(!all(mproc$FREF_TYP %in% fref_typ)){
    msg <- c(msg, 
             paste0('unrecognized entry in FREF_TYP column of mproc.txt:',
              ' check names'))
  }

  if(any(!is.na(mproc$FREF_LEV) & 
         (mproc$FREF_LEV < 0 | mproc$FREF_LEV > 1)
         )){
    msg <- c(msg, 
             paste0('value out of range in FREF_LEV column of mproc.txt:',
             ' check values'))
  }
  
  if(!all(mproc$BREF_TYP %in% bref_typ)){
    msg <- c(msg, 
             paste0('unrecognized entry in BREF_TYP column of mproc.txt:',
             ' check names'))
  }
  
  if(!all(is.na(mproc$BREF_LEV) | mproc$BREF_LEV == floor(mproc$BREF_LEV))){
    msg <- c(msg, 
             paste0('value out of range in BREF_LEV column of mproc.txt:',
             ' check values'))
  }
  
  if(!all(mproc$RFUN_NM %in% rfun_nm)){
    msg <- c(msg, 
             paste0('unrecognized entry in RFUN_NM column of mproc.txt:',
             ' check names'))
  }

  if(any(!is.na(mproc$RPInt) & 
         ( mproc$RPInt < 1 | !mproc$RPInt == floor(mproc$RPInt) )
     )){
    msg <- c(msg, 
             paste0('value out of range in RPInt column of mproc.txt:',
             ' must be both an integer and greater than 0'))
  }
  
  # If there were any errors then 
  if(length(msg) > 0){
    stop(c(paste(length(msg), 'error(s) in mproc.txt file\n'), 
           paste(msg, collapse='\n')))
  }
  
}


#### Test

# (just random stuff -- not actual sets of trials!)

## correct
# mproc1 <- data.frame(ASSESSCLASS = c('CAA', 'CAA', 'PLANB'),
                    # HCR = c('slide', 'simplethresh', 'constF'),
                    # FREF_TYP = c('YPR', 'SPR', 'Fmed'),
                    # FREF_LEV = c(0.1, 0.5, 0.1),
                    # BREF_TYP = c('SIM', 'SIM', 'RSSBR'),
                    # BREF_LEV = c(NA, NA, NA),
                    # RFUN_NM = c('L5SAMP', 'MEAN', 'recT'),
                    # RPInt = c(1, 3, 5))
# 
## incorrect
# mproc2 <- data.frame(ASSESSCLASS = c('CAAXXX', 'CAA', 'PLANB'),
#                      HCR = c('slide', 'simplethresh', 'constF'),
#                      FREF_TYP = c('YPR', 'SPR', 'Fmed'),
#                      FREF_LEV = c(0.1, 0.5, 0.1),
#                      BREF_TYP = c('SIM', 'SIMXXX', 'RSSBR'),
#                      BREF_LEV = c(NA, NA, NA),
#                      RFUN_NM = c('L5SAMPXXX', 'MEAN', 'recT'),
#                      RPInt = c(1, 3, 5))
# 
# mproc3 <- data.frame(ASSESSCLASS = c('CAA', 'CAA', 'PLANB'),
#                      HCR = c('slide', 'simplethresh', 'constF'),
#                      FREF_TYP = c('YPR', 'SPR', 'Fmed'),
#                      FREF_LEV = c(0.1, 0.5, 999),
#                      BREF_TYP = c('SIM', 'SIM', 'RSSBR'),
#                      BREF_LEV = c(25.999, NA, NA),
#                      RFUN_NM = c('L5SAMP', 'MEAN', 'recT'),
#                      RPInt = c(1, 3, 5.999))
# 
# 
# get_mprocCheck(mproc1)
# get_mprocCheck(mproc2)
# get_mprocCheck(mproc3)
