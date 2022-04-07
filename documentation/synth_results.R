############################################
## read across simulation results and produce summary plots
## NE Discards simulation project
## AE Weston
## 


###### 1MP, 1 stock, different scenarios ####
### report figures are left uncommented #### 

## om time series 
# Runs 45-48; low M, no bias changepoint, moving window, slide; folder = 'OM_overlay_lowM'
# 51-54; high M, no bias changepoint, moving window, slide 'OM_oerlay_highM'
# 66-69; low M, changepoint, no window, slide 'OM_overlay_lowM_v2'
# 70-73; ramp M, changepoint, no window, 'OM_overlay_highM_v2'
# 74-77; low M, changepoint, no window, constantF 'OM_overlay_lowM_constF'
# 78-81; high M, changepoint, no window, constantF 'OM_overlay_highM_constF'
# 82-85; low M, no bias changepoint, no window, slide 'OM_overlay_lowM_noCP'
# 86-89; high M, no bias changepoint, no window, slide 'OM_overlay_highM_noCP'
# 94/95; highM/lowM no bias changepoint, no window, slide, initM/F testing 'OM_overlay_lowM_init_test/OM_overlay_highM_init_test/version2'
# 96/97; lowM/highM no bias changepoint, no window, slide, init rec testing 'OM_overlay_lowM_init_test/OM_overlay_highM_init_test/version3'
# 98/99; lowM/highM no bias changepoint, no window, slide, init Fmsyscalar(3) testing 'OM_overlay_lowM_init_test/OM_overlay_highM_init_test/version4'
# 100/101; lowM/highM no bias changepoint, no window, slide, init Fmsyscalar(4) testing 'OM_overlay_lowM_init_test/OM_overlay_highM_init_test/version5'
# 102-105; lowM, accumulating data, uniform bias, slide HCR, 'OM_lowM_AD_UB_slide'
# 106-109; highM, accumulating data, uniform bias, slide HCR, 'OM_highM_AD_UB_slide'
# 110-113; lowM, accumulating data, bias changepoint, slide HCR, 'OM_lowM_AD_CP_slide'
# 114-117; highM, accumulating data, bias changepoint, slide HCR, 'OM_highM_AD_CP_slide'
# 118-121; lowM, accumulating data, bias changepoint, constant HCR, 'OM_lowM_AD_CP_constF'
# 122-125; highM, accumulating data, bias changepoint, constant HCR, 'OM_highM_AD_CP_constF'



# read in one scenario results directory at a time and save as scenario 1/2/3/4 to 
# create single CSV with multiple bias scenarios
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 125/results/sim")

sims <- list.files()

# get SSB, rec, fishing mortality, and catch weight by stock and MP by year
SSB <- matrix(NA, ncol = length(sims), nrow = 200)
REC <- matrix(NA, ncol = length(sims), nrow = 200)
F_mort <- matrix(NA, ncol = length(sims), nrow = 200)
CW <- matrix(NA, ncol = length(sims), nrow = 200)
F_prox <- matrix(NA, ncol = length(sims), nrow = 200)
SSB_prox <- matrix(NA, ncol = length(sims), nrow = 200)

for (i in 1:length(sims)){
  load(sims[i])
  SSB[,i] <- as.numeric(omvalGlobal$codGOM$SSB[1,1,])
  REC[,i] <- as.numeric(omvalGlobal$codGOM$R[1,1,])
  F_mort[,i] <- as.numeric(omvalGlobal$codGOM$F_full[1,1,])
  CW[,i] <- as.numeric(omvalGlobal$codGOM$sumCW[1,1,])
  F_prox[,i] <- as.numeric(omvalGlobal$codGOM$FPROXY[1,1,])
  SSB_prox[,i] <- as.numeric(omvalGlobal$codGOM$SSBPROXY[1,1,])
}

f_metric <- F_mort/F_prox
b_metric <- SSB/SSB_prox

### compare SSB to no bias proxy reference set
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 122/results/sim")
sims <- list.files()
NB_prox <- matrix(NA, ncol = length(sims), nrow = 200)
for (i in 1:length(sims)){
  load(sims[i])
  NB_prox[,i] <- as.numeric(omvalGlobal$codGOM$SSBPROXY[1,1,])
}
B_prox <- SSB/NB_prox

library(matrixStats)
#mean_SSB <- rowMeans(SSB)
#mean_REC <- rowMeans(REC)
#mean_F <- rowMeans(F_mort)
#mean_CW <- rowMeans(CW)

#medians instead
mean_SSB <- rowMedians(SSB)
mean_REC <- rowMedians(REC)
mean_F <- rowMedians(F_mort)
mean_CW <- rowMedians(CW)
med_f_met <- rowMedians(f_metric)
med_b_met <- rowMedians(B_prox)
med_Fprox <- rowMedians(F_prox)
med_SSBprox <- rowMedians(SSB_prox)
med_old_b_met <- rowMedians(b_metric)


scen1SSB <- mean_SSB
scen1REC <- mean_REC
scen1F <- mean_F
scen1C <- mean_CW
scen1Fmet <- med_f_met
scen1Bmet <- med_b_met
scen1Fpx <- med_Fprox
scen1SSBpx <- med_SSBprox
scen1OBmet <- med_old_b_met

scen2SSB <- mean_SSB
scen2REC <- mean_REC
scen2F <- mean_F
scen2C <- mean_CW
scen2Fmet <- med_f_met
scen2Bmet <- med_b_met
scen2Fpx <- med_Fprox
scen2SSBpx <- med_SSBprox
scen2OBmet <- med_old_b_met


scen3SSB <- mean_SSB
scen3REC <- mean_REC
scen3F <- mean_F
scen3C <- mean_CW
scen3Fmet <- med_f_met
scen3Bmet <- med_b_met
scen3Fpx <- med_Fprox
scen3SSBpx <- med_SSBprox
scen3OBmet <- med_old_b_met


scen4SSB <- mean_SSB
scen4REC <- mean_REC
scen4F <- mean_F
scen4C <- mean_CW
scen4Fmet <- med_f_met
scen4Bmet <- med_b_met
scen4Fpx <- med_Fprox
scen4SSBpx <- med_SSBprox
scen4OBmet <- med_old_b_met

all_mean_SSB <- cbind(scen1SSB, scen2SSB, scen3SSB, scen4SSB)
all_mean_rec <- cbind(scen1REC, scen2REC, scen3REC, scen4REC)
all_mean_F <- cbind(scen1F, scen2F, scen3F, scen4F)
all_mean_CW <- cbind(scen1C, scen2C, scen3C, scen4C)
all_med_f_metric <- cbind(scen1Fmet, scen2Fmet, scen3Fmet, scen4Fmet)
all_med_b_metric <- cbind(scen1Bmet, scen2Bmet, scen3Bmet, scen4Bmet)
all_med_F_prox <- cbind(scen1Fpx, scen2Fpx, scen3Fpx, scen4Fpx)
all_med_B_prox <- cbind(scen1SSBpx, scen2SSBpx, scen3SSBpx, scen4SSBpx)
all_med_OB_metric <- cbind(scen1OBmet, scen2OBmet, scen3OBmet, scen4OBmet)


# save results
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")

#write.csv(all_mean_SSB, "mean_SSB.csv")
#write.csv(all_mean_rec, "mean_rec.csv")
#write.csv(all_mean_F, "mean_F.csv")
#write.csv(all_mean_CW, "mean_cw.csv")

write.csv(all_mean_SSB, "med_SSB.csv")
write.csv(all_mean_rec, "med_rec.csv")
write.csv(all_mean_F, "med_F.csv")
write.csv(all_mean_CW, "med_cw.csv")
write.csv(all_med_f_metric, "med_Fmetric.csv")
write.csv(all_med_b_metric, "med_Bmetric.csv")
write.csv(all_med_F_prox, "med_Fproxy.csv")
write.csv(all_med_B_prox, "med_SSBproxy.csv")
write.csv(all_med_OB_metric, "med_oldBmetric.csv")


