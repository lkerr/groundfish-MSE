use "$inputdir/$datafilename" if gffishingyear==2011, clear
keep spstock2
dups, drop terse
drop _expand

save "$outdir/stocks_in_choiceset.dta", replace
