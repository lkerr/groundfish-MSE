

# Process to generate a set of management procedures to include when
# running the assessment model


# Potential proxies for Fmax. A list of the names of the proxy methods
# and a list of the potential values to use for each method.
Fprox <- list('YPR', 'SPR')
Fval <- list(c(0.1, 0.15),
             c(0.3, 0.4))

# Potential proxies for Bmax. A list of the names of the proxy methods
# and a list of the potential values to use for each method.
Bprox <- list('RSSBR', 'SIM')
Bval <- list(c(0.8, 1, 0.2),
             c(NA, NA))


# Potential versions of harvest control rules
HCR <- c('slide', 'simpleThresh')

# expand out the potential values for the combinations of each proxy
# method and its potential values
egF <- lapply(1:length(Fprox), 
              function(x) expand.grid(Fprox[[x]], Fval[[x]]))
egB <- lapply(1:length(Bprox), 
              function(x) expand.grid(Bprox[[x]], Bval[[x]]))

# Concatonate the lists of expanded combinations for proxy methods and
# potential values
fopt <- do.call(rbind, egF)
bopt <- do.call(rbind, egB)

# Make the proxy methods into a list and determine the number of rows
# in each of the list components. Add an additional list element for
# each of the harvest control rules
lst <- list(fopt, bopt)
nrlist <- sapply(lst, function(x) 1:nrow(x))
nrlist[[3]] <- 1:length(HCR)

# Determine row IDs for all combination of reference point calculations
# and harvest control rule methods
id <- expand.grid(nrlist)

# Generate a data frame containing all combinations of proxy methods
# and control rules by using the ID to index
methdf <- cbind( HCR[id[,3]], lst[[1]][id[,1],], lst[[2]][id[,2],])
names(methdf) <- c('HCR', 'FREF_TYP', 'FREF_PAR0', 'BREF_TYP',
                'BREF_PAR0')

# next identify which of the rows are superfluous given the HCR
# (e.g., you only need a biomass-based reference point if you're
# using a simple threshold biomass-based control rule)
# wthresh <- methdf$HCR == 'simpleThresh'
# methdf$FREF_TYP[wthresh] <- NA
# methdf$FREF_VAL[wthresh] <- NA

mproc <- unique(methdf)

mproc <- subset(mproc, HCR =='slide')

# Temporarily use the imported version until I figure out a good
# way to make this work building it in the code. May as well not
# do this until it's done.
mproc <- read.csv('modelParameters/mproc.csv', header=TRUE,
                    stringsAsFactors=FALSE)

if(mprocTest){
  
  mproc <- read.csv('modelParameters/mprocTest.csv', header=TRUE,
                      stringsAsFactors=FALSE)
  cat('***mprocTest == TRUE (in set_om_parameters.R): testing run***\n') 

}


# Check to ensure that the management procedures are a subset of the
# available options
# get_mprocCheck(mproc)