###### plot different scenarios as different colors
# tiff("OM_series_proj.tiff", width = 5, height = 4, units = 'in', res = 300)
# par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
# layout(matrix(c(1,2,3,4), ncol = 2, byrow = TRUE))
# #layout.show(4)
# # Median spawning stock biomass
# all_mean_SSB <- read.csv('med_SSB.csv')
# yrs <- as.character(seq(1982, 2050))
# #tiff("Med_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(all_mean_SSB[169:200,1], ylim = c(0, 45000), type = 'l', lwd = 2, ylab = "SSB (mt)", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = "gray50")
# #axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
# legend(-2.5, 46500, legend = c("A"), bty = 'n')
# lines(all_mean_SSB[169:200,2], type = 'l', lwd = 2, col = "goldenrod2")#lty = 6)
# lines(all_mean_SSB[169:200,3], type = 'l', lwd = 2, col = "skyblue3") #lty = 5)
# lines(all_mean_SSB[169:200,4], type = 'l', lwd = 2, col = "dodgerblue4")#lty = 3)
# #abline(v = 37, lty = 2)
# #legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# #dev.off()
# 
# # Median recruitment
# options(scipen = 0)
# all_mean_rec <- read.csv('med_rec.csv')
# yrs <- as.character(seq(1982, 2050))
# #tiff("Med_rec.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(all_mean_rec[169:200,1],  type = 'l', lwd = 2, ylab = "Recruitment", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = 'gray50', ylim = c(0, 12000000))
# #axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
# legend(-2.5, 12000000, legend = c("B"), bty = 'n')
# lines(all_mean_rec[169:200,2], type = 'l', lwd = 2, col = 'goldenrod2')#lty = 6)
# lines(all_mean_rec[169:200,3], type = 'l', lwd = 2, col = 'skyblue3')#lty = 5)
# lines(all_mean_rec[169:200,4], type = 'l', lwd = 2, col = 'dodgerblue4')#lty = 3)
# #abline(v = 37, lty = 2)
# legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# #dev.off()
# 
# # Median Fishing mortality
# all_mean_F <- read.csv('med_F.csv')
# yrs <- as.character(seq(1982, 2050))
# #tiff("Med_Fmort.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(all_mean_F[169:200,1],  type = 'l', lwd = 2, ylab = "Fishing Mortality", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = 'gray50', ylim = c(0, 1.5))
# #axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
# legend(-2.5, 1.5, legend = c("C"), bty = 'n')
# lines(all_mean_F[169:200,2], type = 'l', lwd = 2, col = 'goldenrod2')#lty = 6)
# lines(all_mean_F[169:200,3], type = 'l', lwd = 2, col = 'skyblue3')#lty = 5)
# lines(all_mean_F[169:200,4], type = 'l', lwd = 2, col = 'dodgerblue4')#lty = 3)
# #abline(v = 37, lty = 2)
# #legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# #dev.off()
# 
# # Median catch weight
# all_mean_cw <- read.csv('med_cw.csv')
# yrs <- as.character(seq(1982, 2050))
# #tiff("Med_cw.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(all_mean_cw[169:200,1], type = 'l', lwd = 2, ylab = "Catch (mt)", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = 'gray50', ylim = c(0, 5000))
# #axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
# legend(-2.5, 5000, legend = c("D"), bty = 'n')
# lines(all_mean_cw[169:200,2], type = 'l', lwd = 2, col = 'goldenrod2')#lty = 6)
# lines(all_mean_cw[169:200,3], type = 'l', lwd = 2, col = 'skyblue3')#lty = 5)
# lines(all_mean_cw[169:200,4], type = 'l', lwd = 2, col = 'dodgerblue4')#lty = 3)
# #abline(v = 37, lty = 2)
# #legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# dev.off()

###### plot different scenarios as different line types 
# report figure 1
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")
#tiff("OM_lines_highM_noCP.tiff", width = 5, height = 4, units = 'in', res = 300)
#par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
#layout(matrix(c(1,2,3,4), ncol = 2, byrow = TRUE))

