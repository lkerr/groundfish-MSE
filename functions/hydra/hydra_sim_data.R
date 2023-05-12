#Hydra_Sim_Dat_R

speciesList <- c("Atlantic_cod","Atlantic_herring","Atlantic_mackerel",  
                 "Goosefish","Haddock","Silver_hake","Spiny_dogfish",
                 "Winter_flounder","Winter_skate","Yellowtail_flounder")

debug <-0
Nyrs <- 42
Nspecies <- 10
Nsizebins <- 5
Nareas <- 1
Nfleets <- 2
Nsurveys <- 2
wtconv <- 1
datfilename <- "hydra_sim_GB_5bin_1978_inpN-ts.dat"
binwidth <- c(29, 29, 29, 29, 29, 
              8, 8, 8, 8, 8, 
             12, 12, 12, 12, 12, 
             24, 24, 24, 24, 24, 
             20, 20, 20, 20, 20,
             17, 17, 17, 17, 17,
             30, 30, 30, 30, 30,
             17, 17, 17, 17, 17,
             23, 23, 23, 23, 23,
             14, 14, 14, 14, 14)

lenwt_a <- c(0.00685681567472357, 0.00696289397647208, 0.00310242979734439, 0.0205011606372842, 0.00759240073997539, 0.00421677371743438, 0.00218691346582327, 0.00910817030110655, 0.00244734811734799, 0.00582004148366075)
lenwt_b <- c(3.09133638752902, 3.08159581281283, 3.32100440840157, 2.93322687044393, 3.06816962846841, 3.12947468289365, 3.13962578098272, 3.08298298576075, 3.26552505022405, 3.10977555176597)

Nrecruitment_cov <- 1
Nmaturity_cov <- 1
Ngrowth_cov <- 1
recruitment_cov <- rep(1,Nyrs*Nrecruitment_cov)
maturity_cov <- rep(1,Nyrs*Nmaturity_cov)
growth_cov <- rep(1,Nyrs)
obs_effort <-rep(1,Nareas*Nfleets*Nyrs)

mean_stomwt <- c(rep(c(0.035,0.103736364,1.952671779,18.42060702,84.48736889),Nyrs),
                 rep(c(0.01,0.03,0.8,1.5,3),Nyrs),
                 rep(c(0.01,0.08,1.3,2,3),Nyrs),
                 rep(c(0.090189781,1.952671779,9.334322368,28.80493233,77.55885308),Nyrs),
                 rep(c(0.031,0.096183673,0.939220418,3.915192982,12.07313904),Nyrs),
                 rep(c(0.039893347,0.179748344,0.512104803,4.879748476,20.262),Nyrs),
                 rep(c(0.090189781,1.952671779,9.334322368,28.80493233,77.55885308),Nyrs),
                 rep(c(0.016072464,0.086965517,0.237958824,0.442743017,1.583142857),Nyrs),
                 rep(c(0.093423453,0.939220418,3.915192982,11.46903371,44.88111925),Nyrs),
                 rep(c(0.016072464,0.086965517,0.237958824,0.442743017,1.583142857),Nyrs))
bs_temp <- c(8.69398, 9.08885, 8.74414285714286, 8.868, 8.55206666666667, 9.43436666666667, 
             9.26516666666667, 9.69548, 9.1646, 8.274075, 8.52445, 8.32313333333333, 
             8.99702857142857, 8.79641428571429, 8.26319, 8.48561666666667, 9.46302222222222, 
             9.72635333333333, 8.42418666666667, 8.99431, 9.18441538461539, 9.96980714285714, 
             9.25267142857143, 9.30151111111111, 9.9935875, 8.71782222222222, 7.99782857142857, 
             8.4206, 9.3799, 8.41815, 8.95543333333333, 9.0541625, 9.2831125, 9.8491375, 
             10.4877555555556, 9.95232857142857, 9.671, 9.63732, 10.31192, 9.5166, 9.99688, 9.77481666666667)
yr1Nphase <- -1           
recphase <- -1			
avg_rec_phase	<- 1
recsigmaphase <- -1
avg_F_phase <- 1
dev_rec_phase <- -3
dev_F_phase <- 2
fqphase <- 1              
fsphase <- 1         
sqphase <- 1         
ssphase <- 1         
ssig_phase <- -3        
sig_phase <- -1    
m1_phase <- -1     
oF1_phase <- -1      
oFdev_phase <- -1     
vuln_phase <- -1  

