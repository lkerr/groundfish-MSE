
ie_folder_readin<-grep("^results_202",mproc$ie_source, value=TRUE)
ie_folder_readin<-unique(ie_folder_readin)

if (length(ie_folder_readin)>1) {
  stop("multiple ie_folders specified. Check mprocfile")
}

if (length(ie_folder_readin==1)) {
  old_name<-list.files(path=here(ie_folder_readin,"sim"),pattern="^omvalGlobal?")
  load(here(ie_folder_readin,"sim",old_name))  
  old_omvalGlobal<-omvalGlobal
  rm(omvalGlobal)
}
