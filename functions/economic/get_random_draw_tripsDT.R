# A function to randomly select a choice from a datsetset of id-choice occasions. 
# Input: a data.table that contains N observations and J choices, 
# An id number (id) and a probability (prhat) of selection. For each id, the sum of prhat=1  
# Draw a runiform on 0-1 for each id and select the choice with the corresponding value. 




get_random_draw_tripsDT <- function(tds){
  #not needed, data comes in sorted on id and we dont' need to sort on prhat
  #tds<-tdsDT[order(tdsDT$id,tdsDT$prhat),]
  
   tds<-tds[, csum := cumsum(prhat), by = id]
    
    #make one draw per id, then replicate it nchoices time and place it into tds$draw
   tdss<-unique(tdsDT[,c("id","nchoices")])
   td<-runif(nrow(tdss), min = 0, max = 1)
   tds$draw<-rep(td,tdss$nchoices)

    #Foreach id, keep the row for which draw is the smallest value that is greater than csum
    
    tds<-tds[tds$draw<tds$csum,]
    tds<-tds[tds[, .I[1], by = id]$V1] 

    return(tds)
}

