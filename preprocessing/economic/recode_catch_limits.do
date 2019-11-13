version 15.1
clear

import delimited "$bio_data/$catch_hist_file"

foreach var of varlist commercial sector smallmesh commonpool herringfishery recreational scallopfishery statewater other{
replace `var'="0" if strmatch(`var',"NA")
}
destring, replace

keep if inlist(data_type,"Catch","ACL")
replace stock=lower(stock)
gen str30 spstock2=""

replace spstock2="WinterFlounderGOM" if strmatch(stock,"gom winter flounder")
replace spstock2="WinterFlounderGB" if strmatch(stock,"gb winter flounder")
replace spstock2="WinterFlounderSNEMA" if strmatch(stock,"sne/ma winter flounder")
replace spstock2="WinterFlounderSNEMA" if strmatch(stock,"sne/ma winter flounder*")
replace spstock2="WinterFlounderSNEMA" if strmatch(stock,"sne winter flounder")



replace spstock2="HaddockGB" if strmatch(stock,"gb haddock")
replace spstock2="HaddockGOM" if strmatch(stock,"gom haddock")
replace spstock2="CodGB" if strmatch(stock,"gb cod")
replace spstock2="CodGOM" if strmatch(stock,"gom cod")
replace spstock2="YellowtailFlounderCCGOM" if strmatch(stock,"cc/gom yellowtail flounder")
replace spstock2="YellowtailFlounderGB" if strmatch(stock,"gb yellowtail flounder")
replace spstock2="YellowtailFlounderSNEMA" if strmatch(stock,"sne/ma yellowtail flounder")
replace spstock2="YellowtailFlounderSNEMA" if strmatch(stock,"sne yellowtail flounder")
replace spstock2="Pollock" if strmatch(stock,"pollock")
replace spstock2="Redfish" if strmatch(stock,"redfish")
replace spstock2="AmericanPlaiceFlounder" if strmatch(stock,"plaice")
replace spstock2="WhiteHake" if strmatch(stock,"white hake")
replace spstock2="Halibut" if strmatch(stock,"halibut")

replace spstock2="WindowpaneN" if strmatch(stock,"northern windowpane")
replace spstock2="WindowpaneS" if strmatch(stock,"southern windowpane")
replace spstock2="Wolffish" if strmatch(stock,"wolffish")
replace spstock2="OceanPout" if strmatch(stock,"ocean pout")
replace spstock2="WitchFlounder" if strmatch(stock,"witch flounder")

replace total=6700 if year==2012 & spstock2=="CodGOM" & data_type=="ACL"
/*
RedSilverOffshoreHake
Other
SummerFlounder
Monkfish
SquidMackerelButterfishHerring
SeaScallop
Skates
SpinyDogfish

*/



collapse (sum) total commercial sector commonpool recreational herringfishery scallopfishery statewater other smallmesh, by(spstock2 data_type)
gen nsnr= commonpool+ herringfishery+ statewater+ scallopfishery+ other+ smallmesh
drop commonpool herringfishery scallopfishery statewater other smallmesh commercial
reshape wide total sector nsnr recreational, i( spstock2) j(data_type) string

gen nsnr_util=nsnrC/totalACL
gen nsnr_CA=nsnrC/nsnrA
gen rec_frac=0
/*See the last full paragraph of page 18359 of the  Framework 44 federal register.  75 FR 68 page 18356-18375 .*/
replace rec_frac=.337 if spstock2=="CodGOM"
replace rec_frac=.275 if spstock2=="HaddockGOM"
gen ns_frac=rec_frac+nsnr_util

gen sector_frac=1-ns_frac
/* This matches pretty well
gen sectorCL=sector_frac*sectorACL
*/
order *ACL, after(spstock2)
keep spstock2 totalACL sector_frac nsnr_util rec_frac



