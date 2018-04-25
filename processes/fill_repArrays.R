

# Will need to include an additional dimension in these arrays for
# some kind of policy decision. Probably easiest if it is the next
# level after "r" for when you combine them all together. r will be 
# the repetitions that you spread out on the hpcc.


oacomp$sumCW[r,y2,,'val'] <- get_dwindow(sumCW, sty, y)
oacomp$sumCW[r,y2,,'caahat'] <- rep$sumCW

oacomp$paaCN[r,y2,,,'val'] <- get_dwindow(paaCN, sty, y)
oacomp$paaCN[r,y2,,,'caahat'] <- rep$paaCN

oacomp$sumIN[r,y2,,'val'] <- get_dwindow(sumIN, sty, y)
oacomp$sumIN[r,y2,,'caahat'] <- rep$sumIN

oacomp$paaIN[r,y2,,,'val'] <- get_dwindow(paaIN, sty, y)
oacomp$paaIN[r,y2,,,'caahat'] <- rep$paaIN

oacomp$effort[r,y2,,'val'] <- get_dwindow(effort, sty, y)
oacomp$effort[r,y2,,'caahat'] <- -99

oacomp$laa[r,y2,,,'val'] <- get_dwindow(laa, sty, y)
oacomp$laa[r,y2,,,'caahat'] <- rep$laa

oacomp$waa[r,y2,,,'val'] <- get_dwindow(waa, sty, y)
oacomp$waa[r,y2,,,'caahat'] <- rep$waa

oacomp$oe_paaCN[r,y2,'val'] <- oe_paaCN
oacomp$oe_paaCN[r,y2,'caahat'] <- rep$oe_paaCN

oacomp$oe_paaIN[r,y2,'val'] <- oe_paaIN
oacomp$oe_paaIN[r,y2,'caahat'] <- rep$oe_paaIN

oacomp$M[r,y2,,,'val'] <- matrix(data=M, nrow=ncaayear, ncol=nage)
oacomp$M[r,y2,,,'caahat'] <- rep$M

oacomp$R_dev[r,y2,,'val'] <- R_dev
oacomp$R_dev[r,y2,,'caahat'] <- rep$R_dev

oacomp$log_ipop_mean[r,y2,'val'] <- log_ipop_mean
oacomp$log_ipop_mean[r,y2,'caahat'] <- rep$log_ipop_mean

oacomp$ipop_dev[r,y2,,'val'] <- ipop_dev
oacomp$ipop_dev[r,y2,,'caahat'] <- rep$ipop_dev

oacomp$oe_sumCW[r,y2,'val'] <- oe_sumCW
oacomp$oe_sumCW[r,y2,'caahat'] <- rep$oe_sumCW

oacomp$oe_sumIN[r,y2,'val'] <- oe_sumIN
oacomp$oe_sumIN[r,y2,'caahat'] <- rep$oe_sumIN

oacomp$pe_R[r,y2,'val'] <- pe_R
oacomp$pe_R[r,y2,'caahat'] <- pe_R

oacomp$selC[r,y2,,'val'] <- selC
oacomp$selC[r,y2,,'caahat'] <- rep$selC

oacomp$qC[r,y2,'val'] <- qC
oacomp$qC[r,y2,'caahat'] <- rep$qC

oacomp$qI[r,y2,'val'] <- qI
oacomp$qI[r,y2,'caahat'] <- rep$qI

oacomp$selI[r,y2,,'val'] <- -99
oacomp$selI[r,y2,,'caahat'] <- -99

oacomp$slxC[r,y2,,,'val'] <- get_dwindow(slxC, sty, y)
oacomp$slxC[r,y2,,,'caahat'] <- rep$slxC

oacomp$F_full[r,y2,,'val'] <- get_dwindow(F_full, sty, y)
oacomp$F_full[r,y2,,'caahat'] <- rep$F_full

oacomp$F[r,y2,,,'val'] <- t(sapply(1:ncaayear, function(i){
                                 slxC[i,] * get_dwindow(F_full, sty, y)[i]
                            }))
oacomp$F[r,y2,,,'caahat'] <- rep$F

oacomp$Z[r,y2,,,'val'] <- get_dwindow(Z, sty, y)
oacomp$Z[r,y2,,,'caahat'] <- rep$Z

oacomp$R[r,y2,,'val'] <- get_dwindow(R, sty, y)
oacomp$R[r,y2,,'val'] <- rep$R

oacomp$J1N[r,y2,,,'val'] <- get_dwindow(J1N, sty, y)
oacomp$J1N[r,y2,,,'caahat'] <- rep$J1N

oacomp$CN[r,y2,,,'val'] <- get_dwindow(CN, sty, y)
oacomp$CN[r,y2,,,'caahat'] <- rep$CN

oacomp$IN[r,y2,,,'val'] <- get_dwindow(IN, sty, y)
oacomp$IN[r,y2,,,'caahat'] <- rep$IN

oacomp$NLL[r,y2,'val'] <- -99
oacomp$NLL[r,y2,'caahat'] <- rep$NLL

oacomp$NLL_sumCW[r,y2,'val'] <- -99
oacomp$NLL_sumCW[r,y2,'caahat'] <- rep$NLL_sumCW

oacomp$NLL_sumIN[r,y2,'val'] <- -99
oacomp$NLL_sumIN[r,y2,'caahat'] <- rep$NLL_sumIN

oacomp$NLL_R_dev[r,y2,'val'] <- -99
oacomp$NLL_R_dev[r,y2,'caahat'] <- rep$NLL_R_dev

oacomp$NLL_paaCN[r,y2,'val'] <- -99
oacomp$NLL_paaCN[r,y2,'caahat'] <- rep$NLL_paaCN

oacomp$NLL_paaIN[r,y2,'val'] <- -99
oacomp$NLL_paaIN[r,y2,'caahat'] <- rep$NLL_paaIN


