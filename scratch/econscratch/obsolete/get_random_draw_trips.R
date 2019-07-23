# A function to randomly select a choice from a datsetset of id-choice occasions. 
# Input: a dataframe that contains N observations and J choices, 
# An id number (id) and a probability (prhat) of selection. For each id, the sum of prhat=1  
# Draw a runiform on 0-1 for each id and select the choice with the corresponding value. 

get_random_draw_trips <- function(tds){
  
  tds<-tds[order(tds$id,tds$prhat),]
  
  #This takes a while
  tds<-tds%>% 
    group_by(id) %>% 
    mutate(csum = cumsum(prhat))
  
  tds$draw<-runif(nrow(tds), min = 0, max = 1)
  
  #This takes a while
  tds<-tds%>%
    group_by(id) %>%
    mutate(draw = first(draw))
  
  tds<-tds[tds$draw<tds$csum,]
  
  #This takes a while
  tds <-
    tds %>% 
    group_by(id) %>% 
    filter(row_number()==1)
  
    return(tds)
}