replace spstock2=lower(spstock2)
replace spstock2=subinstr(spstock2,"ccgom","CCGOM",.)
replace spstock2=subinstr(spstock2,"snema","SNEMA",.)
replace spstock2=subinstr(spstock2,"gom","GOM",.)

replace spstock2=subinstr(spstock2,"gb","GB",.)








merge 1:1 spstock2 using "$outdir/stocks_in_choiceset.dta"
drop _merge
rename totalACL totalACL_mt
sort spstock2
replace sector_frac=1 if sector_frac==.
replace nsnr=0 if nsnr==.
replace rec_frac=0 if rec_frac==.
rename nsnr_util nonsector_nonrec_fraction
rename rec_frac rec_fraction


gen mults_allocated=inlist(spstock2,"americanplaiceflounder","codGB","codGOM","haddockGB","haddockGOM","pollock","redfish","whitehake")
replace mults_allocated=1 if inlist(spstock2,`"winterflounderGB"', `"yellowtailflounderCCGOM"',`"yellowtailflounderGB"',`"yellowtailflounderSNEMA"',`"winterflounderGOM"',`"winterflounderSNEMA"',`"witchflounder"')
gen mults_nonalloc=inlist(spstock2,`"windowpanen"',`"windowpanes"',`"wolffish"',`"halibut"',`"oceanpout"')
gen non_mult=inlist(spstock2, `"americanLobster"',`"monkfish"',`"other"',`"redsilveroffshorehake"',`"seascallop"',`"skates"',`"spinydogfish"',`"squidmackerelbutterfishherring"',`"summerflounder"')
gen stockarea="Unit"
replace stockarea="GB" if inlist(spstock2,"codGB", "haddockGB", "winterflounderGB", "yellowtailflounderGB")
replace stockarea="GOM" if inlist(spstock2,"codGOM", "haddockGOM", "winterflounderGOM")
replace stockarea="SNEMA" if inlist(spstock2, "winterflounderSNEMA", "yellowtailflounderSNEMA")

replace stockarea="CCGOM" if inlist(spstock2,"yellowtailflounderCCGOM")


export delimited using "$outdir/catch_limits_2010_2017.csv", replace
clear

import delimited "$bio_data/$catch_hist_file"



foreach var of varlist commercial sector smallmesh commonpool herringfishery recreational scallopfishery statewater other{
replace `var'="0" if strmatch(`var',"NA")
}
destring, replace

keep if inlist(data_type,"Catch","ACL")
replace stock=lower(stock)
gen str30 spstock2=""

replace spstock2="WinterFlounderGOM" if strmatch(stock,"gom winter flounder")
replace spstock2="WinterFlounderGB" if strmatch(stock,"gb winter flounder")
replace spstock2="WinterFlounderSNEMA" if strmatch(stock,"sne/ma winter flounder")
replace spstock2="WinterFlounderSNEMA" if strmatch(stock,"sne/ma winter flounder*")
replace spstock2="WinterFlounderSNEMA" if strmatch(stock,"sne winter flounder")



replace spstock2="HaddockGB" if strmatch(stock,"gb haddock")
replace spstock2="HaddockGOM" if strmatch(stock,"gom haddock")
replace spstock2="CodGB" if strmatch(stock,"gb cod")
replace spstock2="CodGOM" if strmatch(stock,"gom cod")
replace spstock2="YellowtailFlounderCCGOM" if strmatch(stock,"cc/gom yellowtail flounder")
replace spstock2="YellowtailFlounderGB" if strmatch(stock,"gb yellowtail flounder")
replace spstock2="YellowtailFlounderSNEMA" if strmatch(stock,"sne/ma yellowtail flounder")
replace spstock2="YellowtailFlounderSNEMA" if strmatch(stock,"sne yellowtail flounder")
replace spstock2="Pollock" if strmatch(stock,"pollock")
replace spstock2="Redfish" if strmatch(stock,"redfish")
replace spstock2="AmericanPlaiceFlounder" if strmatch(stock,"plaice")
replace spstock2="WhiteHake" if strmatch(stock,"white hake")
replace spstock2="Halibut" if strmatch(stock,"halibut")