tiff("OM_lines_highM_AD_CP_constF.tiff", width = 7, height = 2, units = 'in', res = 300)
par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
layout(matrix(c(1,2,3,4), ncol = 4, byrow = TRUE))
#layout.show(4)
# Median spawning stock biomass
all_mean_SSB <- read.csv('med_SSB.csv')
#yrs <- as.character(seq(1982, 2050))
yrs <- as.character(seq(1982, 2050, 10))
#tiff("Med_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
plot(all_mean_SSB[132:200,1], ylim = c(0, 45000), type = 'l', lwd = 1.5, ylab = "SSB (mt)", xlab = 'Year', cex.lab = 1, cex.axis = 1, xaxt = 'n')
#axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
axis(1, seq(1,69,10),labels = yrs, cex.axis = 1)
#legend(-2.5, 46500, legend = c("M"), bty = 'n')
lines(all_mean_SSB[132:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_SSB[132:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_SSB[132:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
#legend('topright', legend = c("No bias", "50%", "125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
#dev.off()

# Median recruitment
options(scipen = 0)
all_mean_rec <- read.csv('med_rec.csv')
#tiff("Med_rec.tiff", width = 5, height = 4, units = 'in', res = 300)
plot(all_mean_rec[132:200,1],  type = 'l', lwd = 1.5, ylab = "Recruitment", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 33000000), xaxt = 'n')
#axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
axis(1, seq(1,69,10),labels = yrs, cex.axis = 1)
#legend(-2.5, 34000000, legend = c("N"), bty = 'n')
lines(all_mean_rec[132:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_rec[132:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_rec[132:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
#legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
#dev.off()

# Median Fishing mortality
all_mean_F <- read.csv('med_F.csv')
#tiff("Med_Fmort.tiff", width = 5, height = 4, units = 'in', res = 300)
plot(all_mean_F[132:200,1],  type = 'l', lwd = 1.5, ylab = "Fishing Mortality", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 2.3), xaxt = 'n')
#axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
axis(1, seq(1,69,10),labels = yrs, cex.axis = 1)
#legend(-2.5, 2.4, legend = c("O"), bty = 'n')
lines(all_mean_F[132:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_F[132:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_F[132:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
#legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
#dev.off()

# Median catch weight
all_mean_cw <- read.csv('med_cw.csv')
#tiff("Med_cw.tiff", width = 5, height = 4, units = 'in', res = 300)
plot(all_mean_cw[132:200,1], type = 'l', lwd = 1.5, ylab = "Catch (mt)", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 20000), xaxt = 'n')
#axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
axis(1, seq(1,69,10),labels = yrs, cex.axis = 1)
#legend(-1.5, 21000, legend = c("P"), bty = 'n')
lines(all_mean_cw[132:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_cw[132:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_cw[132:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
legend('topright', legend = c("No bias", "50%", "125%", "200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
dev.off()


# report figure 2
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")
#tiff("OM_lines_highM_noCP.tiff", width = 5, height = 4, units = 'in', res = 300)
#par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
#layout(matrix(c(1,2,3,4), ncol = 2, byrow = TRUE))

tiff("OM_proj_highM_AD_CP_constF.tiff", width = 7, height = 2, units = 'in', res = 300)
par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
layout(matrix(c(1,2,3,4), ncol = 4, byrow = TRUE))
#layout.show(4)
# Median spawning stock biomass
all_mean_SSB <- read.csv('med_SSB.csv')
plot(all_mean_SSB[165:200,1], ylim = c(0, 45000), type = 'l', lwd = 1.5, ylab = "SSB (mt)", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1)
#legend(-2.5, 45000, legend = c("M"), bty = 'n')
lines(all_mean_SSB[165:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_SSB[165:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_SSB[165:200,4], type = 'l', lwd = 1.5, lty = 3)

# Median recruitment
options(scipen = 0)
all_mean_rec <- read.csv('med_rec.csv')
plot(all_mean_rec[165:200,1],  type = 'l', lwd = 1.5, ylab = "Recruitment", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 20000000))
#legend(-2.5, 20000000, legend = c("N"), bty = 'n')
lines(all_mean_rec[165:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_rec[165:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_rec[165:200,4], type = 'l', lwd = 1.5, lty = 3)

# Median Fishing mortality
all_mean_F <- read.csv('med_F.csv')
plot(all_mean_F[165:200,1],  type = 'l', lwd = 1.5, ylab = "Fishing Mortality", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 1.5))
#legend(-2.5, 1.5, legend = c("O"), bty = 'n')
lines(all_mean_F[165:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_F[165:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_F[165:200,4], type = 'l', lwd = 1.5, lty = 3)

# Median catch weight
all_mean_cw <- read.csv('med_cw.csv')
plot(all_mean_cw[165:200,1], type = 'l', lwd = 1.5, ylab = "Catch (mt)", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 15000))
#legend(-2.5, 15000, legend = c("P"), bty = 'n')
lines(all_mean_cw[165:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_cw[165:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_cw[165:200,4], type = 'l', lwd = 1.5, lty = 3)
legend('topright', legend = c("No bias", "50%", "125%", "200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
dev.off()


######## plot overfishing/overfished ####
# report figure 7
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_slide")
all_med_f_metric <- read.csv('med_Fmetric.csv')
tiff("OF_highM_AD_CP_slide.tiff", width = 7.5, height = 2.1, units = 'in', res = 300)
par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
layout(matrix(c(1,2,3,4), ncol = 4, byrow = TRUE))
#layout.show(2)
plot(all_med_f_metric[165:200,1], type = 'l', lwd = 1.5, ylab = "OM F/FMSY", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 5))
legend(-2.5, 5, legend = c("M"), bty = 'n')
lines(all_med_f_metric[165:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_med_f_metric[165:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_med_f_metric[165:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 1)

all_med_b_metric <- read.csv('med_Bmetric.csv')
plot(all_med_b_metric[165:200,1], type = 'l', lwd = 1.5, ylab = "OM SSB/True SSB threshold", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 5))
legend(-2.5, 5, legend = c("N"), bty = 'n')
lines(all_med_b_metric[165:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_med_b_metric[165:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_med_b_metric[165:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 1)

#all_med_OG_b_metric <- read.csv('med_oldBmetric.csv')
est_B <- read.csv('med_sa_SSB.csv')
est_B <- est_B[34:68,]
B_thresh <- read.csv('med_SSBproxy.csv')
B_thresh <- B_thresh[166:200,]
all_med_OG_b_metric <- est_B/B_thresh
plot(all_med_OG_b_metric[,1], type = 'l', lwd = 1.5, ylab = "EM SSB/Estimated SSB threshold", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 5))
legend(-2.5, 5, legend = c("O"), bty = 'n')
lines(all_med_OG_b_metric[,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_med_OG_b_metric[,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_med_OG_b_metric[,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 1)

est_F <- read.csv('med_sa_F.csv')
est_F <- est_F[34:68,]
FMSY <- read.csv('med_Fproxy.csv')
FMSY <- FMSY[166:200,]
est_F_metric <- est_F/FMSY

plot(est_F_metric[,1], type = 'l', lwd = 1.5, ylab = "Estimated F/FMSY", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 5))
legend(-2.5, 5, legend = c("P"), bty = 'n')
lines(est_F_metric[,2], type = 'l', lwd = 1.5, lty = 2)
lines(est_F_metric[,3], type = 'l', lwd = 1.5, lty = 6)
lines(est_F_metric[,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 1)
#legend('topright', legend = c("No bias", "50%", "125%", "200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
dev.off()


################ historic time period ########
## same across scenarios
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_overlay_highM_noCP")
# 
# #tiff("OM_series_hist.tiff", width = 5, height = 4, units = 'in', res = 300)
# #par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
# #layout(matrix(c(1,2,3,4), ncol = 2, byrow = TRUE))
# tiff("OM_series_hist_v2.tiff", width = 6, height = 1.5, units = 'in', res = 300)
# par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
# layout(matrix(c(1,2,3,4), ncol = 4, byrow = TRUE))
# #layout.show(4)
# # Mean spawning stock biomass/median 
# all_mean_SSB <- read.csv('med_SSB.csv')
# yrs <- as.character(seq(1982, 2014))
# plot(all_mean_SSB[132:164,1], xaxt = 'n', ylim = c(0, 50000), type = 'l', lwd = 2, ylab = "SSB (mt)", xlab = 'Year', cex.lab = 1, cex.axis = 1)
# axis(1, at = c(1:33),labels = yrs, cex.axis = 1)
# legend(-5.5, 50000, legend = c("E"), bty = 'n')
# 
# # Mean recruitment
# options(scipen = 0)
# all_mean_rec <- read.csv('med_rec.csv')
# plot(all_mean_rec[132:164,1],  xaxt = 'n', type = 'l', lwd = 2, ylab = "Recruitment", xlab = 'Year', cex.lab = 1, cex.axis = 1,  ylim = c(0, 40000000))
# axis(1, at = c(1:33),labels = yrs, cex.axis = 1)
# legend(-5.5, 40000000, legend = c("F"), bty = 'n')
# 
# # Mean Fishing mortality
# all_mean_F <- read.csv('med_F.csv')
# plot(all_mean_F[132:164,1],  xaxt = 'n', type = 'l', lwd = 2, ylab = "Fishing Mortality", xlab = 'Year', cex.lab = 1, cex.axis = 1,  ylim = c(0, 2.2))
# axis(1, at = c(1:33),labels = yrs, cex.axis = 1)
# legend(-5.5, 2.2, legend = c("G"), bty = 'n')
# 
# # Mean catch weight
# all_mean_cw <- read.csv('med_cw.csv')
# plot(all_mean_cw[132:164,1], type = 'l', xaxt = 'n', lwd = 2, ylab = "Catch (mt)", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 20000))
# axis(1, at = c(1:33),labels = yrs, cex.axis = 1)
# legend(-5.5, 20000, legend = c("H"), bty = 'n')
# dev.off()



#### Relative error plots ####
## save across scenarios 1/2/3/4 to one .csv
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 125/results/sim")
sims <- list.files()

relE_SSB <- matrix(NA, ncol = length(sims), nrow = 200)
relE_REC <- matrix(NA, ncol = length(sims), nrow = 200)
relE_F_mort <- matrix(NA, ncol = length(sims), nrow = 200)
for (i in 1:length(sims)){
  load(sims[i])
  relE_SSB[,i] <- as.numeric(omvalGlobal$codGOM$relE_SSB[1,1,])
  relE_REC[,i] <- as.numeric(omvalGlobal$codGOM$relE_R[1,1,])
  relE_F_mort[,i] <- as.numeric(omvalGlobal$codGOM$relE_F[1,1,])
}

library(matrixStats)
mean_relESSB <- rowMedians(relE_SSB)
mean_relEREC <- rowMedians(relE_REC)
mean_relEF <- rowMedians(relE_F_mort)

scen1SSB <- mean_relESSB
scen1REC <- mean_relEREC
scen1F <- mean_relEF

scen2SSB <- mean_relESSB
scen2REC <- mean_relEREC
scen2F <- mean_relEF

scen3SSB <- mean_relESSB
scen3REC <- mean_relEREC
scen3F <- mean_relEF

scen4SSB <- mean_relESSB
scen4REC <- mean_relEREC
scen4F <- mean_relEF

all_mean_SSB <- cbind(scen1SSB, scen2SSB, scen3SSB, scen4SSB)
all_mean_rec <- cbind(scen1REC, scen2REC, scen3REC, scen4REC)
all_mean_F <- cbind(scen1F, scen2F, scen3F, scen4F)

setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")
write.csv(all_mean_SSB, "med_REESSB.csv")
write.csv(all_mean_rec, "med_REEREC.csv")
write.csv(all_mean_F, "med_REEF.csv")

# tiff("REE_series.tiff", width = 6, height = 4, units = 'in', res = 300)
# par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
# layout(matrix(c(1,2,3,4,5,6), ncol = 3, byrow = TRUE))
# layout.show(6)
# SSB_REE <- read.csv('med_REESSB.csv')
# #yrs <- as.character(seq(2020, 2050))
# #tiff("Med_SSBREE.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(SSB_REE[170:200,1],  ylim = c(-100, 100), type = 'l', lwd = 2, ylab = "%REE SSB", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = 'gray50')
# #axis(1, at = c(1:31),labels = yrs, cex.axis = 1)
# legend(-2, 110, legend = c("A"), bty = 'n')
# lines(SSB_REE[170:200,2], type = 'l', lwd = 2, col = 'goldenrod2') #lty = 6)
# lines(SSB_REE[170:200,3], type = 'l', lwd = 2, col = 'skyblue3') #lty = 5)
# lines(SSB_REE[170:200,4], type = 'l', lwd = 2, col = 'dodgerblue4') #lty = 3)
# abline(h = 0)
# #legend('topleft', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# #dev.off()
# 
# rec_REE <- read.csv('med_REEREC.csv')
# #tiff("Med_RECREE.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(rec_REE[170:200,1], ylim = c(-100, 100), type = 'l', lwd = 2, ylab = "%REE Recruitment", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = 'gray50')
# #axis(1, at = c(1:31),labels = yrs, cex.axis = 1)
# legend(-2, 110, legend = c("B"), bty = 'n')
# lines(rec_REE[170:200,2], type = 'l', lwd = 2, col = 'goldenrod2')#lty = 6)
# lines(rec_REE[170:200,3], type = 'l', lwd = 2, col = 'skyblue3') #lty = 5)
# lines(rec_REE[170:200,4], type = 'l', lwd = 2, col = 'dodgerblue4')#lty = 3)
# abline(h = 0)
# #legend('topleft', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# #dev.off()
# 
# F_REE <- read.csv('med_REEF.csv')
# #tiff("Med_FREE.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(F_REE[170:200,1],  ylim = c(-100, 100), type = 'l', lwd = 2, ylab = "%REE Fishing Mortality", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1, col = 'gray50')
# #axis(1, at = c(1:31),labels = yrs, cex.axis = 1)
# legend(-2, 110, legend = c("C"), bty = 'n')
# lines(F_REE[170:200,2], type = 'l', lwd = 2, col = 'goldenrod2')#lty = 6)
# lines(F_REE[170:200,3], type = 'l', lwd = 2, col = 'skyblue3')#lty = 5)
# lines(F_REE[170:200,4], type = 'l', lwd = 2, col = 'dodgerblue4') #lty = 3)
# abline(h = 0)
# legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
# dev.off()


##### REE plots as different lines not colors
## Report figure 5
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")
tiff("REE_lines_highM_AD_CP_constF.tiff", width = 6, height = 4, units = 'in', res = 300)
par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
layout(matrix(c(1,2,3,4,5,6), ncol = 3, byrow = TRUE))
layout.show(6)
SSB_REE <- read.csv('med_REESSB.csv')
plot(SSB_REE[166:200,1],  ylim = c(-100, 100), type = 'l', lwd = 1.5, ylab = "%REE SSB", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1)
#legend(-2, 110, legend = c("J"), bty = 'n')
lines(SSB_REE[166:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(SSB_REE[166:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(SSB_REE[166:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 0)

rec_REE <- read.csv('med_REEREC.csv')
plot(rec_REE[166:200,1], ylim = c(-100, 100), type = 'l', lwd = 1.5, ylab = "%REE Recruitment", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1)
#legend(-2, 110, legend = c("K"), bty = 'n')
lines(rec_REE[166:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(rec_REE[166:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(rec_REE[166:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 0)

F_REE <- read.csv('med_REEF.csv')
plot(F_REE[166:200,1],  ylim = c(-100, 100), type = 'l', lwd = 1.5, ylab = "%REE Fishing Mortality", xlab = 'Projection Year', cex.lab = 1, cex.axis = 1)
#legend(-2, 110, legend = c("L"), bty = 'n')
lines(F_REE[166:200,2], type = 'l', lwd = 1.5, lty = 2)
lines(F_REE[166:200,3], type = 'l', lwd = 1.5, lty = 6)
lines(F_REE[166:200,4], type = 'l', lwd = 1.5, lty = 3)
abline(h = 0)
#legend('topright', legend = c("No bias", "50%", "125%", "200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
dev.off()




#### overfishing/overfished plots #####
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 26/results/sim")
# sims <- list.files()
# ofg <- matrix(NA, ncol = length(sims), nrow = 200)
# ofd <- matrix(NA, ncol = length(sims), nrow = 200)
# for (i in 1:length(sims)){
#   load(sims[i])
#   ofg[,i] <- as.numeric(omvalGlobal$codGOM$OFgStatus[1,1,])
#   ofd[,i] <- as.numeric(omvalGlobal$codGOM$OFdStatus[1,1,])
# }
# 
# ## proportion of years 
# ofg_sum <- colSums(ofg, na.rm = TRUE)
# ofd_sum <- colSums(ofd, na.rm = TRUE)
# proj_yrs <- 32
# freq_ofg <- ofg_sum/proj_yrs
# freq_ofd <- ofd_sum/proj_yrs
# med_ofg <- mean(freq_ofg) *100
# med_ofd <- mean(freq_ofd) *100


#setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Plots")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Plots_v2")
# 
# ## redo time series plots
# mean_ofd <- rowMeans(ofd)
# yrs <- as.character(seq(2019, 2050))
# tiff("Mean_ofd_scen4.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(mean_ofd[168:199], xaxt = 'n', ylim = c(0,1), pch = 16, type = 'o', lwd = 2, ylab = "Overfished Status", xlab = 'Year', cex.lab = 1, cex.axis = 1)
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()
# 
# mean_ofg <- rowMeans(ofg)
# yrs <- as.character(seq(2019, 2050))
# tiff("Mean_ofg_scen4.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(mean_ofg[168:199], xaxt = 'n', ylim = c(0,1), pch = 16, type = 'o', lwd = 2, ylab = "Overfishing Status", xlab = 'Year', cex.lab = 1, cex.axis = 1)
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()

#### redefine overfishing as Fproxy > OM F #####
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 25/results/sim")
# 
# sims <- list.files()
# OM_F <- matrix(NA, ncol = length(sims), nrow = 200)
# Fprox <- matrix(NA, ncol = length(sims), nrow = 200)
# for (i in 1:length(sims)){
#   load(sims[i])
#   OM_F[,i] <- as.numeric(omvalGlobal$codGOM$F_full[1,1,])
#   Fprox[,i] <- as.numeric(omvalGlobal$codGOM$FPROXY[1,1,])
# }
# overF <- ifelse(OM_F > Fprox, 1, 0) 
# mean_overF <- rowMeans(overF[169:200,])
# 
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Plots_v2")
# yrs <- as.character(seq(2019, 2050))
# tiff("Mean_ofg_v2_scen3.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(mean_overF, xaxt = 'n', ylim = c(0,1), pch = 16, type = 'o', lwd = 2, ylab = "Overfishing Status", xlab = 'Year', cex.lab = 1, cex.axis = 1)
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()




#### errors testing
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 20/results/sim")
# 
# sims <- list.files()
# 
# # get SSB, rec, fishing mortality, and catch weight by stock and MP by year
# SSB_err <- matrix(NA, ncol = length(sims), nrow = 200)
# for (i in 1:length(sims)){
#   load(sims[i])
#   SSB_err[,i] <- as.numeric(omvalGlobal$codGOM$relE_SSB[1,1,])
# }
# 
# 
# ## extract single year across assessment sims ####
# ## 
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 20/Across_single")
# run1 <- readRDS('codGOM_1_199_1.rdat')
# run2 <- readRDS('codGOM_1_199_2.rdat')
# run3 <- readRDS('codGOM_1_199_3.rdat')
# 
# ssb1 <- run1$SSB
# ssb2 <- run2$SSB
# ssb3 <- run3$SSB
# 
# comb_ssb <- cbind(ssb1, ssb2, ssb3)




#### overlay OM and assessment time series ####
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/ASAP_res/overlay")
OM_SSB <- read.csv('OM_SSB.csv')
EM_SSB_200 <- read.csv('em_SSB.csv')
EM_SSB_185 <- read.csv('EM_SSB_185.csv')


# read in assessment results from one iteration and add to OM time series 
# spawning stock biomass
setwd("C:/Users/aweston/Documents/GH_projs/groundfish-MSE/assessment/ASAP")
em <- readRDS('codGOM_1_200.rdat')
emssb <- em$SSB
emssb <- t(emssb)
emssb <- t(emssb) ##copy paste to master excel

totalbiomass <- em$tot.jan1.B
totalbiomass <- t(totalbiomass)
totalbiomass <- t(totalbiomass)




library("RColorBrewer")
clr <- brewer.pal(n = 8, name = 'YlGnBu')
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/ASAP_res/overlay")

tiff('SSB_window_21.tiff', width = 6, height = 5, units = 'in', res = 300)
all <- read.csv('OM_EM_SSB_21.csv', header = FALSE)
plot(all$V1, all$V2, type = 'l', lwd = 2, ylim = c(0, 52000), ylab = "Spawning Stock Biomass", xlab = 'Year')
lines(all$V1, all$V3, col = clr[3], lwd = 2)
lines(all$V1, all$V4, col = clr[4], lwd = 2)
lines(all$V1, all$V5, col = clr[5], lwd = 2)
lines(all$V1, all$V6, col = clr[6], lwd = 2)
lines(all$V1, all$V7, col = clr[7], lwd = 2)
lines(all$V1, all$V8, col = clr[8], lwd = 2)
abline(v = 163)
legend(187, y = 54000, legend = c("168", "174", "184", "190", "194", '199'),col = clr[3:8], lwd = 2, bty = 'n', cex = 0.75)
dev.off()


# recruitment
OM_rec <- read.csv("OM_rec.csv")
setwd("C:/Users/aweston/Documents/GH_projs/groundfish-MSE/assessment/ASAP")
em <- readRDS('codGOM_1_200.rdat')
emrec <- em$SR.resids$recruits
emrec <- t(emrec)
emrec <- t(emrec) ##copy paste to master excel

library("RColorBrewer")
clr <- brewer.pal(n = 8, name = 'YlOrRd')

setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/ASAP_res/overlay")
all <- read.csv('OM_EM_REC_21.csv', header = FALSE)
tiff('REC_window_21.tiff', width = 6, height = 5, units = 'in', res = 300)
plot(all$V1, all$V2, type = 'l', lwd = 2,  ylab = "Recruitment", xlab = 'Year')
lines(all$V1, all$V3, col = clr[3], lwd = 2)
lines(all$V1, all$V4, col = clr[4], lwd = 2)
lines(all$V1, all$V5, col = clr[5], lwd = 2)
lines(all$V1, all$V6, col = clr[6], lwd = 2)
lines(all$V1, all$V7, col = clr[7], lwd = 2)
lines(all$V1, all$V8, col = clr[8], lwd = 2)
abline(v = 169)
legend('topright', legend = c("168", "174", "184", "190", "194", '199'),col = clr[3:8], lwd = 2, bty = 'n', cex = 0.75)
dev.off()


# spawning stock biomass
setwd("C:/Users/aweston/Documents/GH_projs/groundfish-MSE/assessment/ASAP")
em <- readRDS('codGOM_1_200.rdat')
emf <- em$F.report
emf <- t(emf)
emf <- t(emf) ##copy paste to master excel

library("RColorBrewer")
clr <- brewer.pal(n = 8, name = 'Purples')

setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/ASAP_res/overlay")
all <- read.csv('OM_EM_F_21.csv', header = FALSE)
tiff('Fmort_window_21.tiff', width = 6, height = 5, units = 'in', res = 300)
plot(all$V1, all$V2, type = 'l', lwd = 2,  ylab = "Fishing mortality", xlab = 'Year')
lines(all$V1, all$V3, col = clr[3], lwd = 2)
lines(all$V1, all$V4, col = clr[4], lwd = 2)
lines(all$V1, all$V5, col = clr[5], lwd = 2)
lines(all$V1, all$V6, col = clr[6], lwd = 2)
lines(all$V1, all$V7, col = clr[7], lwd = 2)
lines(all$V1, all$V8, col = clr[8], lwd = 2)
abline(v = 169)
legend('topright', legend = c("168", "174", "184", "190", "194", '199'),col = clr[3:8], lwd = 2, bty = 'n', cex = 0.75)
dev.off()


### boxplots ####
### for report
# average annual yield (1-5), (6-15), (+15-36)
# report figure 3
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")


duration <- c(rep("Short", 5), rep("Medium", 10), rep("Long", 21))
#duration <- c(rep("Short", 5), rep("Medium", 10), rep("Long", 17))

#proj$Time <- duration
library(ggplot2)
library(reshape2)
library(forcats)
#rest <- melt(proj)
#### short, medium, long term ssb

SSB <- read.csv("med_SSB.csv")
SSB_proj <- SSB[165:200,]
#SSB_proj <- SSB[169:200,]
SSB_proj$int <- duration
ref_SSB <- melt(SSB_proj)
colnames(ref_SSB) <- c("Years", "Scenario", "SSB")
tiff("AASSB_boxes_gray.tiff", width = 6, height = 5, units = 'in', res = 300)
ggplot(data = ref_SSB) +
  geom_boxplot(aes(x = fct_reorder(Years, SSB), y = SSB, fill = Scenario)) +
  scale_fill_manual(labels = c("No bias", "50%", "125%", "200%"),
                    values = c('gray1', 'gray35', 'gray65', 'gray95')) +
  # values =c("gray50", "goldenrod2", "skyblue3", "dodgerblue4")) + 
  theme_classic(base_size = 19) + theme(axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 19), axis.text.x = element_text(colour = "black", size = 19)) +
  xlab("Time Frame") + annotate(geom = "text", x = 1, y = 40000, label = "", size = 6) #+
  #scale_y_continuous(labels = function(x) format(x, scientific = TRUE))

dev.off()

# library(matrixStats)
# short <- as.matrix(SSB[165:169,])
# colMedians(short)
# med <- as.matrix(SSB[170:179,])
# colMedians(med)
# long <- as.matrix(SSB[180:200,])
# colMedians(long)

#### short, medium, long term recruitment
REC <- read.csv("med_REC.csv")
options(scipen = 1)
REC_proj <- REC[165:200,]
#REC_proj <- REC[169:200,]

REC_proj$int <- duration
ref_REC <- melt(REC_proj)
colnames(ref_REC) <- c("Years", "Scenario", "Recruitment")
tiff("AAREC_boxes_gray.tiff", width = 6, height = 5, units = 'in', res = 300)
ggplot(data = ref_REC) +
  geom_boxplot(aes(x = fct_reorder(Years, Recruitment), y = Recruitment, fill = Scenario)) +
  scale_fill_manual(labels = c("No bias", "50%", "125%", "200%"),
                    values = c('gray1', 'gray35', 'gray65', 'gray95')) +
  # values =c("gray50", "goldenrod2", "skyblue3", "dodgerblue4")) + 
  theme_classic(base_size = 19) + theme(axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 19), axis.text.x = element_text(colour = "black", size = 19)) +
  xlab("Time Frame") + annotate(geom = "text", x = 1, y = 8000000, label = "", size = 6) +
  scale_y_continuous(labels = function(x) format(x, scientific = TRUE)) + ylim(0,8000000)

dev.off()

# library(matrixStats)
# short <- as.matrix(REC[165:169,])
# colMedians(short)
# med <- as.matrix(REC[170:179,])
# colMedians(med)
# long <- as.matrix(REC[180:200,])
# colMedians(long)

#### short, medium, long term f
F <- read.csv("med_F.csv")
F_proj <- F[165:200,]
#F_proj <- F[169:200,]
F_proj$int <- duration
ref_F <- melt(F_proj)
colnames(ref_F) <- c("Years", "Scenario", "Fishing_Mortality")
tiff("AAF_boxes_gray.tiff", width = 6, height = 5, units = 'in', res = 300)
ggplot(data = ref_F) +
  geom_boxplot(aes(x = fct_reorder(Years, Fishing_Mortality), y = Fishing_Mortality, fill = Scenario)) +
  scale_fill_manual(labels = c("No bias", "50%", "125%", "200%"),
                    values = c('gray1', 'gray35', 'gray65', 'gray95')) +
  # values =c("gray50", "goldenrod2", "skyblue3", "dodgerblue4")) + 
  theme_classic(base_size = 19) + theme(axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 19), axis.text.x = element_text(colour = "black", size = 19)) +
  xlab("Time Frame") + annotate(geom = "text", x = 1, y = 1.5, label = "", size = 6) +
ylab("Fishing Mortality") + ylim(0, 1.5)

dev.off()

# library(matrixStats)
# short <- as.matrix(F[165:169,])
# colMedians(short)
# med <- as.matrix(F[170:179,])
# colMedians(med)
# long <- as.matrix(F[180:200,])
# colMedians(long)


CW <- read.csv("med_cw.csv")
#par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
#layout(matrix(c(1,2,3,4), ncol = 2, byrow = TRUE))

##### short, medium, long term catch
#proj <- CW[168:199,]
proj <- CW[164:199,]
#duration <- c(rep("A (1-5)", 5), rep("B (6-15)", 10), rep("C (16-36)", 21))
#duration <- c(rep("Short", 5), rep("Medium", 10), rep("Long", 21))


proj$Time <- duration
library(ggplot2)
library(reshape2)
library(forcats)
rest <- melt(proj)
colnames(rest) <- c("Years", "Scenario", "Catch")
tiff("AAC_boxes_gray.tiff", width = 6, height = 5, units = 'in', res = 300)
ggplot(data = rest) +
  geom_boxplot(aes(x = fct_reorder(Years, Catch), y = Catch, fill = Scenario)) +
  scale_fill_manual(labels = c("No bias", "50%", "125%", "200%"),
                    values = c('gray1', 'gray35', 'gray65', 'gray95')) +
  # values =c("gray50", "goldenrod2", "skyblue3", "dodgerblue4")) + 
  theme_classic(base_size = 19) + theme(axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 19), axis.text.x = element_text(colour = "black", size = 19)) +
  xlab("Time Frame") + annotate(geom = "text", x = 1, y = 4000, label = "", size = 6)
dev.off()

# library(matrixStats)
# short <- as.matrix(CW[165:169,])
# colMedians(short)
# med <- as.matrix(CW[170:179,])
# colMedians(med)
# long <- as.matrix(CW[180:199,])
# colMedians(long)



#### local multiruns #####
## 10 local runs with no bias 
##### issue with HPCC not giving stochastic results!!!!###

#setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 28/results/sim")
#setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 30/results/sim")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40/results/sim")
# sims <- list.files()
# load(sims)
# 
# # spawning stock biomass
# SpB <- omvalGlobal$codGOM$SSB[,1,169:200]
# 
# # recruitment
# recr <- omvalGlobal$codGOM$R[,1,169:200]
# 
# #fishing mortality
# fm <- omvalGlobal$codGOM$F_full[,1,169:200]
# 
# #sum catch weight
# cw <- omvalGlobal$codGOM$sumCW[,1,169:200]
# 
# # relative error in SSB
# relESSB <- omvalGlobal$codGOM$relE_SSB[,1,169:200]
# 
# # relative error in recruitment
# relEREC <- omvalGlobal$codGOM$relE_R[,1,169:200]
# 
# #relative error in fishing mortality
# relEFmort <- omvalGlobal$codGOM$relE_F[,1,169:200]
# 
# yrs <- as.character(seq(1, 32))
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario1_v2")
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Low_rec")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# 
# tiff("OM_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(SpB, ylab = "OM Spawning Stock Biomass", xaxt = 'n', xlab = "Projection Year")
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()
# 
# tiff("REE_SSB_indiv.tiff", width = 5, height = 4, units = 'in', res = 300)
# matplot(t(relESSB), type = 'l', ylab = "%REE SSB", lwd = 2, lty = 1, col = 2:11)
# abline(h = 0)
# dev.off()
# 
# tiff("OM_REC.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(recr, ylab = "OM Recruitment", xaxt = 'n', xlab = "Projection Year")
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()
# 
# tiff("OM_F.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(fm, ylab = "OM Fishing Mortality", xaxt = 'n', xlab = "Projection Year")
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()
# 
# tiff("REE_F_indiv.tiff", width = 5, height = 4, units = 'in', res = 300)
# matplot(t(relEFmort), type = 'l', ylab = "%REE F", lwd = 2, lty = 1, col = 1:10)
# abline(h = 0)
# dev.off()
# 
# tiff("OM_catch.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(cw, ylab = "OM Catch", xaxt = 'n', xlab = "Projection Year")
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# dev.off()
# 
# 
# tiff("RelE_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(relESSB, ylab = "%REE SSB", xaxt = 'n', xlab = "Projection Year", ylim = c(-20, 20))
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# abline(h = 0)
# dev.off()
# 
# tiff("RelE_Rec.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(relEREC, ylab = "%REE Rec", xaxt = 'n', xlab = "Projection Year", ylim = c(-20, 20))
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# abline(h = 0)
# dev.off()
# 
# 
# tiff("RelE_F.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(relEFmort, ylab = "%REE F", xaxt = 'n', xlab = "Projection Year", ylim = c(-20, 20))
# axis(1, at = c(1:32),labels = yrs, cex.axis = 1)
# abline(h = 0)
# dev.off()
# 
# ##mean REE means
# mean_REE_SSB <- colMeans(relESSB)
# mean(as.numeric(mean_REE_SSB), na.rm = TRUE)
# 
# mean_REE_REC <- colMeans(relEREC)
# mean(as.numeric(mean_REE_REC), na.rm = TRUE)
# 
# mean_REE_F <- colMeans(relEFmort)
# mean(as.numeric(mean_REE_F), na.rm = TRUE)
# 
# med_REE_SSB <- colMedians(relESSB)
# median(med_REE_SSB, na.rm = TRUE)
# 
# med_REE_REC <- colMedians(relEREC)
# median(med_REE_REC, na.rm = TRUE)
# 
# med_REE_F <- colMedians(relEFmort)
# median(med_REE_F, na.rm = TRUE)


###### extract assessment runs and overlay OM results
## use assessments from year 200
#setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 29/assessment/ASAP")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40/assessment/ASAP")
# 
# library(matrixStats)
# nsim <- 2
# EM_SSB <- matrix(NA, nrow = 37, ncol = nsim)
# EM_REC <- matrix(NA, nrow = 37, ncol = nsim)
# EM_F <- matrix(NA, nrow = 37, ncol = nsim)
# EM_CW <- matrix(NA, nrow = 37, ncol = nsim)
# for (i in 1:nsim){
# assess <- readRDS(paste0("codGOM_", i, "_200.rdat"))
# EM_SSB[,i] <- assess$SSB
# EM_REC[,i] <- assess$SR.resids$recruits
# EM_F[,i] <- assess$F.report
# EM_CW[,i] <- as.vector(assess$catch.obs)
# }
# 
# #clip to projection years
# EM_SSB <- EM_SSB[7:37,]
# EM_REC <- EM_REC[7:37,]
# EM_F <- EM_F[7:37,]
# EM_CW <- EM_CW[7:37,]
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 29/results/sim")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40/results/sim")
# sims <- list.files()
# load(sims)
# 
# SpB <- omvalGlobal$codGOM$SSB[,1,169:199]
# recr <- omvalGlobal$codGOM$R[,1,169:199]
# fm <- omvalGlobal$codGOM$F_full[,1,169:199]
# cw <- omvalGlobal$codGOM$sumCW[,1,169:199]
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario1_v2")
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Low_rec")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("EM_OM_medSSB.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_SSB), col = 'light blue', ylab = "Spawning Stock Biomass", xlab = "Projection Year", ylim = c(0, 50000))
# OM_med_SSB <- colMedians(SpB)
# lines(OM_med_SSB, lwd = 2.5)
# dev.off()
# 
# options(scipen = 999)
# tiff("EM_OM_medRec.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_REC), col = 'light blue', ylab = "Recruitment", xlab = "Projection Year", ylim = c(100000,9000000))
# OM_med_rec <- colMedians(recr)
# lines(OM_med_rec, lwd = 2.5)
# dev.off()
# 
# tiff("EM_OM_medF.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_F), col = 'light blue', ylab = "Fishing Mortality", xlab = "Projection Year")
# OM_med_fm <- colMedians(fm)
# lines(OM_med_fm, lwd = 2.5)
# dev.off()
# 
# tiff("EM_OM_medobsCW.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_CW), col = 'light blue', ylab = "Catch", xlab = "Projection Year", ylim = c(0, 5000))
# OM_med_cw <- colMedians(cw)
# lines(OM_med_cw, lwd = 2.5)
# dev.off()
# 
# 
# #######extract assessment runs and overlay OM results##### from earlier years 
# ## use assessments from year 172
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40/assessment/ASAP")
# library(matrixStats)
# nsim <- 2
# EM_SSB <- matrix(NA, nrow = 37, ncol = nsim)
# EM_REC <- matrix(NA, nrow = 37, ncol = nsim)
# EM_F <- matrix(NA, nrow = 37, ncol = nsim)
# EM_CW <- matrix(NA, nrow = 37, ncol = nsim)
# EM_index <- matrix(NA, nrow = 37, ncol = nsim)
# for (i in 1:nsim){
#   assess <- readRDS(paste0("codGOM_", i, "_172.rdat"))
#   EM_SSB[,i] <- assess$SSB
#   EM_REC[,i] <- assess$SR.resids$recruits
#   EM_F[,i] <- assess$F.report
#   EM_CW[,i] <- as.vector(assess$catch.obs)
#   EM_index[,i] <- as.vector(assess$index.obs$ind01)
# }
# 
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 29/results/sim")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40/results/sim")
# sims <- list.files()
# load(sims)
# 
# SpB <- omvalGlobal$codGOM$SSB[,1,135:171]
# recr <- omvalGlobal$codGOM$R[,1,135:171]
# fm <- omvalGlobal$codGOM$F_full[,1,135:171]
# cw <- omvalGlobal$codGOM$sumCW[,1,135:171]
# 
# 
# YR <- as.character(c(135:171))
# 
# 
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("EM_OM_medSSB_172.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_SSB), col = 'light blue', ylab = "Spawning Stock Biomass", xlab = "Year", ylim = c(0, 50000), xaxt = 'n')
# axis(1, at = c(1:37),labels = YR, cex.axis = 1)
# OM_med_SSB <- colMedians(SpB)
# lines(OM_med_SSB, lwd = 2.5)
# OM_med_ind <- colMedians(t(EM_index))
# lines(OM_med_ind)
# dev.off()
# 
# tiff("EM_OM_medRec_172.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_REC), col = 'light blue', ylab = "Recruitment", xlab = "Year", xaxt = 'n')
# axis(1, at = c(1:37),labels = YR, cex.axis = 1)
# OM_med_rec <- colMedians(recr)
# lines(OM_med_rec, lwd = 2.5)
# dev.off()
# 
# tiff("EM_OM_medF_172.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_F), col = 'light blue', ylab = "Fishing Mortality", xlab = "Year", xaxt = 'n')
# axis(1, at = c(1:37),labels = YR, cex.axis = 1)
# OM_med_fm <- colMedians(fm)
# lines(OM_med_fm, lwd = 2.5)
# dev.off()
# 
# tiff("EM_OM_medobsCW_172.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(EM_CW), col = 'light blue', ylab = "Catch", xlab = "Year", xaxt = 'n')
# axis(1, at = c(1:37),labels = YR, cex.axis = 1)
# OM_med_cw <- colMedians(cw)
# lines(OM_med_cw, lwd = 2.5)
# dev.off()
# 
# 
# boxplot(t(EM_index))
# OM_med_ind <- colMedians(t(EM_index))
# plot(OM_med_ind, type = 'l', ylab = "OM median Observed Index")
# plot(OM_med_SSB, type = 'l', ylab = "OM median SSB")
# 
# 
# 
# ### overfished/overfishing plots 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 29/results/sim")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40/results/sim")
# #setwd("C:/Users/aweston/Documents/GH_projs/groundfish-MSE/results/sim")
# 
# sims <- list.files()
# load(sims)
# ofd <- omvalGlobal$codGOM$OFdStatus[,1,168:199]
# med_ofd <- colMedians(ofd)
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario4_v3")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("Med_Ofd.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(med_ofd, type = 'l', lwd = 2, xlab = "Projection Year", ylab = "Median Overfished Status")
# dev.off()
# 
# 
# ofg <- omvalGlobal$codGOM$OFgStatus[,1,168:199]
# med_ofg <- colMedians(ofg)
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario4_v3")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("Med_Ofg.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(med_ofg, type = 'l', lwd = 2, xlab = "Projection Year", ylab = "Median Overfishing Status")
# dev.off()
# 
# 
# 
# fproxy <- omvalGlobal$codGOM$FPROXY[,1,168:199]
# #boxplot(fproxy)
# f_full <- omvalGlobal$codGOM$F_full[,1,168:199]
# #boxplot(f_full)
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario4_v3")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# 
# f_metric <- f_full/fproxy
# tiff("F_metric.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(f_metric, ylab = "OM F/Fproxy", xlab = "Projection Year")
# abline(h = 1)
# dev.off()
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario4_v3")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("F_proxy.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(fproxy, ylab = "F proxy")
# dev.off()
# 
# EM_f <- EM_F[6:36,]
# fproxy <- fproxy[,-1]
# fproxy <- unname(t(fproxy))
# f_ofg <- EM_f/fproxy
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario4_v3")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("EMF_Fproxy.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(f_ofg), ylab = "EM F/F proxy")
# abline(h = 1)
# dev.off()
# 
# 
# #### OM SSB/ SSBproxy
# ssbproxy <- omvalGlobal$codGOM$SSBPROXY[,1,169:200]
# ssb <- omvalGlobal$codGOM$SSB[,1,169:200]
# 
# s_metric <- ssb/ssbproxy
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario4_v3")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("SSB_metric.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(s_metric, ylim = c(0 , 4.5), ylab = "OM SSB/SSBproxy")
# abline(h = 1)
# dev.off()
# 
# #setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Disc_Figs/Scenario1_v2")
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 40")
# tiff("SSB_proxy.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(ssbproxy, ylab = "SSB proxy")
# dev.off()





##### extract results off HPCC ########
##### individual figures for each scenario
# 45-48 low M
# 51-54 high M
# 66-69 low M, no window, 2015 changepoint, slide HCR
# 70-73 high M, no window, 2015 changepoint, slide HCR
# 74-77 lowM, no window, 2015 changepoint, constant HCR
# 78-81 highM, no window, 2015 changepoint, constant HCR
# 82-85 lowM, no window, 2015 MP w/no bias changepoint, slide HCR
# 86-89 highM, no window, 2015 MP w/no bias changepoint, slide HCR
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 74/results/sim")
# sims <- list.files()
# 
# # get SSB, rec, fishing mortality, and catch weight by stock and MP by year
# SSB <- matrix(NA, ncol = length(sims), nrow = 200)
# REC <- matrix(NA, ncol = length(sims), nrow = 200)
# F_mort <- matrix(NA, ncol = length(sims), nrow = 200)
# CW <- matrix(NA, ncol = length(sims), nrow = 200)
# REE_SSB <- matrix(NA, ncol = length(sims), nrow = 200)
# REE_REC <- matrix(NA, ncol = length(sims), nrow = 200)
# REE_F <- matrix(NA, ncol = length(sims), nrow = 200)
# F_prox <- matrix(NA, ncol = length(sims), nrow = 200)
# B_prox <- matrix(NA, ncol = length(sims), nrow = 200)
# ofd <- matrix(NA, ncol = length(sims), nrow = 200)
# ofg <- matrix(NA, ncol = length(sims), nrow = 200)
# for (i in 1:length(sims)){
#   load(sims[i])
#   SSB[,i] <- as.numeric(omvalGlobal$codGOM$SSB[1,1,])
#   REC[,i] <- as.numeric(omvalGlobal$codGOM$R[1,1,])
#   F_mort[,i] <- as.numeric(omvalGlobal$codGOM$F_full[1,1,])
#   CW[,i] <- as.numeric(omvalGlobal$codGOM$sumCW[1,1,])
#   REE_SSB[,i] <- as.numeric(omvalGlobal$codGOM$relE_SSB[1,1,])
#   REE_REC[,i] <- as.numeric(omvalGlobal$codGOM$relE_R[1,1,])
#   REE_F[,i] <- as.numeric(omvalGlobal$codGOM$relE_F[1,1,])
#   F_prox[,i] <- as.numeric(omvalGlobal$codGOM$FPROXY[1,1,])
#   B_prox[,i] <- as.numeric(omvalGlobal$codGOM$SSBPROXY[1,1,])
#   ofd[,i] <- as.numeric(omvalGlobal$codGOM$OFdStatus[1,1,])
#   ofg[,i] <- as.numeric(omvalGlobal$codGOM$OFgStatus[1,1,])
#   
# }
# #yrs <- as.character(seq(1, 32))
# yrs <- as.character(seq(1, 36))
# 
# library(matrixStats)
# med <- rowMedians(SSB)
# plot(med[122:165], type = 'l')
# boxplot(t(SSB[122:165,]), ylab = "SSB (mt)", xaxt = 'n', xlab = "Projection Year", ylim = c(0, 50000))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# 
# 
# 
# ### OM time series plots ####
# # if projection starts in 2019 use 169 as start year, if proj starts in 2015 use 165
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 85")
# tiff("OM_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(SSB[165:200,]), ylab = "SSB (mt)", xaxt = 'n', xlab = "Projection Year", ylim = c(0, 50000))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# legend(-2, 50000, legend = c("A"), bty = 'n')
# dev.off()
# 
# #tiff("REE_SSB_indiv.tiff", width = 5, height = 4, units = 'in', res = 300)
# #matplot(t(REE_SSB), type = 'l', ylab = "%REE SSB", lwd = 2, lty = 1, col = 2:11)
# #abline(h = 0)
# #dev.off()
# 
# tiff("OM_REC.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(REC[165:200,]), ylab = "Recruitment", xaxt = 'n', xlab = "Projection Year", ylim = c(0, 20000000))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# legend(-2, 20000000, legend = c("B"), bty = 'n')
# dev.off()
# 
# tiff("OM_F.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(F_mort[165:200,]), ylab = "Fishing Mortality", xaxt = 'n', xlab = "Projection Year", ylim = c(0,1.5))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# legend(-2, 1.5, legend = c("C"), bty = 'n')
# dev.off()
# 
# #tiff("REE_F_indiv.tiff", width = 5, height = 4, units = 'in', res = 300)
# #matplot(t(REE_F), type = 'l', ylab = "%REE F", lwd = 2, lty = 1, col = 1:10)
# #abline(h = 0)
# #dev.off()
# 
# tiff("OM_catch.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(CW[165:200,]), ylab = "Catch (mt)", xaxt = 'n', xlab = "Projection Year", ylim = c(0,7000))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# legend(-2, 7000, legend = c("D"), bty = 'n')
# dev.off()
# 
# ### relative errors # 168
# tiff("RelE_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(REE_SSB[165:199,]), ylab = "%REE SSB", xaxt = 'n', xlab = "Projection Year", ylim = c(-100, 100))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# abline(h = 0)
# legend(-2, 100, legend = c("A"), bty = 'n')
# dev.off()
# 
# tiff("RelE_Rec.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(REE_REC[165:199,]), ylab = "%REE Recruitment", xaxt = 'n', xlab = "Projection Year", ylim = c(-100, 100))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# abline(h = 0)
# legend(-2, 100, legend = c("B"), bty = 'n')
# dev.off()
# 
# 
# tiff("RelE_F.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(REE_F[165:199,]), ylab = "%REE Fishing Mortality", xaxt = 'n', xlab = "Projection Year", ylim = c(-100, 100))
# axis(1, at = c(1:36),labels = yrs, cex.axis = 1)
# abline(h = 0)
# legend(-2, 100, legend = c("C"), bty = 'n')
# dev.off()

##
# library(matrixStats)
# med_ofd <- rowMedians(ofd)
# tiff("Med_Ofd.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(med_ofd[168:199], type = 'l', lwd = 2, xlab = "Projection Year", ylab = "Median Overfished Status")
# dev.off()
# 
# med_ofg <- rowMedians(ofg)
# tiff("Med_Ofg.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(med_ofg[168:199], type = 'l', lwd = 2, xlab = "Projection Year", ylab = "Median Overfishing Status")
# dev.off()

# biomass metrics
# s_metric <- SSB/B_prox
# tiff("SSB_metric.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(s_metric[165:200,]), ylim = c(0 , 4), ylab = "OM SSB/SSB threshold", xlab = "Projection Year")
# abline(h = 1)
# legend(-2, 4, legend = c("D"), bty = 'n')
# dev.off()
# 
# tiff("SSB_proxy.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(B_prox[165:200,]), ylab = "SSB threshold", xlab = "Projection Year", ylim = c(0, 80000))
# legend(-2, 80000, legend = c("D"), bty = 'n')
# dev.off()
# 
# # f metrics
# f_metric <- F_mort/F_prox
# tiff("F_metric.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(f_metric[165:200,]), ylab = "OM F/F target", xlab = "Projection Year", ylim = c(0,3))
# abline(h = 1)
# legend(-2, 3, legend = c("D"), bty = 'n')
# dev.off()
# 
# tiff("F_proxy.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(F_prox[165:200,]), ylab = "F target", xlab = "Projection Year", ylim = c(0, 1))
# legend(-2, 1, legend = c("D"), bty = 'n')
# dev.off()
# 
# 
# 
# ### compare SSB to no bias proxy
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 86/results/sim")
# sims <- list.files()
# NB_prox <- matrix(NA, ncol = length(sims), nrow = 200)
# for (i in 1:length(sims)){
#   load(sims[i])
#   NB_prox[,i] <- as.numeric(omvalGlobal$codGOM$SSBPROXY[1,1,])
# }
# 
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 89")
# 
# new_prox <- SSB/NB_prox
# tiff("newB_metric.tiff", width = 5, height = 4, units = 'in', res = 300)
# boxplot(t(new_prox[165:200,]), ylab = "OM SSB/SSB Threshold", xlab = "Projection Year", ylim = c(0,2.5))
# abline(h = 1)
# legend(-2, 2.5, legend = c("D"), bty = 'n')
# dev.off()


#################################### 
# Wed Apr 29 13:05:11 2020 ------------------------------
# boxplots plots of F target and Biomass threshold
# report figure 6
library(ggplot2)
library(reshape2)

# folder with M = 0.2 files
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_lowM_AD_CP_constF")
B_prox <- read.csv("med_SSBproxy.csv")
B_prox <- B_prox[165:200,]
colnames(B_prox) <- c("1", "2", "3", "4")

# folder with M-ramp files
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")
B_prox2 <- read.csv("med_SSBproxy.csv")
B_prox2 <- B_prox2[165:200,]
colnames(B_prox2) <- c("1", "2", "3", "4")

meltB <- melt(B_prox)
natM <- rep("M=0.2", 144)
new <- cbind(meltB, natM)

meltB2 <- melt(B_prox2)
natM <- rep("Mramp", 144)
new2 <- cbind(meltB2, natM)
Bpx_long <- rbind(new, new2)

tiff("SSB_proxies_boxes.tiff", width = 6, height = 5, units = 'in', res = 300)
ggplot(data = Bpx_long) + geom_boxplot(aes(x = variable, y = value, fill = natM)) + 
  scale_fill_grey() + theme_classic(base_size = 19) + 
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, color = 'black', size = 19), legend.title = element_blank(), axis.text.x = element_text(colour = "black", size = 19)) +
  xlab("Bias Scenario") + ylab("SSB Threshold") + 
  annotate(geom = "text", x = 1, y = 70000, label = "", size = 6) +
  scale_y_continuous(labels = function(x) format(x, scientific = TRUE), limits = c(0, 70000))
dev.off()


### low M plot
# tiff("SSB_proxies_boxes.tiff", width = 6, height = 5, units = 'in', res = 300)
# ggplot(data = meltB) + geom_boxplot(aes(x = variable, y = value, fill = natM)) +
#   scale_fill_grey() + theme_classic(base_size = 19) +
#   theme(axis.text.y = element_text(angle = 90, hjust = 0.5, color = 'black', size = 19), legend.title = element_blank(), axis.text.x = element_text(colour = "black", size = 19)) +
#   xlab("Bias Scenario") + ylab("SSB Threshold") +
#   annotate(geom = "text", x = 1, y = 70000, label = "", size = 6) +
#   scale_y_continuous(labels = function(x) format(x, scientific = TRUE), limits = c(0, 40000))
# dev.off()


#### F proxy
#folder with M = 0.2 files
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_lowM_AD_CP_constF")
F_prox <- read.csv("med_Fproxy.csv")
F_prox <- F_prox[165:200,]
colnames(F_prox) <- c("1", "2", "3", "4")

# folder with M-ramp files
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")
F_prox2 <- read.csv("med_Fproxy.csv")
F_prox2 <- F_prox2[165:200,]
colnames(F_prox2) <- c("1", "2", "3", "4")

meltF <- melt(F_prox)
natM <- rep("M=0.2", 144)
new <- cbind(meltF, natM)

meltF2 <- melt(F_prox2)
natM <- rep("Mramp", 144)
new2 <- cbind(meltF2, natM)
Fpx_long <- rbind(new, new2)

tiff("F_proxies_boxes.tiff", width = 6, height = 5, units = 'in', res = 300)
ggplot(data = Fpx_long) + geom_boxplot(aes(x = variable, y = value, fill = natM)) + 
  scale_fill_grey() + theme_classic(base_size = 19) + 
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5, color = 'black', size = 19), legend.title = element_blank(), axis.text.x = element_text(colour = "black", size = 19)) +
  xlab("Bias Scenario") + ylab("F MSY") + 
  annotate(geom = "text", x = 1, y = 0.5, label = "", size = 6) +
  scale_y_continuous(limits = c(0, 0.5))
dev.off()


#low M fig
# tiff("F_proxies_boxes.tiff", width = 6, height = 5, units = 'in', res = 300)
# ggplot(data = meltF) + geom_boxplot(aes(x = variable, y = value, fill = natM)) + 
#   scale_fill_grey() + theme_classic(base_size = 19) + 
#   theme(axis.text.y = element_text(angle = 90, hjust = 0.5, color = 'black', size = 19), legend.title = element_blank(), axis.text.x = element_text(colour = "black", size = 19)) +
#   xlab("Bias Scenario") + ylab("F MSY") + 
#   annotate(geom = "text", x = 1, y = 0.5, label = "", size = 6) +
#   scale_y_continuous(limits = c(0, 0.5))
# dev.off()

###### assessment performance ####
# overlay single assessment iterations from the terminal year 
# lty = 1,2,6,3

# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Files_forPN/No_bias_accum_CP_slide_M0.2")
# no_bias <- dget('codGOM_1_195.rdat')
# 
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Files_forPN/Extreme_bias_accum_CP_slide_M0.2")
# ext_bias <- dget('codGOM_1_195.rdat')
# 
# ssb_no_bias <- no_bias$SSB
# rec_no_bias <- no_bias$SR.resids$recruits
# f_no_bias <- no_bias$F.report
# cw_no_bias <- no_bias$catch.pred[1,]
# 
# ssb_ext_bias <- ext_bias$SSB
# rec_ext_bias <- ext_bias$SR.resids$recruits
# f_ext_bias <- ext_bias$F.report
# cw_ext_bias <- ext_bias$catch.pred[1,]
# 
# setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/Files_forPN")
# yrs <- as.character(seq(1982, 2044))
# tiff("Assess_ssb.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(ssb_no_bias, type = 'l', xlab = "Year", ylab = "SSB (mt)", xaxt = 'n', ylim = c(0, 50000), lwd = 1.5)
# axis(1, at = c(1:63),labels = yrs, cex.axis = 1)
# lines(ssb_ext_bias, lwd = 1.5, lty = 3)
# legend('topright', legend = c("No bias", "200%"), lty = c(1,3), lwd = 1.5, bty = 'n', cex = 0.75)
# dev.off()
# 
# tiff("Assess_rec.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(rec_no_bias, type = 'l', xlab = "Year", ylab = "Recruitment", xaxt = 'n', ylim = c(0, 40000000), lwd = 1.5)
# axis(1, at = c(1:63),labels = yrs, cex.axis = 1)
# lines(rec_ext_bias, lwd = 1.5, lty = 3)
# legend('topright', legend = c("No bias", "200%"), lty = c(1,3), lwd = 1.5, bty = 'n', cex = 0.75)
# dev.off()
# 
# tiff("Assess_F.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(f_no_bias, type = 'l', xlab = "Year", ylab = "Fishing mortality", xaxt = 'n', ylim = c(0,3), lwd = 1.5)
# axis(1, at = c(1:63),labels = yrs, cex.axis = 1)
# lines(f_ext_bias, lwd = 1.5, lty = 3)
# legend('topright', legend = c("No bias", "200%"), lty = c(1,3), lwd = 1.5, bty = 'n', cex = 0.75)
# dev.off()
# 
# tiff("Assess_cw.tiff", width = 5, height = 4, units = 'in', res = 300)
# plot(cw_no_bias, type = 'l', xlab = "Year", ylab = "Catch (mt)", xaxt = 'n', lwd = 1.5)
# axis(1, at = c(1:63),labels = yrs, cex.axis = 1)
# lines(cw_ext_bias, lwd = 1.5, lty = 3)
# legend('topright', legend = c("No bias", "200%"), lty = c(1,3), lwd = 1.5, bty = 'n', cex = 0.75)
# dev.off()


##### extract terminal assessment year results ####


# save across bias scenarios 1/2/3/4 to one .csv
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Run results/Run 125/results/term_assessment")

assess <- list.files()

sa_SSB <- matrix(NA, ncol = length(assess), nrow = 68)
sa_REC <- matrix(NA, ncol = length(assess), nrow = 68)
sa_F_mort <- matrix(NA, ncol = length(assess), nrow = 68)
sa_CW <- matrix(NA, ncol = length(assess), nrow = 68)


for(i in 1:length(assess)){
  res <- readRDS(assess[i])
  sa_SSB[,i] <- as.numeric(res$SSB)
  sa_REC[,i] <- as.numeric(res$SR.resids$recruits)
  sa_F_mort[,i] <- as.numeric(res$F.report)
  sa_CW[,i] <- as.numeric(res$catch.obs)

}

library(matrixStats)

med_sa_SSB <- rowMedians(sa_SSB)
med_sa_REC <- rowMedians(sa_REC)
med_sa_F <- rowMedians(sa_F_mort)
med_sa_CW <- rowMedians(sa_CW)


scen1SSB <- med_sa_SSB
scen1REC <- med_sa_REC
scen1F <- med_sa_F
scen1C <- med_sa_CW


scen2SSB <- med_sa_SSB
scen2REC <- med_sa_REC
scen2F <- med_sa_F
scen2C <- med_sa_CW


scen3SSB <- med_sa_SSB
scen3REC <- med_sa_REC
scen3F <- med_sa_F
scen3C <- med_sa_CW

scen4SSB <- med_sa_SSB
scen4REC <- med_sa_REC
scen4F <- med_sa_F
scen4C <- med_sa_CW


all_med_SSB <- cbind(scen1SSB, scen2SSB, scen3SSB, scen4SSB)
all_med_rec <- cbind(scen1REC, scen2REC, scen3REC, scen4REC)
all_med_F <- cbind(scen1F, scen2F, scen3F, scen4F)
all_med_CW <- cbind(scen1C, scen2C, scen3C, scen4C)

# save results
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")

write.csv(all_med_SSB, "med_sa_SSB.csv")
write.csv(all_med_rec, "med_sa_rec.csv")
write.csv(all_med_F, "med_sa_F.csv")
write.csv(all_med_CW, "med_sa_cw.csv")



###### plot different assessment scenarios as different line types- like OM figure
## report figure 4
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims/Material/OM_highM_AD_CP_constF")

tiff("SA_lines_highM_AD_CP_constF.tiff", width = 7, height = 2, units = 'in', res = 300)
par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
layout(matrix(c(1,2,3,4), ncol = 4, byrow = TRUE))
#layout.show(4)
# Median spawning stock biomass
all_mean_SSB <- read.csv('med_sa_SSB.csv')
#yrs <- as.character(seq(1982, 2050))
yrs <- as.character(seq(1982, 2049, 10))
#tiff("Med_SSB.tiff", width = 5, height = 4, units = 'in', res = 300)
plot(all_mean_SSB[,1], ylim = c(0, 45000), type = 'l', lwd = 1.5, ylab = "SSB (mt)", xlab = 'Year', cex.lab = 1, cex.axis = 1, xaxt = 'n')
#axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
axis(1, seq(1,68,10),labels = yrs, cex.axis = 1)
#legend(-2.5, 46500, legend = c("M"), bty = 'n')
lines(all_mean_SSB[,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_SSB[,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_SSB[,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
#legend('topright', legend = c("No bias", "50%", "125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
#dev.off()

# Median recruitment
options(scipen = 0)
all_mean_rec <- read.csv('med_sa_rec.csv')
plot(all_mean_rec[,1],  type = 'l', lwd = 1.5, ylab = "Recruitment", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 33000000), xaxt = 'n')
#axis(1, at = c(1:69),labels = yrs, cex.axis = 1)
axis(1, seq(1,68,10),labels = yrs, cex.axis = 1)
#legend(-2.5, 34000000, legend = c("N"), bty = 'n')
lines(all_mean_rec[,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_rec[,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_rec[,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
#legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
#dev.off()

# Median Fishing mortality
all_mean_F <- read.csv('med_sa_F.csv')
plot(all_mean_F[,1],  type = 'l', lwd = 1.5, ylab = "Fishing Mortality", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 2.3), xaxt = 'n')
axis(1, seq(1,68,10),labels = yrs, cex.axis = 1)
#legend(-2.5, 2.4, legend = c("O"), bty = 'n')
lines(all_mean_F[,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_F[,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_F[,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
#legend('topright', legend = c("No bias", "+50%", "+125%", "+200%"), lty = c(1,1,1,1), col = c("gray50", "goldenrod2", "skyblue3", "dodgerblue4"), lwd = 2, bty = 'n', cex = 0.75)
#dev.off()

# Median catch weight
all_mean_cw <- read.csv('med_sa_cw.csv')
plot(all_mean_cw[,1], type = 'l', lwd = 1.5, ylab = "Catch (mt)", xlab = 'Year', cex.lab = 1, cex.axis = 1, ylim = c(0, 20000), xaxt = 'n')
axis(1, seq(1,68,10),labels = yrs, cex.axis = 1)
#legend(-1.5, 21000, legend = c("P"), bty = 'n')
lines(all_mean_cw[,2], type = 'l', lwd = 1.5, lty = 2)
lines(all_mean_cw[,3], type = 'l', lwd = 1.5, lty = 6)
lines(all_mean_cw[,4], type = 'l', lwd = 1.5, lty = 3)
abline(v = 33)
legend('topright', legend = c("No bias", "50%", "125%", "200%"), lty = c(1,2,6,3), lwd = 1.5, bty = 'n', cex = 0.75)
dev.off()

###### simple HCR figure
setwd("C:/Users/aweston/Box/Ashley Weston (System Account)/Discard Sims")
tiff("HCR.tiff", width = 4, height = 4, units = 'in', res = 300)
par(mar = c(2.5, 3, 1.5, 0.5), mgp = c(1.5, 0.5, 0))
constf <- rep(0.5,20)
ramp <- c(0,0.1, 0.2, 0.3, 0.4, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
plot(constf, type = 'l', cex.lab = 1.5, lwd = 2, yaxt = 'n', xaxt = 'n', xlab = "Biomass", ylab = "Fishing Mortality", ylim = c(0, 1))
lines(ramp, lty = 2, lwd = 2)
legend('topright', legend = c("Constant HCR", "Slide HCR"),lty = c(1,2), lwd = 2, bty = 'n')
dev.off()






