#Hydra_Sim_Dat_R
get_hydra_data <- function(MSEyr=0)
{
  speciesList <- c("Atlantic_cod","Atlantic_herring","Atlantic_mackerel",  
                   "Goosefish","Haddock","Silver_hake","Spiny_dogfish",
                   "Winter_flounder","Winter_skate","Yellowtail_flounder")
  
  debug <-0
  Nyrs <- 42
  Nspecies <- 10
  Nsizebins <- 5
  Nareas <- 1
  Nfleets <- 3
  Nsurveys <- 2
  wtconv <- 1
  
  F_devs <-rep(0,Nfleets*Nyrs)
  recruitment_devs <- rep(0,Nspecies*(Nyrs-1))
  
  Nyrs <- Nyrs + MSEyr
  

  datfilename <- "hydra_sim_data-ts.dat"
  binwidth <- c(38, 18, 18, 18, 51,
                18, 5, 5, 5, 11,
                23, 5, 5, 5, 23,
                32, 15, 15, 15, 46,
                31, 13, 13, 13, 30,
                19, 10, 10, 10, 35,
                47, 14, 14, 14, 62,
                26, 9, 9, 9, 33,
                43, 13, 13, 13, 37,
                22, 7, 7, 7, 24)
  
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

  yr1Nphase <- 1           
  recphase <- -1			
  avg_rec_phase	<- 1
  recsigmaphase <- -1
  avg_F_phase <- 1
  dev_rec_phase <- 2
  dev_F_phase <- 1
  fqphase <- 1              
  fsphase <- 1         
  sqphase <- 1         
  ssphase <- 1         
  ssig_phase <- -1
  sig_phase <- -1    
  m1_phase <- -1     
  oF1_phase <- -1      
  oFdev_phase <- -1     
  vuln_phase <- -1  
  
  recGamma_alpha <- rep(1,Nareas*Nspecies)
  recGamma_shape <- rep(1,Nareas*Nspecies)
  recGamma_beta <- rep(1,Nareas*Nspecies)
  # recGamma_alpha <- rep(1,Nareas*Nspecies)
  # recGamma_shape <- rep(1,Nareas*Nspecies)
  # recGamma_beta <- rep(1,Nareas*Nspecies)
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
              1,0,0,1,1,1,1,0,1,0,
              0,0,0,1,0,0,1,0,0,0,
              0,0,0,0,0,0,1,0,0,0,
              0,0,0,0,0,0,0,0,0,0,
              1,0,0,1,0,0,1,0,0,0)
  # isprey <- c(1,0,0,1,0,0,1,0,1,0,
  #             1,0,0,1,1,1,1,0,1,0,
  #             1,0,0,1,1,1,1,0,1,0,
  #             0,0,0,1,0,0,0,0,0,0,
  #             1,0,0,1,1,1,1,0,1,0,
  #             1,1,1,1,1,1,1,0,1,0,
  #             0,0,0,1,0,0,1,0,0,0,
  #             0,0,0,0,0,0,1,0,0,0,
  #             0,0,0,0,0,0,0,0,0,0,
  #             1,0,0,1,0,0,1,0,0,0)
  preferred_wtratio <- rep(0.5,Nareas*Nspecies)
  sd_sizepref <-rep(2,Nspecies)
  B0 <- c(40492.1504465078, 505.36938141088, 528.887106715519, 1371.90070992549, 
          38085.3933953885, 6022.7619315119, 49621.132793312, 5141.41161960716, 
          39169.6461461017, 2560.63451957253)
  Nguilds <- 10
  guildMembers <- seq(1:Nguilds)
  fleetMembers <- c(1,3,3,1,1,1,2,1,1,1)
  AssessmentPeriod <- 3
  flagRamp <- 1
  minExploitation <- rep(1e-05,Nfleets)
  maxExploitation <- rep(0.999,Nfleets)
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
  predOrPrey <- c(1,0,0,1,0,1,1,0,1,0)
  bandwidth_metric <- 5
  baseline_threshold <- 0.2
  indicator_fishery_q <- c(1, 0, 0, 1, 1, 1, 0, 1, 1, 1,
                           0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
                           0, 1, 1, 0, 0, 0, 0, 0, 0, 0)
  AR_parameters <- rep(0,3)
  flagMSE <- 0
  residentTime <- rep(1,Nareas*Nspecies)
  areaMortality <- rep(0,Nareas*Nspecies)
  
  #Not present in current dat file?
  m1_change_yr <- 43
  m1_multiplier <- 1
  of_change_yr <- 43
  of_multiplier <- 1  
  ################################
  eof <- 54321
  
  #Start the other .dat file information:
  Nsurvey_obs <- 833 
  obs_survey_biomass <- read.csv("functions/hydra/obs_survey_biomass_3fleet.csv",sep=",",head=F)
  colnames(obs_survey_biomass) <- c("survey","year","species","biomass","cv")
  Nsurvey_size_obs <- 833 
  obs_survey_size <- read.csv("functions/hydra/obs_survey_size_3fleet.csv",sep=",",head=F)
  colnames(obs_survey_size) <- c("survey","year","species","type","inpN","sizebin1","sizebin2","sizebin3","sizebin4","sizebin5")
  
  Ncatch_obs <- 1260
  obs_catch_biomass <- read.csv("functions/hydra/obs_catch_biomass_3fleet.csv",sep=",",head=F)
  obs_catch_biomass[1,1] <- as.numeric(1)
  colnames(obs_catch_biomass) <- c("fleet","area","year","species","catch","cv")
  Ncatch_size_obs <- 556
  obs_catch_size <- read.csv("functions/hydra/obs_catch_size_3fleet.csv",sep=",",head=F)
  colnames(obs_catch_size) <- c("fleet","area","year","species","type","inpN","sizebin1","sizebin2","sizebin3","sizebin4","sizebin5")
  
  Ndietprop_obs <- 506
  obs_dietprop <- read.csv("functions/hydra/obs_dietprop_3fleet.csv",sep=",",head=F)
  colnames(obs_dietprop) <- c("survey","year","predator","predator_size","InpN",
                              "wt_prey_1","wt_prey_2","wt_prey_3","wt_prey_4",
                              "wt_prey_5","wt_prey_6","wt_prey_7","wt_prey_8",
                              "wt_prey_9","wt_prey_10","wt_prey_11")
  
  #Start of the .pin file information:
  ln_yr1N <- c(4.320719, 4.170631, 3.755749, 3.921926, 2.776405,
               7.114145, 7.114145, 7.176080, 7.176080, 7.909972,
               5.153246, 5.395981, 5.292695, 5.180995, 5.082370,
               2.356080, 2.373466, 2.182834, 2.240743, 1.409347,
               4.864227, 5.769418, 6.391626, 6.376833, 6.586802,
               4.908024, 5.035344, 4.712493, 4.341122, 4.615205,
               3.785003, 3.682979, 3.383073, 2.926285, 2.103726,
               4.058581, 4.456441, 4.553273, 4.724987, 5.084422,
               4.761059, 4.878398, 4.773043, 4.628072, 4.719693,
               4.779360, 5.310661, 5.426917, 5.607626, 6.514726)
  recruitment_alpha <- rep(0,Nspecies)
  recruitment_shape <- rep(0,Nspecies)
  recruitment_beta <- rep(0,Nspecies)
  ln_avg_recruitment <- c(5, 10, 7.5, 4.5, 8, 6.5, 5, 6, 6, 7)
  # ln_avg_recruitment:
  # ln_avg_recruitment <- c(8.04380760469463,11.2580744944398,10.2056449821234,7.26721881384248,9.17000749695306,10.4427032203272,9.94925902386207,8.12114001798702,9.07220425500543,8.05293757807327)
  
  # ln_recsigma <- c(-0.693147181, -0.693147181, -0.693147181, -2.302585093, -0.693147181, -0.693147181, -2.302585093, -0.693147181, -2.302585093, -0.693147181) #rep(-0.3011051,Nspecies)
  ln_recsigma <- rep(1,Nspecies)
  avg_F <- c(-2.42134984013792, -3.66107348353279, -4.07193042420258)
  logit_vuln <- rep(10,sum(isprey)) 
  # fishsel_pars <- c(3.69,2.89,2.71,2.48) # rep(1,Nfleets*2)
  fishsel_pars <- c(1,1,1,1,1,1) # rep(1,Nfleets*2)
  # ln_fishery_q <- rep(c(-1.203972804, -0.693147181, 0.405465108, 0, 0, -1.609437912, 0, -1.108662625), 42) #rep(0,Nspecies-Nfleets*Nareas)
  ln_fishery_q <- rep(c(0,0,0,0,0,0,0),Nyrs)
  
  ln_survey_q <- rep(0,Nsurveys*Nspecies)
  # survey_selpars <-rep(-1,Nsurveys*2)
  survey_selpars <-rep(1,Nsurveys*2)
  ln_M1ann <- rep(-2.302585,Nspecies)
  ln_otherFood_base <- 21
  # otherFood_dev <- rep(0,Nspecies-2)
  otherFood_dev <- rep(0,5)
  
  # F_devs:
  # F_devs <- c(0.642347785906398, 2.21511161030484, 2.25431160976588, 0.871229765122742, 0.539542083057794, 0.191617091328200, -0.274226971730411, -0.149655132312834, -0.246003110138881, -0.265206591096768, -0.161844697814579, -0.326638855123091, 0.123119027785921, 0.145196718514495, 0.0767383074783148, 0.186576973923877, 0.406691437766896, -0.359361770794067, -0.149003212959931, -0.256071255470159, -0.175124636169956, -0.235694653084319, 0.0507356133534115, 0.390164890208099, 0.218926409539086, 0.667656440038750, 0.613235398428212, 0.454548195106711, 0.332446812333383, 0.306715258913203, 0.325361902326360, 0.458769483114119, 0.350301544305041, 0.396347877993905, 0.0723033248881896, -0.860734746492823, -0.610578104449168, -0.906380642616671, -1.28741351109271, -1.52786603368601, -1.83225102533723, -2.66594059586467,
  #             1.93623908212084, 2.82857892156422, 3.32186575371829, 2.06201060017420, 2.78156703142258, 2.76749897915350, 2.14673169688974, 1.89479261369969, 1.65613552446752, 1.05759887796602, 0.911189105806114, -0.376049282638672, 0.795856984809867, 0.0486893805022728, -0.479238034767885, -0.115378043438043, 2.04095664602131, -1.89364335380913, -0.308078027345191, -1.00727128324459, -1.08625244088444, -0.461322277673814, -1.11926302615060, -1.40258868301778, -1.07977593989810, -0.436222508739022, -0.311123659394116, -1.08362685276302, -0.509598262613727, -0.476696221432666, -0.818825942380379, -1.08778198228919, -2.07592128911797, -1.92225963941335, -1.84497262584752, -0.308813721184292, -0.306506981625798, -0.678609755600919, -0.922701473857126, -0.814876653824111, -1.02764474107525, -2.29466851995102)
  F_devs <- rep(0,Nfleets*Nyrs)
  
  # recruitment_devs:
  # recruitment_devs <- c(4.07101679403499, 0.138685475867744, 0.322948957667609, 0.375325950933137, 0.406513177117343, 0.280421701495075, 0.214786197113921, 2.33173878135605, 0.340977523136827, 0.408441456896429, 0.357978688174531, 0.275200345660794, 0.187349641994563, 0.128790754204963, 0.117456043927797, 0.266565383364999, 0.305267266045770, -0.0307947362963351, -0.0584624392035154, -0.00880114104615189, -0.0207830793764117, 0.0527858559868810, -0.109748056035389, -0.319771001463870, -0.379842825998977, -0.235193293210003, 0.00437641664689230, -0.0560622579296344, -0.477525358106279, -0.768187381942645, -0.947236967457238, -1.07239679066051, -1.13366892881276, -1.07766122690664, -0.976966437332207, -0.912794370151976, -0.799390113447097, -0.635464628129226, -0.397262876479866, -0.179152234172607, 0.0105402439587027,
  #                       0.180505813873166, -0.944727926988017, -0.803508439960390, -0.843784919599053, -0.893608133738976, -0.910057484147376, -0.640694502115925, -0.153493809047555, -0.0325355082239373, -0.421104308939472, -0.749215511535918, -0.956880440480958, -1.01997168657238, -0.981032824337681, -0.739644401545234, 0.148828602021032, 3.72913167103931, 0.0374441767235010, 0.0443226208398156, 0.0839975266529166, 0.0868087500151784, 0.0946039468598259, 0.0571848692498879, 0.117902479554903, 0.277852088344759, 0.237591629951386, 0.157054743214672, 3.58978892128202, 0.140417527179362, 0.143114671995238, 0.159674558292028, 0.375157338212199, 0.205397192958404, 0.0475589745203435, 0.290113850746455, -0.0294667085203037, -0.0441829793144660, -0.0604847263525942, -0.0407258697974924, 0.0211025076199143, 0.0395648358890591,
  #                       -0.337829920377835, 0.504304843759951, 1.04611562850318, 0.558784781666428, 0.556948905959489, 0.568011722527429, 0.323769990154085, 0.190054907845939, 0.161764706851924, 0.234180142352713, 0.351857017190228, 0.387969432424790, 0.321990239394345, 0.178443633484509, 0.0296805968673780, -0.116863618586621, -0.154169082027346, -0.173997807840825, -0.205213614847976, -0.250649632635878, -0.320601218699877, -0.395758841326480, -0.516483137579288, -0.554356960350748, -0.572530004745789, -0.586473859579181, -0.579167917046875, -0.552135326686806, -0.496298819310966, -0.392937298602104, -0.216489563478000, 0.00357582238376930, 0.148161031066814, 0.204575189087172, 0.202731003985849, 0.221920961075996, 0.166168395964801, 0.0805709448733918, 0.0392512430361689, -0.0259905855772173, -0.0328841560682167,
  #                       2.32793124615119, -0.0177301270369863, -0.0419026359933991, 0.0474917686701091, 0.102869475861236, 0.139990336522282, 0.151154303460883, 0.159761756937202, 0.151900249135995, 0.144210229152973, 0.128932997152568, 0.103993506272498, 0.0639368978721863, -0.0202727850977575, -0.108092481036988, -0.197086209252428, -0.256657128940964, -0.308840094376032, -0.346364881629412, -0.380536633243617, -0.414448541757276, -0.463334905445159, -0.512444861338410, -0.557177988425378, -0.580474975021367, -0.583224713105101, -0.550182324875487, -0.456416636352205, -0.299850604518333, -0.0884795991066378, 0.145950702036312, 0.425242080279221, 0.611499725125438, 0.719199662477960, 0.672599626829983, 0.233777495216659, 0.105271147834561, -0.0214425227932780, -0.0765176237160724, -0.0910534138753954, -0.0631816141568317,
  #                       1.84690782286185, -0.422550626499784, -0.560390578460127, -0.585246333429093, -0.555959322276233, -0.620118999545246, -0.603751849600555, -0.732586647910010, -0.724023144516396, -0.674878894370415, -0.640123907273754, -0.610044624189296, -0.575934087880396, -0.561080064063551, -0.631514026030687, -0.574251774354043, -0.481510748144219, -0.336097715470899, -0.291732576251157, -0.202429884242547, -0.0933240511513655, 0.132038334923860, 0.268139373648005, 0.625303764255273, 0.868689873204487, 0.176063079100390, -0.121941740944300, -0.0868811659272949, 0.0806215509435315, 0.0365795329047499, -0.256598143733876, -0.0851662211364984, 0.195008313437225, 2.68695810738975, 1.18941358562530, 1.21480532498961, 0.271595724699825, 0.846497203591579, 0.317944281155231, 0.162433899158409, 0.109136584820933,
  #                       1.50280694330462, -0.0765207811219604, -0.0941607174958176, -0.176693735889762, -0.0905151341790609, 0.106615717007879, 0.270763717479396, 0.104191947867587, -0.0224939361233675, -0.00581061358959515, 0.367039917092175, 0.477967082197466, 0.648311491467606, -0.199593124635538, -0.335129640301300, -0.191006125186362, -0.0979495771337933, -0.246808425354872, -0.363573144079429, -0.643905005878867, -0.804875202699392, -0.748305052718997, -0.684316301781171, -0.758203028382862, -0.780630009991757, -0.766677872673878, -0.592941666469130, -0.369527348486176, -0.360314445809215, -0.109733185042669, 0.484976319102492, 0.417799351123524, 0.576491616189523, 0.170159325949290, -0.0184769187021368, 0.0532313168494449, 0.0719507819709875, 0.325820290176483, 2.47847410377405, 0.201732500114487, 0.279828096868553,
  #                       2.34718714645396, -0.126136690792163, -0.0634069624370805, -0.0866447625656093, -0.0876504767193696, -0.0335462073354386, 0.106830211832477, 0.286264757565858, 0.493636747419267, 0.405947549862266, 0.249375085117857, 0.187421675632082, 0.175234947624233, 0.323489580859798, 0.425539615224058, 0.0858259603882921, -0.156255147194693, -0.279404354495394, -0.374911918224575, -0.371929582312906, -0.406315556586740, -0.473255889923087, -0.529539334429060, -0.590907522630942, -0.572909580594954, -0.472640425470342, -0.401062649624605, -0.598942764868320, -0.522418902554223, -0.353442713550133, -0.230434224312737, 0.0826942911567312, 0.687281639606074, 0.524070289315211, 0.367361909267529, 0.201272842350191, 0.0719079588193094, -0.0808272683624324, -0.0733522793092189, -0.0633381830897218, -0.0720687518786844,
  #                       2.97583434622743, -0.107734208307542, -0.0800208540646773, -0.0626304833666242, -0.0539103374308447, 0.00201042486116596, 0.0449467530605357, 0.0553024374985777, 0.0679958073458275, 0.0378417157178902, 0.0859631936866938, 0.0967512452285340, 0.0856741054160369, 0.203233542624125, 0.457826264246450, 0.295115158453675, 0.181382359642731, 0.149069562167994, 0.204229034956162, 0.233965414972615, 0.186785618368796, 0.00514173412763218, -0.183244750520811, -0.294256589773911, -0.360408109759666, -0.308368974978005, -0.103753070757325, -0.0558646633132040, -0.107435921037370, -0.0853769774139151, -0.0820311785047421, -0.223736296877286, -0.447495015371010, -0.593443437383693, -0.565788818053698, -0.491431484878569, -0.397898235861180, -0.301930212307996, -0.216816888459090, -0.150706486587860, -0.0947862693168374,
  #                       2.52953407485034, -0.449214610997165, -0.577813742378050, -0.629938824416064, -0.648533986807259, -0.649029056605968, -0.640391975387666, -0.639441427867884, -0.624520604627852, -0.587949767196586, -0.573630445405847, -0.527131432009904, -0.457397764196061, -0.351421577688766, -0.239877524922186, -0.114695578917493, 0.00267526890167055, 0.0747113615003304, 0.0534677156074731, 1.11346538263192e-05, -0.0355911272202252, -0.0440214909616820, -0.00153934346255530, 0.0637708381422895, 0.216078567372062, 0.348981425369733, 0.340488660414599, 0.237753841908532, 0.147262837316981, 0.128726698941574, 0.157775026847857, 0.287261914559174, 0.347440157522058, 2.52968391581853, 0.178241006845786, 0.108813792434664, 0.0310888704192728, -0.00702097632092130, -0.00256425949872891, 0.0102297577161041, 0.00772967720251338,
  #                       3.61288775784202, 0.00965808453421859, 0.0496747000260294, 0.138655888880849, 0.241503834346313, 0.327378636472001, 0.516522682497902, 0.769834522441817, 1.05658323474027, 0.479550296578843, 0.193777065149906, 0.0545338971333514, 0.0732895405428120, 0.0782557075336442, 0.164060710718301, 0.244377450641458, 2.64746950513174, 0.321973740128851, 0.521188280672279, 0.577492455005100, 0.575619998431454, 0.571388257143310, 0.605274944310051, 0.360838340759673, 0.0909402066514395, 0.0225206474179350, -0.0638090315525881, -0.359654071592401, -0.747410310375396, -1.11826146481522, -1.36967153398851, -1.57302716073570, -1.66682763495708, -1.66665577544376, -1.58956156238157, -1.40975841339253, -1.18912278745266, -0.902942433497982, -0.522814334162795, -0.111516726339720, -0.0142175826168099)
  recruitment_devs <- rep(0,Nspecies*(Nyrs-1))  
  
  hydra_data <- list(speciesList=speciesList, debug=debug, Nyrs=Nyrs, Nspecies=Nspecies, Nsizebins=Nsizebins,
                     Nareas=Nareas, Nfleets=Nfleets, Nsurveys=Nsurveys, wtconv=wtconv, datfilename=datfilename,
                     binwidth=binwidth, lenwt_a=lenwt_a, lenwt_b=lenwt_b, Nrecruitment_cov=Nrecruitment_cov, Nmaturity_cov=Nmaturity_cov,
                     Ngrowth_cov=Ngrowth_cov, recruitment_cov=recruitment_cov, maturity_cov=maturity_cov, growth_cov=growth_cov, obs_effort=obs_effort,
                     mean_stomwt=mean_stomwt, bs_temp=bs_temp,yr1Nphase=yr1Nphase, recphase=recphase, avg_rec_phase=avg_rec_phase, 
                     recsigmaphase=recsigmaphase, avg_F_phase=avg_F_phase, dev_rec_phase=dev_rec_phase, dev_F_phase=dev_F_phase, fqphase=fqphase, 
                     fsphase=fsphase, sqphase=sqphase, ssphase=ssphase, ssig_phase=ssig_phase, sig_phase=sig_phase, 
                     m1_phase=m1_phase, oF1_phase=oF1_phase, oFdev_phase=oFdev_phase, vuln_phase=vuln_phase, recGamma_alpha=recGamma_alpha, 
                     recGamma_shape=recGamma_shape, recGamma_beta=recGamma_beta, recDS_alpha=recDS_alpha, recDS_shape=recDS_shape, recDS_beta=recDS_beta, 
                     recGamSSB_alpha=recGamSSB_alpha, recGamSSB_shape=recGamSSB_shape, recGamSSB_beta=recGamSSB_beta, recRicker_alpha=recRicker_alpha, recRicker_shape=recRicker_shape, 
                     recRicker_beta=recRicker_beta, recBH_alpha=recBH_alpha, recBH_shape=recBH_shape, recBH_beta=recBH_beta, recShepherd_alpha=recShepherd_alpha, 
                     recShepherd_shape=recShepherd_shape, recShepherd_beta=recShepherd_beta, recHockey_alpha=recHockey_alpha, recHockey_shape=recHockey_shape, recHockey_beta=recHockey_beta, 
                     recSegmented_alpha=recSegmented_alpha, recSegmented_shape=recSegmented_shape, recSegmented_beta=recSegmented_beta, rectype=rectype, stochrec=stochrec, 
                     sexratio=sexratio, recruitment_covwt=recruitment_covwt, fecund_d=fecund_d, fecund_h=fecund_h, fecund_theta=fecund_theta, 
                     maturity_nu=maturity_nu, maturity_omega=maturity_omega, maturity_covwt=maturity_covwt, growth_psi=growth_psi, growth_kappa=growth_kappa, 
                     growth_covwt=growth_covwt, vonB_LinF=vonB_LinF, vonB_k=vonB_k, growthtype=growthtype, phimax=phimax, 
                     intake_alpha=intake_alpha, intake_beta=intake_beta, isprey=isprey, preferred_wtratio=preferred_wtratio, sd_sizepref=sd_sizepref, 
                     B0=B0, Nguilds=Nguilds, guildMembers=guildMembers, fleetMembers=fleetMembers, AssessmentPeriod=AssessmentPeriod, 
                     flagRamp=flagRamp, minExploitation=minExploitation, maxExploitation=maxExploitation,
                     minMaxExploitation=minMaxExploitation, minMaxThreshold=minMaxThreshold,
                     Nthresholds=Nthresholds, threshold_preportion=threshold_preportion, exploitation_levels=exploitation_levels, threshold_species=threshold_species, AssessmentOn=AssessmentOn,
                     speciesDetection=speciesDetection, LFI_size=LFI_size, scaleInitialN=scaleInitialN, effortScaled=effortScaled, discard_Coef=discard_Coef,
                     discardSurvival_Coef=discardSurvival_Coef, predOrPrey=predOrPrey, bandwidth_metric=bandwidth_metric, baseline_threshold=baseline_threshold, indicator_fishery_q=indicator_fishery_q,
                     AR_parameters=AR_parameters, flagMSE=flagMSE, residentTime=residentTime, areaMortality=areaMortality, 
                     m1_change_yr=m1_change_yr,
                     m1_multiplier=m1_multiplier,
                     of_change_yr=of_change_yr,
                     of_multiplier=of_multiplier,
                     eof=eof,
                     Nsurvey_obs=Nsurvey_obs, obs_survey_biomass=obs_survey_biomass, Nsurvey_size_obs=Nsurvey_size_obs, obs_survey_size=obs_survey_size, Ncatch_obs=Ncatch_obs, obs_catch_biomass=obs_catch_biomass, 
                     Ncatch_size_obs=Ncatch_size_obs, obs_catch_size=obs_catch_size, Ndietprop_obs=Ndietprop_obs, obs_dietprop=obs_dietprop, ln_yr1N=ln_yr1N, recruitment_alpha=recruitment_alpha, 
                     recruitment_shape=recruitment_shape, recruitment_beta=recruitment_beta, ln_avg_recruitment=ln_avg_recruitment, recruitment_devs=recruitment_devs, ln_recsigma=ln_recsigma, avg_F=avg_F, 
                     F_devs=F_devs, logit_vuln = logit_vuln, fishsel_pars=fishsel_pars, ln_fishery_q=ln_fishery_q, ln_survey_q=ln_survey_q, survey_selpars=survey_selpars, ln_M1ann=ln_M1ann, 
                     ln_otherFood_base=ln_otherFood_base, otherFood_dev=otherFood_dev)

  return(hydra_data)
  
}