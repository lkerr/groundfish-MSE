
# Function to check to make sure the values in mproc are part of the set
# of potential values before running the code. This avoids more confusing
# error messages later on.
# 
# mproc: the mproc file *after* it has been read in as a data frame.



get_mprocCheck <- function(mproc){
  
  # List all the potential values for each of the columns that require
  # text input (i.e., everything but the parameter columns)
  
  
  assessclass <- c('CAA', 'PLANB')
  hcr <- c('slide', 'simplethresh', 'constF', NA)
  fref_typ <- c('YPR', 'SPR', 'SSBR', 'Fmed', 'FmsySim', NA)
  bref_typ <- c('RSSBR', 'SIM', NA)
  rfun_nm <- c('forecast', 'hindcastMean', NA)
  
  msg <- c()
  
  # Note: use paste0 when splitting text over multiple lines to get correct-
  #       looking error message output
  
  if(any(is.na(mproc$BREF_TYP) | mproc$BREF_TYP == 'RSSBR')){
    msg <- c(msg, 'RSSBR unimplemented: change to SIM')
  }
  
  # Check that the string names that are entered are all correct

  
  if(!all(mproc$ASSESSCLASS %in% assessclass)){
    msg <- c(msg, 
             paste0('unrecognized entry in ASSESSCLASS column of mproc.csv:',
              ' check names'))
  }
  
  if(!all(mproc$HCR %in% hcr)){
    msg <- c(msg, 
             paste0('unrecognized entry in HCR column of mproc.csv:',
             ' check names'))
  }
  
  if(!all(mproc$FREF_TYP %in% fref_typ)){
    msg <- c(msg, 
             paste0('unrecognized entry in FREF_TYP column of mproc.csv:',
              ' check names'))
  }

  
  if(!all(mproc$RFUN_NM %in% rfun_nm)){
    msg <- c(msg, 
             paste0('unrecognized entry in RFUN_NM column of mproc.csv:',
                    ' check names'))
  }


  if(any(!is.na(mproc$FREF_PAR0) & 
         !mproc$FREF_PAR0 == floor(mproc$FREF_PAR0))){
    msg <- c(msg, 
             paste0('value out of range in FREF_PAR0 column of mproc.csv:',
             ' must be integer'))
  }

  
  if(!all(mproc$BREF_TYP %in% bref_typ)){
    msg <- c(msg, 
             paste0('unrecognized entry in BREF_TYP column of mproc.csv:',
                    ' check names'))
  }
  

  if(!all(mproc$RFUN_NM %in% rfun_nm)){
    msg <- c(msg, 
             paste0('unrecognized entry in RFUN_NM column of mproc.csv:',
                    ' check names'))
  }


  
  # Check that the reference point interval is correct
  
  if(any(!is.na(mproc$RPInt) & 
         ( mproc$RPInt < 1 | !mproc$RPInt == floor(mproc$RPInt) )
  )){
    msg <- c(msg, 
             paste0('value out of range in RPInt column of mproc.csv:',
                    ' must be both an integer and greater than 0'))
  }
  
  # If there were any errors then stop and report
    if(length(msg) > 0){
      stop(c(paste(length(msg), 'error(s) in mproc.csv file:\n'),
             paste(msg, collapse='\n')))
    }
  
}


