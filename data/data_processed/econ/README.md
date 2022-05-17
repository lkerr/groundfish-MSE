This folder will hold processed economic data.  

raw and processed economic data SHOULD NOT be uploaded to github. 

``annual_sector_catch_limits.csv`` contains the total ACL and sector ACL for 2010-2017.  It also contains a 0/1 indicator for whether the stock is an allocated groundfish (mults_allocated), a non-allocated groundfish (mults_nonalloc), or a non-groundfish stock (non-mult). Finally, it contains a stockarea column.  Stock areas are all capitals, no punctuation. Unit stocks are "Unit".

``catch_limits_2010_2017.csv`` contains the sum of totalACL_mt over the 2010-2017 time periods (not an average). It also contains the fractions of the ACL that are allocated to the recreational fishery (rec_fraction) and the other fisheries (nonsector_nonrec_fraction). This will be useful if you need to make an assumption about mortality from the non-sector fleets. 

``catch_limits_2017.csv`` contains only the 2017 line from ``annual_sector_catch_limits.csv``. Probably should not use this.