recGamma_alpha <- rep(1,Nareas*Nspecies)
recGamma_shape <- rep(1,Nareas*Nspecies)
recGamma_beta <- rep(1,Nareas*Nspecies)
recGamma_alpha <- rep(1,Nareas*Nspecies)
recGamma_shape <- rep(1,Nareas*Nspecies)
recGamma_beta <- rep(1,Nareas*Nspecies)
recDS_alpha <- rep(1,Nareas*Nspecies)
recDS_shape <- rep(1,Nareas*Nspecies)
recDS_beta <- rep(1,Nareas*Nspecies)
recGamSSB_alpha <- rep(1,Nareas*Nspecies)
recGamSSB_shape <- rep(1,Nareas*Nspecies)
recGamSSB_beta <- rep(1,Nareas*Nspecies)
recRicker_alpha <- rep(1,Nareas*Nspecies)
recRicker_shape <- rep(1,Nareas*Nspecies)
recRicker_beta <- rep(1,Nareas*Nspecies)
recBH_alpha <- rep(1,Nareas*Nspecies)
recBH_shape <- rep(1,Nareas*Nspecies)
recBH_beta <- rep(1,Nareas*Nspecies)
recShepherd_alpha <- rep(1,Nareas*Nspecies)
recShepherd_shape <- rep(1,Nareas*Nspecies)
recShepherd_beta <- rep(1,Nareas*Nspecies)
recHockey_alpha <- rep(1,Nareas*Nspecies)
recHockey_shape <- rep(1,Nareas*Nspecies)
recHockey_beta <- rep(1,Nareas*Nspecies)
recSegmented_alpha <- rep(1,Nareas*Nspecies)
recSegmented_shape <- rep(1,Nareas*Nspecies)
recSegmented_beta <- rep(1,Nareas*Nspecies)

rectype <- rep(9,Nspecies)
stochrec <- rep(0,Nspecies)
sexratio <- rep(0.5,Nareas*Nspecies)
recruitment_covwt <- rep(0,Nspecies*Nrecruitment_cov)
fecund_d <- rep(1,Nareas*Nspecies)
fecund_h <- rep(1,Nareas*Nspecies)
fecund_theta <- rep(0,Nareas*Nspecies*Nsizebins)
maturity_nu <- rep(1,Nareas*Nspecies)
maturity_omega <- rep(1,Nareas*Nspecies)
maturity_covwt <- rep(0,Nspecies*Nmaturity_cov)

growth_psi <- c(22.31730855, 11.65211497, 20.48292586, 9.180847155,
                23.06032547, 13.77993268, 11.28075301, 17.76925648,
                18.77845121, 16.00105119)
growth_kappa <- c(0.734859369, 0.456436561, 0.26327238, 0.955590716, 
                  0.502070649, 0.648621251, 0.688187, 0.552886341, 
                  0.59567, 0.618898136)
growth_covwt <- rep(0,Nspecies*Ngrowth_cov)
vonB_LinF <- c(113.5946212, 29.05066434, 43.2563036, 84.5, 73.8, 
               41.22438991, 99.99, 56.29613167, 114.1, 44.70963156)
vonB_k <- c(0.197508768, 0.45225377, 0.205956533, 0.34, 0.376, 0.403649534, 
            0.1, 0.291557309, 0.14405, 0.477577158)
growthtype <- c(3,3,3,1,1,3,3,3,3,3)
phimax <- 1
intake_alpha <- rep(0.004,Nareas*Nspecies)
intake_beta <- rep(0.11,Nareas*Nspecies)
isprey <- c(1,0,0,1,0,0,1,0,1,0,
            1,0,0,1,1,1,1,0,1,0,
            1,0,0,1,1,1,1,0,1,0,
            0,0,0,1,0,0,0,0,0,0,
            1,0,0,1,1,1,1,0,1,0,
            1,1,1,1,1,1,1,0,1,0,
            0,0,0,1,0,0,1,0,0,0,
            0,0,0,0,0,0,1,0,0,0,
            0,0,0,0,0,0,0,0,0,0,
            1,0,0,1,0,0,1,0,0,0)
preferred_wtratio <- rep(0.5,Nareas*Nspecies)
sd_sizepref <-rep(2,Nspecies)
B0 <- c(40492.1504465078, 505.36938141088, 528.887106715519, 1371.90070992549, 
        38085.3933953885, 6022.7619315119, 49621.132793312, 5141.41161960716, 
        39169.6461461017, 2560.63451957253)
Nguilds <- 10
guildMembers <- seq(1:Nguilds)
fleetMembers <- c(1,2,2,1,1,1,1,1,1,1)
AssessmentPeriod <- 3
flagRamp <- 1
minExploitation <- rep(1e-05,2)
maxExploitation <- rep(0.999,2)
minMaxExploitation <- rep(0.05,2)
minMaxThreshold <- c(0.1,0.4)
Nthresholds <- 5
threshold_preportion <- sort(c(0.1,0.2,0.3,0.4,1e+06))
exploitation_levels <- rep(0.05,Nthresholds)
threshold_species <- rep(0,Nspecies)
AssessmentOn <- 0
speciesDetection <- 0
LFI_size <- 60
scaleInitialN <- 1
effortScaled <- rep(1,Nareas*Nspecies)
discard_Coef <- rep(0,Nareas*Nspecies*Nfleets*Nsizebins)
discardSurvival_Coef <- rep(1,Nareas*Nspecies*Nfleets*Nsizebins)
predOrPrey <- c(1,1,1,1,1,1,1,0,1,1)
bandwidth_metric <- 5
baseline_threshold <- 0.2
indicator_fishery_q <- c(1,0,0,1,1,1,1,1,1,1,
                         0,1,1,0,0,0,0,0,0,0)
AR_parameters <- rep(0,3)
flagMSE <- 0
residentTime <- rep(1,Nareas*Nspecies)
areaMortality <- rep(0,Nareas*Nspecies)
eof <- 54321
