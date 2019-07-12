#Setup dataset
# 20 spstock2 and 110000 vessel-days takes about 9 seconds to run.
rm(list=ls())
set.seed(2)
tds<-merge(1:20, 1:110000, by=NULL)
colnames(tds)<-c("spstock2","id")
tds<-tds[c(2,1)]

#random values from an exp(normal) to mimic a logit probability
tds$expu<-exp(rnorm(nrow(tds), mean = 0, sd = 1))

  tds<-tds%>% 
  group_by(id) %>% 
  mutate(totexpu=sum(expu))


tds$prhat<- tds$expu/tds$totexpu


#This is the output of the get_predict_etargeting
ptm<-proc.time()

#This is the working bit of code 
# within id, sort by probability, accumulate probability into a cdf
# draw from a random uniform on [0,1] and fill down by id
# pull out the first row for which the draw is less than the cdf value 
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

chosen<-tds[tds$draw<tds$csum,]

#This takes a while
  chosen <-
    chosen %>% 
    group_by(id) %>% 
    filter(row_number()==1)

chosen<-chosen[c(1,2)]

ptm2<-proc.time()
ptm2-ptm
# draw from a uniform [0,1] and have the same 