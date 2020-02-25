DF = data.frame(x=rep(c("b","a","c"),each=3), y=c(1,3,6), v=1:9)
DT = data.table(x=rep(c("b","a","c"),each=3), y=c(1,3,6), v=1:9)
X = data.table(x=c("c","b","d"), v=9:7, foo=c(4,2,0))

## Data.Table calls this a right join.  
 # Resultant table only has rows that match. DT rows with x=a are dropped
# the equivalent stata syntax is to:
# use DT
# merge m:1 x using X, keep(2 3)

DTR<-DT[X, on="x"]


## Data.Table calls this a left join.  
# Resultant table only has rows that match. DT rows with x=a stay, but the cols which are not in X (x=a) are NA.
DTL<-X[DT, on="x"]
# the equivalent stata syntax is to:
# use DT
# merge m:1 x using X, keep(2 3)

## Data.Table calls this an inner join
# Resultant table only has rows that match. DT rows with x=a stay, but the cols which are not in X (x=a) are NA.

# use DT
# merge m:1 x using X, keep(3)
DTN<-X[DT, on="x", nomatch=NULL]

