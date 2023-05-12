reptoRlist = function(fn){
 options(warn=-1)
 ifile=scan(fn,what="character",flush=T,blank.lines.skip=F,quiet=T)
 idx=sapply(as.double(ifile),is.na)
 vnam=ifile[idx] 
 nv=length(vnam) 
 A=list()
 ir=0
 for(i in 1:nv){
  ir=match(vnam[i],ifile)
  if(i!=nv){
    irr=match(vnam[i+1],ifile)} else {irr=length(ifile)+1 
    dum=NA
  }
  if(irr-ir==2){dum=as.double(scan(fn,skip=ir,nlines=1,quiet=T,what=""))}
  if(irr-ir>2){dum=as.matrix(read.table(fn,skip=ir,nrow=irr-ir-1,fill=T))}
  if(is.numeric(dum)){A[[ vnam[i ]]]=dum}
 }
return(A)
}
