#This takes care of within-year counters and indexing. These are needed/useful for the economic model.
withinYearAdmin<-function(y,yearitercounter){
yearitercounter<-yearitercounter+1

chunk_flag<-yearitercounter %% savechunksize

cat('finishwithinYearAdmin')
}
