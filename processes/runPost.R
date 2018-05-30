


fl <- list.files('results/sim/', full.names=TRUE)

flLst <- list()
for(i in 1:length(fl)){
  load(fl[i])
  flLst[[i]] <- omval
}

omval <- get_simcat(x=flLst)
names(omval) <- names(flLst[[1]])

get_plots(omval, dirOut='results/fig/')
