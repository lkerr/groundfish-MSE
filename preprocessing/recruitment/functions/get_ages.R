


## Function for getting a vector of ages from a vector of lengths
## Note that if you choose to return a vector rather than a table
## of numbers you get a vector of ages the same size as the input
## lengths you gave. Despite this remember that these are not really
## corresponding ages / lengths at all so you shouldn't consider that
## a relationship.  The point of returning a vector is just so that
## you get a return of the same dimensionality.

# alk: age length key created by get_alk()
# 
# lengths: vector of new lengths that need corresponding ages
# 
# vector: toggle for vector output. If TRUE a vector of ages is
#         created that matches the length of the input vector.


get_ages <- function(alk, # key from get_alk
                     lengths, # new lengths needing ages
                     vector=FALSE # toggle for vector output
                     ){

      # classify the lengths into size groups
    lcat <- cut(lengths, breaks=alk$lbin, labels=alk$midpts)
    ltab <- table(lcat)

    # get estimated age composition using the alk
    newLtab <- round(alk$alk %*% ltab)
    # produce a vector of ages
    newL <- unlist(mapply(rep, x=alk$ages, each=newLtab[,1]))

  if(vector){
    ret <- newL
  }else{
    ret <- newLtab[,1]
  }
  
  return(ret)
  
}

