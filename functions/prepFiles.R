

prepFiles <- function(){
  
  # Remove compiled versions of assessment model. This is important
  # because if previous compiled versions are present they can
  # produce errors when switching from one operating system to another.
  
  fl <- list.files('assessment/')
  extlist <- strsplit(fl, split='\\.')
  ext <- sapply(extlist, tail, 1)
  fl2trash <- ext %in% c('dll', 'o', 'so')
  unlink(file.path('assessment', fl[fl2trash]))
    
}

