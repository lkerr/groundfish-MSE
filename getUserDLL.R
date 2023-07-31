getUserDLL <- function(){
  dlls <- getLoadedDLLs()
  isTMBdll <- function(dll)!is(try(getNativeSymbolInfo("MakeADFunObject",dll),TRUE),"try-error")
  TMBdll <- sapply(dlls, isTMBdll)
  if(mproc[m,ASSESCLASS]=="WHAM"){
    "wham"
  } else if(sum(TMBdll) == 0){ stop("There are no TMB models loaded (use 'dyn.load').")
    } else  if(sum(TMBdll) >1 ){ stop("Multiple TMB models loaded. Failed to guess DLL name.")
    } else {names(dlls[TMBdll])}
  
}