#
#
# More checks below but complicated conditions -- will wait to complete
# until management procedures are finalized.
#
#



  
#   # Check that the parameter values are all in range given the
#   # other inputs. Looped to help deal with different classes of MPs in the
#   # same input file.
#   
#   for(i in 1:length(mproc)){
#   
#     # Per-recruit approaches to Fmsy
#     
#     if(!is.na(mproc$FREF_TYP[i]) & 
#        (mproc$FREF_TYP[i] == 'YPR' | mproc$FREF_TYP[i] == 'SPR')){
#       
#       if(!is.na(mproc$FREF_PAR1[i])){
#         msg <- c(msg, 
#                  paste0('if using per-recruit F reference point do ',
#                         'not include a value for FREF_PAR1 ',
#                         '(line ', i, ')'))
#       }
#       
#       if(!is.na(mproc$FREF_PAR0[i]) & 
#          (mproc$FREF_PAR0[i] < 0 | mproc$FREF_PAR0[i] > 1)){
#         msg <- c(msg, 
#                  paste0('if using per-recruit F reference point FREF_PAR0 ',
#                         'must be between 0.0 and 1.0 ', 
#                         '(line', i, ')'))
#       }
#     }
#     
#     # Fmsy simulation-based approaches
#     
#     if(!is.na(mproc$FREF_TYP[i]) & mproc$FREF_TYP[i] == 'FmsySim'){
#       
#       if(is.na(mproc$FREF_PAR0[i]) | is.na(mproc$FREF_PAR1[i])){
#         msg <- c(msg, 
#                  paste0('If using simulations then FREF_PAR1 and FREF_PAR0', 
#                         'must both be integers (line', i, ')'))
#       }
#       
#       if(mproc$RFUN_NM[i] == 'hindcastMean'){
#         
#         if(mproc$FREF_PAR0[i] < mproc$FREF_PAR1[i]){
#           
#           msg <- c(msg, 
#                    paste0('If using simulations and hindcastMean then', 
#                           'FREF_PAR1 must be > FREF_PAR0 ',
#                           '(line', i, ')'))
#         }
#         
#         if(!is.integer(mproc$FREF_PAR0[i]) | 
#            !is.integer(mproc$FREF_PAR1[i])){
#           
#           msg <- c(msg, 
#                    paste0('If using simulations and hindcastMean then', 
#                           'FREF_PAR1 and FREF_PAR0 must be (negative) integers ',
#                           '(line', i, ')'))
#         }
#         
#         if(mproc$FREF_PAR1[i] > -1 | mproc$FREF_PAR1[i] > -1){
#           msg <- c(msg, 
#                    paste0('If using simulations and hindcastMean then', 
#                           'FREF_PAR1 and FREF_PAR0 must be (negative) integers ',
#                           '(line', i, ')'))
#         }
#       }
#       
#       if(mproc$RFUN_NM[i] == 'forecast'){
#       
#         if(!is.na(mproc$FREF_PAR1[i])){
#           msg <- c(msg, 
#                    paste0('If using simulations and forecast then', 
#                           'FREF_PAR1 should be NA ',
#                           '(line', i, ')'))
#         }
#         
#         if(!is.integer(mproc$FREF_PAR1[i])){
#           msg <- c(msg, 
#                    paste0('If using simulations and forecast then', 
#                           'FREF_PAR1 should be an integer > 0 ',
#                           '(line', i, ')'))
#         }
#         
#         if(mproc$FREF_PAR1[i] < 0){
#           msg <- c(msg, 
#                    paste0('If using simulations and forecast then', 
#                           'FREF_PAR1 should be an integer > 0 ',
#                           '(line', i, ')'))
#         }
#       }
#     }
#     
#     # Bmsy simulation-based approaches
#     
#     if(!is.na(mproc$BREF_TYP[i]) & mproc$BREF_TYP[i] == 'SIM'){
#       
#       if(is.na(mproc$BREF_PAR0[i]) | is.na(mproc$BREF_PAR1[i])){
#         msg <- c(msg, 
#                  paste0('If using simulations then BREF_PAR1 and BREF_PAR0', 
#                         'must both be integers (line', i, ')'))
#       }
#       
#       if(mproc$RFUN_NM[i] == 'hindcastMean'){
#         
#         if(mproc$BREF_PAR0[i] < mproc$BREF_PAR1[i]){
#           
#           msg <- c(msg, 
#                    paste0('If using simulations and hindcastMean then', 
#                           'BREF_PAR1 must be > BREF_PAR0',
#                           '(line', i, ')'))
#         }
#         
#         if(!is.integer(mproc$BREF_PAR0[i]) | 
#            !is.integer(mproc$BREF_PAR1[i])){
#           
#           msg <- c(msg, 
#                    paste0('If using simulations and hindcastMean then', 
#                           'BREF_PAR1 and FREF_PAR0 must be (negative) integers ',
#                           '(line', i, ')'))
#         }
#         
#         if(mproc$BREF_PAR1[i] > -1 | mproc$BREF_PAR1[i] > -1){
#           msg <- c(msg, 
#                    paste0('If using simulations and hindcastMean then', 
#                           'BREF_PAR1 and BREF_PAR0 must be (negative) integers ',
#                           '(line', i, ')'))
#         }
#       }
#       
#       if(mproc$RFUN_NM[i] == 'forecast'){
#         
#         if(!is.na(mproc$BREF_PAR1[i])){
#           msg <- c(msg, 
#                    paste0('If using simulations and forecast then', 
#                           'BREF_PAR1 should be NA ',
#                           '(line', i, ')'))
#         }
#         
#         if(!is.integer(mproc$BREF_PAR1[i])){
#           msg <- c(msg, 
#                    paste0('If using simulations and forecast then', 
#                           'BREF_PAR1 should be an integer > 0 ',
#                           '(line', i, ')'))
#         }
#         
#         if(!is.na(mproc$BREF_PAR1[i]) & mproc$BREF_PAR1[i] < 0){
#           msg <- c(msg, 
#                    paste0('If using simulations and forecast then', 
#                           'BREF_PAR1 should be an integer > 0 ',
#                           '(line', i, ')'))
#         }
#       }
#     }
#       
#   }
# 
#   
#   # If there were any errors then stop and report
#   if(length(msg) > 0){
#     stop(c(paste(length(msg), 'error(s) in mproc.csv file:\n'), 
#            paste(msg, collapse='\n')))
#   }
#   
# }
# 
# 
# #### Test
# 
# # (just random stuff -- not actual sets of trials!)
# 
# # correct
# mproc1 <- data.frame(ASSESSCLASS = c('CAA', 'CAA', 'PLANB'),
#                      HCR = c('slide', 'simplethresh', NA),
#                      FREF_TYP = c('YPR', 'SPR', NA),
#                      FREF_PAR0 = c(0.1, 0.5, 0.1),
#                      FREF_PAR1 = c(NA, NA, NA),
#                      BREF_TYP = c('SIM', 'SIM', NA),
#                      BREF_PAR0 = c(-30, 10, NA),
#                      BREF_PAR1 = c(-1, NA, NA),
#                      RFUN_NM = c('hindcastMean', 'forecast', NA),
#                      RPInt = c(1, 3, NA))
# 
# # incorrect
# mproc2 <- data.frame(ASSESSCLASS = c('CAAXXX', 'CAA', 'PLANB'),
#                      HCR = c('slide', 'simplethresh', 'constF'),
#                      FREF_TYP = c('YPR', 'SPR', 'Fmed'),
#                      FREF_PAR0 = c(0.1, 0.5, 0.1),
#                      FREF_PAR1 = c(0.1, 0.5, 0.1),
#                      BREF_TYP = c('SIM', 'SIMXXX', 'RSSBR'),
#                      BREF_PAR0 = c(NA, NA, NA),
#                      RFUN_NM = c('L5SAMPXXX', 'MEAN', 'recT'),
#                      RPInt = c(1, 3, 5))
# 
# mproc3 <- data.frame(ASSESSCLASS = c('CAA', 'CAA', 'PLANB'),
#                      HCR = c('slide', 'simplethresh', 'constF'),
#                      FREF_TYP = c('YPR', 'SPR', 'FMSY'),
#                      FREF_PAR0 = c(0.1, 0.5, 99),
#                      BREF_TYP = c('SIM', 'SIM', 'RSSBR'),
#                      BREF_PAR0 = c(25.999, NA, NA),
#                      RFUN_NM = c('L5SAMP', 'MEAN', 'recT'),
#                      RPInt = c(1, 3, 5.999))
# 
# 
# get_mprocCheck(mproc1)
# get_mprocCheck(mproc2)
# # get_mprocCheck(mproc3)
