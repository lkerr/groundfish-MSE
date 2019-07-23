# A function to randomly select a choice from a datsetset of id-choice occasions. 
# Input: a data.table that contains N observations and J choices, 
# An id number (id) and a probability (prhat) of selection. For each id, the sum of prhat=1  
# Draw a runiform on 0-1 for each id and select the choice with the corresponding value. 

# Turns out that the first line takes a LONG ASS time. So, not a good idea compared to the Data.Table solution


get_random_draw_tripsmatrix <- function(tds){
  
  #Convert the first part 
  #tds<-tds%>% 
  #  group_by(id) %>% 
  #  mutate(csum = cumsum(prhat))
  
  tds[,"csum"]<-ave(tds[,"prhat"],tds["ID"],FUN=cumsum)
  
  
  #tds[, csum := cumsum(prhat), by = id]
  
  tds$draw<-runif(nrow(tds), min = 0, max = 1)
  
  #This takes a while
  tds<-tds%>%
    group_by(id) %>%
    mutate(draw = first(draw))
  
  tds<-tds[tds$draw<tds$csum,]
  
  #This takes a while
  # tds <-
  #   tds %>% 
  #   group_by(id) %>% 
  #   filter(row_number()==1)
  tds[tds[, .I[1], by = id]$V1]
    return(tds)
}

