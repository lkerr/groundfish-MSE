#This bit of code will look set/update the random number generator based on information in an Rds.
# the Rds is located in path "full.pathRNG" and is named "rng_pattern".  That directory may contain many Rds files, this code pull the last modified Rds. within that Rds, it pulls out the last entry in the list of RNG states and sets that to the random seed.

#this code might be useful if you ran a small number of simulations and wanted to 'continue' from that spot in the RNG generator.  Or if you needed to go  investgate a particular simulation.



rng_details<-file.info(list.files(path=full.pathRNG, full.names=TRUE, pattern=rng_pattern))
rng_details <- rng_details[with(rng_details, order(as.POSIXct(mtime))), ]
files <- rownames(rng_details)
rngfile<-files[length(files)]
myrng<-readRDS(rngfile)
.Random.seed<-myrng[[length(myrng)]]
