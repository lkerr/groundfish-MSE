# A function to select the choice with the higest prob from a datsetset of id-choice occasions. 
# Input: a dataframe that contains N observations and J choices, 
# An id number (id) and a probability (prhat) of selection. For each id, the sum of prhat=1  
# This might be faster by ordering on id, prhat then using a data.table solution to keep just the first observation. 
get_best_trip <- function(tds){
  
   tds <- tds %>% 
     group_by(id) %>%
     filter(prhat == max(prhat)) 
  
    return(tds)
}

