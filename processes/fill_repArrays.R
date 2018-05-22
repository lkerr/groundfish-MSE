

# For simplicity, have one list (oacomp) that goes through comparing
# the assessment model results with the true values and then have
# another object that will just hold the values themselves.  Makes
# things easier for analysis of results


oacomp$sumCW[r,m,y2,,'val'] <- get_dwindow(sumCW, sty, y)
oacomp$sumCW[r,m,y2,,'caahat'] <- rep$sumCW

oacomp$paaCN[r,m,y2,,,'val'] <- get_dwindow(paaCN, sty, y)
oacomp$paaCN[r,m,y2,,,'caahat'] <- rep$paaCN

oacomp$sumIN[r,m,y2,,'val'] <- get_dwindow(sumIN, sty, y)
oacomp$sumIN[r,m,y2,,'caahat'] <- rep$sumIN

oacomp$paaIN[r,m,y2,,,'val'] <- get_dwindow(paaIN, sty, y)
oacomp$paaIN[r,m,y2,,,'caahat'] <- rep$paaIN

# oacomp$effort[r,m,y2,,'val'] <- get_dwindow(effort, sty, y)
# oacomp$effort[r,m,y2,,'caahat'] <- -99
# 
# oacomp$laa[r,m,y2,,,'val'] <- get_dwindow(laa, sty, y)
# oacomp$laa[r,m,y2,,,'caahat'] <- rep$laa
# 
# oacomp$waa[r,m,y2,,,'val'] <- get_dwindow(waa, sty, y)
# oacomp$waa[r,m,y2,,,'caahat'] <- rep$waa
# 
# oacomp$oe_paaCN[r,m,y2,'val'] <- oe_paaCN
# oacomp$oe_paaCN[r,m,y2,'caahat'] <- rep$oe_paaCN
# 
# oacomp$oe_paaIN[r,m,y2,'val'] <- oe_paaIN
# oacomp$oe_paaIN[r,m,y2,'caahat'] <- rep$oe_paaIN
# 
# oacomp$M[r,m,y2,,,'val'] <- matrix(data=M, nrow=ncaayear, ncol=nage)
# oacomp$M[r,m,y2,,,'caahat'] <- rep$M
# 
# oacomp$R_dev[r,m,y2,,'val'] <- R_dev
# oacomp$R_dev[r,m,y2,,'caahat'] <- rep$R_dev
# 
# oacomp$log_ipop_mean[r,m,y2,'val'] <- log_ipop_mean
# oacomp$log_ipop_mean[r,m,y2,'caahat'] <- rep$log_ipop_mean
# 
# oacomp$ipop_dev[r,m,y2,,'val'] <- ipop_dev
# oacomp$ipop_dev[r,m,y2,,'caahat'] <- rep$ipop_dev
# 
# oacomp$oe_sumCW[r,m,y2,'val'] <- oe_sumCW
# oacomp$oe_sumCW[r,m,y2,'caahat'] <- rep$oe_sumCW
# 
# oacomp$oe_sumIN[r,m,y2,'val'] <- oe_sumIN
# oacomp$oe_sumIN[r,m,y2,'caahat'] <- rep$oe_sumIN
# 
# oacomp$pe_R[r,m,y2,'val'] <- pe_R
# oacomp$pe_R[r,m,y2,'caahat'] <- pe_R
# 
# oacomp$selC[r,m,y2,,'val'] <- selC
# oacomp$selC[r,m,y2,,'caahat'] <- rep$selC

oacomp$qC[r,m,y2,'val'] <- qC
oacomp$qC[r,m,y2,'caahat'] <- rep$qC

# oacomp$qI[r,m,y2,'val'] <- qI
# oacomp$qI[r,m,y2,'caahat'] <- rep$qI
# 
# oacomp$selI[r,m,y2,,'val'] <- -99
# oacomp$selI[r,m,y2,,'caahat'] <- -99

oacomp$slxC[r,m,y2,,,'val'] <- get_dwindow(slxC, sty, y)
oacomp$slxC[r,m,y2,,,'caahat'] <- rep$slxC

oacomp$F_full[r,m,y2,,'val'] <- get_dwindow(F_full, sty, y)
oacomp$F_full[r,m,y2,,'caahat'] <- rep$F_full

oacomp$F[r,m,y2,,,'val'] <- t(sapply(1:ncaayear, function(i){
                                 slxC[i,] * get_dwindow(F_full, sty, y)[i]
                            }))
oacomp$F[r,m,y2,,,'caahat'] <- rep$F

# oacomp$Z[r,m,y2,,,'val'] <- get_dwindow(Z, sty, y)
# oacomp$Z[r,m,y2,,,'caahat'] <- rep$Z

oacomp$R[r,m,y2,,'val'] <- get_dwindow(R, sty, y)
oacomp$R[r,m,y2,,'val'] <- rep$R

# oacomp$J1N[r,m,y2,,,'val'] <- get_dwindow(J1N, sty, y)
# oacomp$J1N[r,m,y2,,,'caahat'] <- rep$J1N
# 
# oacomp$CN[r,m,y2,,,'val'] <- get_dwindow(CN, sty, y)
# oacomp$CN[r,m,y2,,,'caahat'] <- rep$CN

# estimated SSB
SSBaa <- rep$J1N * get_dwindow(waa, sty, y) * get_dwindow(mat, sty, y)
SSBhat <- apply(SSBaa, 1, sum)
oacomp$SSB[r,m,y2,,'val'] <- get_dwindow(SSB, sty, y)
oacomp$SSB[r,m,y2,,'caahat'] <- SSBhat

# oacomp$IN[r,m,y2,,,'val'] <- get_dwindow(IN, sty, y)
# oacomp$IN[r,m,y2,,,'caahat'] <- rep$IN
# 
# oacomp$NLL[r,m,y2,'val'] <- -99
# oacomp$NLL[r,m,y2,'caahat'] <- rep$NLL
# 
# oacomp$NLL_sumCW[r,m,y2,'val'] <- -99
# oacomp$NLL_sumCW[r,m,y2,'caahat'] <- rep$NLL_sumCW
# 
# oacomp$NLL_sumIN[r,m,y2,'val'] <- -99
# oacomp$NLL_sumIN[r,m,y2,'caahat'] <- rep$NLL_sumIN
# 
# oacomp$NLL_R_dev[r,m,y2,'val'] <- -99
# oacomp$NLL_R_dev[r,m,y2,'caahat'] <- rep$NLL_R_dev
# 
# oacomp$NLL_paaCN[r,m,y2,'val'] <- -99
# oacomp$NLL_paaCN[r,m,y2,'caahat'] <- rep$NLL_paaCN
# 
# oacomp$NLL_paaIN[r,m,y2,'val'] <- -99
# oacomp$NLL_paaIN[r,m,y2,'caahat'] <- rep$NLL_paaIN



## Here start filling the simpler arrays with just the OM values

omval$SSB[r,m,y2,,] <- get_dwindow(SSB, sty, y)
omval$R[r,m,y2,,] <- get_dwindow(R, sty, y)
omval$F_full[r,m,y2,,] <- get_dwindow(F_full, sty, y)
giniCN <- apply(get_dwindow(paaCN, sty, y), 1, get_gini)
omval$ginipaaCN[r,m,y2,,] <- giniCN
giniIN <- apply(get_dwindow(paaIN, sty, y), 1, get_gini)
omval$ginipaaIN[r,m,y2,,] <- giniIN