replace spstock2="WindowpaneN" if strmatch(stock,"northern windowpane")
replace spstock2="WindowpaneS" if strmatch(stock,"southern windowpane")
replace spstock2="Wolffish" if strmatch(stock,"wolffish")
replace spstock2="OceanPout" if strmatch(stock,"ocean pout")
replace spstock2="WitchFlounder" if strmatch(stock,"witch flounder")

replace total=6700 if year==2012 & spstock2=="CodGOM" & data_type=="ACL"
/*
RedSilverOffshoreHake
Other
SummerFlounder
Monkfish
SquidMackerelButterfishHerring
SeaScallop
Skates
SpinyDogfish

*/
keep if year==2017


collapse (sum) total commercial sector commonpool recreational herringfishery scallopfishery statewater other smallmesh, by(spstock2 data_type)
gen nsnr= commonpool+ herringfishery+ statewater+ scallopfishery+ other+ smallmesh
drop commonpool herringfishery scallopfishery statewater other smallmesh commercial
reshape wide total sector nsnr recreational, i( spstock2) j(data_type) string

gen nsnr_util=nsnrC/totalACL
gen nsnr_CA=nsnrC/nsnrA
gen rec_frac=0
replace rec_frac=.337 if spstock2=="CodGOM"
replace rec_frac=.275 if spstock2=="HaddockGOM"
gen ns_frac=rec_frac+nsnr_util

gen sector_frac=1-ns_frac
/* This matches pretty well
gen sectorCL=sector_frac*sectorACL
*/
order *ACL, after(spstock2)
keep spstock2 totalACL sector_frac nsnr_util rec_frac



replace spstock2=lower(spstock2)
replace spstock2=subinstr(spstock2,"ccgom","CCGOM",.)
replace spstock2=subinstr(spstock2,"snema","SNEMA",.)
replace spstock2=subinstr(spstock2,"gom","GOM",.)

replace spstock2=subinstr(spstock2,"gb","GB",.)
merge 1:1 spstock2 using "$outdir/stocks_in_choiceset.dta"
drop _merge
rename totalACL totalACL_mt
sort spstock2
replace sector_frac=1 if sector_frac==.
replace nsnr=0 if nsnr==.
replace rec_frac=0 if rec_frac==.
rename nsnr_util nonsector_nonrec_fraction
rename rec_frac rec_fraction


gen mults_allocated=inlist(spstock2,"americanplaiceflounder","codGB","codGOM","haddockGB","haddockGOM","pollock","redfish","whitehake")
replace mults_allocated=1 if inlist(spstock2,`"winterflounderGB"', `"yellowtailflounderCCGOM"',`"yellowtailflounderGB"',`"yellowtailflounderSNEMA"',`"winterflounderGOM"',`"winterflounderSNEMA"',`"witchflounder"')
gen mults_nonalloc=inlist(spstock2,`"windowpanen"',`"windowpanes"',`"wolffish"',`"halibut"',`"oceanpout"')
gen non_mult=inlist(spstock2, `"americanLobster"',`"monkfish"',`"other"',`"redsilveroffshorehake"',`"seascallop"',`"skates"',`"spinydogfish"',`"squidmackerelbutterfishherring"',`"summerflounder"')
gen stockarea="Unit"
replace stockarea="GB" if inlist(spstock2,"codGB", "haddockGB", "winterflounderGB", "yellowtailflounderGB")
replace stockarea="GOM" if inlist(spstock2,"codGOM", "haddockGOM", "winterflounderGOM")
replace stockarea="SNEMA" if inlist(spstock2, "winterflounderSNEMA", "yellowtailflounderSNEMA")

replace stockarea="CCGOM" if inlist(spstock2,"yellowtailflounderCCGOM")
export delimited using "$outdir/catch_limits_2017.csv", replace













