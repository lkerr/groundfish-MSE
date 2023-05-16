#ifdef DEBUG
  #ifndef __SUNPRO_C
    #include <cfenv>
    #include <cstdlib>
  #endif
#endif
  //Including C++ libraries
  #include "statsLib.h"
  #include <iostream>
  #include <math.h>
 // #include <cmath>
  #include <fstream>
  #include <string>
  #include <sstream>
  #include <time.h>
  time_t baseTime;
  clock_t startTime = clock();
  // ofstream test("test.csv"); // for debugging only
  ofstream gavjunk("gav.junk");
#include <admodel.h>
#include <contrib.h>

  extern "C"  {
    void ad_boundf(int i);
  }
#include <hydra_sim.htp>

model_data::model_data(int argc,char * argv[]) : ad_comm(argc,argv)
{
    int on,opt;
    sim=0;
     rseed=1;
    //the following line checks for the "-sim" command line option
    //if it exists the if statement retreives the random number seed
    //that is required for the simulation model
    if((on=option_match(ad_comm::argc,ad_comm::argv,"-sim",opt))>-1)
    {
      sim=1;
      rseed=atoi(ad_comm::argv[on+1]);
    }
  debug.allocate("debug");
  Nyrs.allocate("Nyrs");
  Nspecies.allocate("Nspecies");
  Nsizebins.allocate("Nsizebins");
  Nareas.allocate("Nareas");
  Nfleets.allocate("Nfleets");
  Nsurveys.allocate("Nsurveys");
  Totsizebins = Nspecies*Nsizebins;
  maxThreshold.allocate(1,Nareas);
 Nprey = Nspecies + 1;
  o = 0.001;         //small number to add before taking logs in objective function calcs
  wtconv.allocate("wtconv");
  datfilename.allocate("datfilename");
  cout<<datfilename<<endl;
  binwidth.allocate(1,Nspecies,1,Nsizebins,"binwidth");
  lenwt_a.allocate(1,Nspecies,"lenwt_a");
  lenwt_b.allocate(1,Nspecies,"lenwt_b");
  lbinmax.allocate(1,Nspecies,1,Nsizebins);
  lbinmin.allocate(1,Nspecies,1,Nsizebins);
  lbinmidpt.allocate(1,Nspecies,1,Nsizebins);
  wtbinmax.allocate(1,Nspecies,1,Nsizebins);
  wtbinmin.allocate(1,Nspecies,1,Nsizebins);
  wtatlbinmidpt.allocate(1,Nspecies,1,Nsizebins);
  binavgwt.allocate(1,Nspecies,1,Nsizebins);
  powlbinmaxb.allocate(1,Nspecies,1,Nsizebins);
	for (spp=1; spp<=Nspecies; spp++){
		lbinmax(spp,1)   = binwidth(spp,1);
		lbinmin(spp,1)   = 0.0;						//lowest bin assumed to start at 0!
		lbinmidpt(spp,1) = binwidth(spp,1)/2.0;
		for (size=2; size<=Nsizebins; size++){
			lbinmax(spp, size)   = binwidth(spp, size) + lbinmax(spp, size-1);
			lbinmin(spp, size)   = lbinmax(spp, size-1);
			lbinmidpt(spp, size) = binwidth(spp, size)/2.0 + lbinmax(spp, size-1);
		}
    	wtbinmax(spp) = lenwt_a(spp)* pow(lbinmax(spp), lenwt_b(spp));
    	wtbinmin(spp) = lenwt_a(spp)* pow(lbinmin(spp), lenwt_b(spp));
    	wtatlbinmidpt(spp) = lenwt_a(spp)* pow(lbinmidpt(spp), lenwt_b(spp));
	}
	binavgwt = (wtbinmin + wtbinmax)/2.0;
  Nrecruitment_cov.allocate("Nrecruitment_cov");
  Nmaturity_cov.allocate("Nmaturity_cov");
  Ngrowth_cov.allocate("Ngrowth_cov");
  recruitment_cov.allocate(1,Nrecruitment_cov,1,Nyrs,"recruitment_cov");
  maturity_cov.allocate(1,Nmaturity_cov,1,Nyrs,"maturity_cov");
  growth_cov.allocate(1,Ngrowth_cov,1,Nyrs,"growth_cov");
  obs_effort.allocate(1,Nareas,1,Nfleets,1,Nyrs,"obs_effort");
  mean_stomwt.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"mean_stomwt");
  obs_temp.allocate(1,Nareas,1,Nyrs,"obs_temp");
  yr1Nphase.allocate("yr1Nphase");
  recphase.allocate("recphase");
  avg_rec_phase.allocate("avg_rec_phase");
  recsigmaphase.allocate("recsigmaphase");
  avg_F_phase.allocate("avg_F_phase");
  dev_rec_phase.allocate("dev_rec_phase");
  dev_F_phase.allocate("dev_F_phase");
  fqphase.allocate("fqphase");
  fsphase.allocate("fsphase");
  sqphase.allocate("sqphase");
  ssphase.allocate("ssphase");
  ssig_phase.allocate("ssig_phase");
  csig_phase.allocate("csig_phase");
  m1_phase.allocate("m1_phase");
  oF1_phase.allocate("oF1_phase");
  oFdev_phase.allocate("oFdev_phase");
  vuln_phase.allocate("vuln_phase");
  recGamma_alpha.allocate(1,Nareas,1,Nspecies,"recGamma_alpha");
  recGamma_shape.allocate(1,Nareas,1,Nspecies,"recGamma_shape");
  recGamma_beta.allocate(1,Nareas,1,Nspecies,"recGamma_beta");
  recDS_alpha.allocate(1,Nareas,1,Nspecies,"recDS_alpha");
  recDS_shape.allocate(1,Nareas,1,Nspecies,"recDS_shape");
  recDS_beta.allocate(1,Nareas,1,Nspecies,"recDS_beta");
  recGamSSB_alpha.allocate(1,Nareas,1,Nspecies,"recGamSSB_alpha");
  recGamSSB_shape.allocate(1,Nareas,1,Nspecies,"recGamSSB_shape");
  recGamSSB_beta.allocate(1,Nareas,1,Nspecies,"recGamSSB_beta");
  recRicker_alpha.allocate(1,Nareas,1,Nspecies,"recRicker_alpha");
  recRicker_shape.allocate(1,Nareas,1,Nspecies,"recRicker_shape");
  recRicker_beta.allocate(1,Nareas,1,Nspecies,"recRicker_beta");
  recBH_alpha.allocate(1,Nareas,1,Nspecies,"recBH_alpha");
  recBH_shape.allocate(1,Nareas,1,Nspecies,"recBH_shape");
  recBH_beta.allocate(1,Nareas,1,Nspecies,"recBH_beta");
  recShepherd_alpha.allocate(1,Nareas,1,Nspecies,"recShepherd_alpha");
  recShepherd_shape.allocate(1,Nareas,1,Nspecies,"recShepherd_shape");
  recShepherd_beta.allocate(1,Nareas,1,Nspecies,"recShepherd_beta");
  recHockey_alpha.allocate(1,Nareas,1,Nspecies,"recHockey_alpha");
  recHockey_shape.allocate(1,Nareas,1,Nspecies,"recHockey_shape");
  recHockey_beta.allocate(1,Nareas,1,Nspecies,"recHockey_beta");
  recSegmented_alpha.allocate(1,Nareas,1,Nspecies,"recSegmented_alpha");
  recSegmented_shape.allocate(1,Nareas,1,Nspecies,"recSegmented_shape");
  recSegmented_beta.allocate(1,Nareas,1,Nspecies,"recSegmented_beta");
  rectype.allocate(1,Nspecies,"rectype");
  stochrec.allocate(1,Nspecies,"stochrec");
  rec_alpha.allocate(1,Nareas,1,Nspecies);
  rec_shape.allocate(1,Nareas,1,Nspecies);
  rec_beta.allocate(1,Nareas,1,Nspecies);
  if(debug==1){
  cout<<"debug: "<<endl<<debug<<endl;
  cout<<"Nyrs: "<<endl<<Nyrs<<endl;
  cout<<"Nspecies: "<<endl<<Nspecies<<endl;
  cout<<"Nsizebins: "<<endl<<Nsizebins<<endl;
  cout<<"Nareas: "<<endl<<Nareas<<endl;
  cout<<"Nfleets: "<<endl<<Nfleets<<endl;
  cout<<"Nsurveys: "<<endl<<Nsurveys<<endl;
  cout<<"wtconv: "<<endl<<wtconv<<endl;
  cout<<"datfilename: "<<endl<<datfilename<<endl;
  cout<<"binwidth: "<<endl<<binwidth<<endl;
  cout<<"lenwt_a: "<<endl<<lenwt_a<<endl;
  cout<<"lenwt_b: "<<endl<<lenwt_b<<endl;
 cout<<"Nrecruitment_cov: "<<endl<<Nrecruitment_cov<<endl;
 cout<<"Nmaturity_cov: "<<endl<<Nmaturity_cov<<endl;
 cout<<"Ngrowth_cov: "<<endl<<Ngrowth_cov<<endl;
 cout<<"recruitment_cov: "<<endl<<recruitment_cov<<endl;
 cout<<"maturity_cov: "<<endl<<maturity_cov<<endl;
 cout<<"growth_cov: "<<endl<<growth_cov<<endl;
 cout<<"obs_effort: "<<endl<<obs_effort<<endl;
 cout<<"mean_stomwt: "<<endl<<mean_stomwt<<endl;
 cout<<"obs_temp: "<<endl<<obs_temp<<endl;
 cout<<"yr1Nphase: "<<endl<<yr1Nphase<<endl;
 cout<<"recphase: "<<endl<<recphase<<endl;
 cout<<"avg_rec_phase: "<<endl<<avg_rec_phase<<endl;
 cout<<"recsigmaphase: "<<endl<<recsigmaphase<<endl;
 cout<<"avg_F_phase: "<<endl<<avg_F_phase<<endl;
 cout<<"dev_rec_phase: "<<endl<<dev_rec_phase<<endl;
 cout<<"dev_F_phase: "<<endl<<dev_F_phase<<endl;
 cout<<"fqphase: "<<endl<<fqphase<<endl;
 cout<<"fsphase: "<<endl<<fsphase<<endl;
 cout<<"sqphase: "<<endl<<sqphase<<endl;
 cout<<"ssphase: "<<endl<<ssphase<<endl;
 cout<<"ssig_phase: "<<endl<<ssig_phase<<endl;
 cout<<"m1_phase: "<<endl<<m1_phase<<endl;
 cout<<"oF1_phase: "<<endl<<oF1_phase<<endl;
 cout<<"oFdev_phase: "<<endl<<oFdev_phase<<endl;
 cout<<"vuln_phase: "<<endl<<vuln_phase<<endl;
 cout<<"recGamma_alpha: "<<endl<<recGamma_alpha<<endl;
 cout<<"recGamma_shape: "<<endl<<recGamma_shape<<endl;
 cout<<"recGamma_beta: "<<endl<<recGamma_beta<<endl;
 cout<<"recDS_alpha: "<<endl<<recDS_alpha<<endl;
 cout<<"recDS_shape: "<<endl<<recDS_shape<<endl;
 cout<<"recDS_beta: "<<endl<<recDS_beta<<endl;
 cout<<"recGamSSB_alpha: "<<endl<<recGamSSB_alpha<<endl;
 cout<<"recGamSSB_shape: "<<endl<<recGamSSB_shape<<endl;
 cout<<"recGamSSB_beta: "<<endl<<recGamSSB_beta<<endl;
 cout<<"recRicker_alpha: "<<endl<<recRicker_alpha<<endl;
 cout<<"recRicker_shape: "<<endl<<recRicker_shape<<endl;
 cout<<"recRicker_beta: "<<endl<<recRicker_beta<<endl;
 cout<<"recBH_alpha: "<<endl<<recBH_alpha<<endl;
 cout<<"recBH_shape: "<<endl<<recBH_shape<<endl;
 cout<<"recBH_beta: "<<endl<<recBH_beta<<endl;
 cout<<"recShepherd_alpha: "<<endl<<recShepherd_alpha<<endl;
 cout<<"recShepherd_shape: "<<endl<<recShepherd_shape<<endl;
 cout<<"recShepherd_beta: "<<endl<<recShepherd_beta<<endl;
 cout<<"recHockey_alpha: "<<endl<<recHockey_alpha<<endl;
 cout<<"recHockey_shape: "<<endl<<recHockey_shape<<endl;
 cout<<"recHockey_beta: "<<endl<<recHockey_beta<<endl;
 cout<<"recSegmented_alpha: "<<endl<<recSegmented_alpha<<endl;
 cout<<"recSegmented_shape: "<<endl<<recSegmented_shape<<endl;
 cout<<"recSegmented_beta: "<<endl<<recSegmented_beta<<endl;
 cout<<"rectype: "<<endl<<rectype<<endl;
 cout<<"stochrec: "<<endl<<stochrec<<endl;
 cout<<"rec_alpha: "<<endl<<rec_alpha<<endl;
 cout<<"rec_shape: "<<endl<<rec_shape<<endl;
 cout<<"rec_beta: "<<endl<<rec_beta<<endl;
  }
  for (area=1; area<=Nareas; area++){
	for(spp=1; spp<=Nspecies; spp++){
	  switch (rectype (spp)){
       case 1:	  				//egg production based recruitment, 3 par gamma (Ricker-ish)
		  rec_alpha(area,spp) = recGamma_alpha(area,spp);
		  rec_shape(area,spp) = recGamma_shape(area,spp);
		  rec_beta(area,spp) = recGamma_beta(area,spp);
	   break;
	   case 2:                   //SSB based recruitment, 3 par Deriso-Schnute; see Quinn & Deriso 1999 p 95
          rec_alpha(area,spp) = recDS_alpha(area,spp);
          rec_shape(area,spp) = recDS_shape(area,spp);
          rec_beta(area,spp) = recDS_beta(area,spp);
       break;
	   case 3:                   //SSB based recruitment, 3 par gamma
          rec_alpha(area,spp) = recGamSSB_alpha(area,spp);
          rec_shape(area,spp) = recGamSSB_shape(area,spp);
          rec_beta(area,spp) = recGamSSB_beta(area,spp);
       break;
	   case 4:                   //SSB based recruitment, 2 par Ricker
          rec_alpha(area,spp) = recRicker_alpha(area,spp);
          rec_shape(area,spp) = recRicker_shape(area,spp);
          rec_beta(area,spp) = recRicker_beta(area,spp);
       break;
	   case 5:                   //SSB based recruitment, 2 par BevHolt
          rec_alpha(area,spp) = recBH_alpha(area,spp);
          rec_shape(area,spp) = recBH_shape(area,spp);
          rec_beta(area,spp) = recBH_beta(area,spp);
       break;
       case 6:                // SSB based recruitment, 3 parameters Shepherd
          rec_alpha(area,spp) = recShepherd_alpha(area,spp);
          rec_shape(area,spp) = recShepherd_shape(area,spp);
          rec_beta(area,spp) = recShepherd_beta(area,spp);
       break;
       case 7:                // SSB based rcruitment. hockeyStick
          rec_alpha(area,spp) = recHockey_alpha(area,spp);
          rec_shape(area,spp) = recHockey_shape(area,spp);
          rec_beta(area,spp) = recHockey_beta(area,spp);
       break;
       case 8:                // SSB based recruitment,segmented regresion with breakpoint
          rec_alpha(area,spp) = recSegmented_alpha(area,spp);
          rec_shape(area,spp) = recSegmented_shape(area,spp);
          rec_beta(area,spp) = recSegmented_beta(area,spp);
       break;
	   case 9:                   //no functional form, uses average+devs in .pin file
          rec_alpha(area,spp) = 0;
          rec_shape(area,spp) = 0;
          rec_beta(area,spp) = 0;
       break;
       default:
          cout<<"undefined recruitment type, check .dat file"<<endl;
          exit(1);
		}
    }
 }
  sexratio.allocate(1,Nareas,1,Nspecies,"sexratio");
  recruitment_covwt.allocate(1,Nspecies,1,Nrecruitment_cov,"recruitment_covwt");
  fecund_d.allocate(1,Nareas,1,Nspecies,"fecund_d");
  fecund_h.allocate(1,Nareas,1,Nspecies,"fecund_h");
  fecund_theta.allocate(1,Nareas,1,Nspecies,1,Nsizebins,"fecund_theta");
  fecundity.allocate(1,Nareas,1,Nspecies,1,Nsizebins);
  for (area=1; area<=Nareas; area++){
	for(spp=1; spp<=Nspecies; spp++){
    	fecundity(area, spp) = elem_prod(fecund_theta(area, spp),
											(fecund_d(area, spp)
                            	 			* pow(lbinmidpt(spp),fecund_h(area, spp))));
	}
  }
  maturity_nu.allocate(1,Nareas,1,Nspecies,"maturity_nu");
  maturity_omega.allocate(1,Nareas,1,Nspecies,"maturity_omega");
  maturity_covwt.allocate(1,Nspecies,1,Nmaturity_cov,"maturity_covwt");
  covariates_M.allocate(1,Nspecies,1,Nyrs);
  growth_psi.allocate(1,Nareas,1,Nspecies,"growth_psi");
  growth_kappa.allocate(1,Nareas,1,Nspecies,"growth_kappa");
  growth_covwt.allocate(1,Nspecies,1,Ngrowth_cov,"growth_covwt");
  vonB_Linf.allocate(1,Nareas,1,Nspecies,"vonB_Linf");
  vonB_k.allocate(1,Nareas,1,Nspecies,"vonB_k");
  growthtype.allocate(1,Nspecies,"growthtype");
  phimax.allocate("phimax");
  growthprob_phi.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins);
  delta_t.allocate(1,Nsizebins);
  lmax_test.allocate(1,2);
  if(debug==1){
 cout<<"sexratio: "<<endl<<sexratio<<endl;
 cout<<"recruitment_covwt: "<<endl<<recruitment_covwt<<endl;
 cout<<"fecund_d: "<<endl<<fecund_d<<endl;
 cout<<"fecund_h: "<<endl<<fecund_h<<endl;
 cout<<"fecund_theta: "<<endl<<fecund_theta<<endl;
 cout<<"maturity_nu: "<<endl<<maturity_nu<<endl;
 cout<<"maturity_omega: "<<endl<<maturity_omega<<endl;
 cout<<"maturity_covwt: "<<endl<<maturity_covwt<<endl;
 cout<<"growth_psi: "<<endl<<growth_psi<<endl;
 cout<<"growth_kappa: "<<endl<<growth_kappa<<endl;
 cout<<"growth_covwt: "<<endl<<growth_covwt<<endl;
 cout<<"vonB_Linf: "<<endl<<vonB_Linf<<endl;
 cout<<"vonB_k: "<<endl<<vonB_k<<endl;
 cout<<"growthtype: "<<endl<<growthtype<<endl;
 cout<<"phimax: "<<endl<<phimax<<endl;
  }
  for (area=1; area<=Nareas; area++){
	for(spp=1; spp<=Nspecies; spp++){
     for(yr=1; yr<=Nyrs; yr++){
      switch (growthtype (spp)){
        case 1:	  	 //exponential no covariates
              // these yimes  of growing out of bin relative to size zero. SGaichas
    	  delta_t = pow((lbinmax(spp)/growth_psi(area, spp)),(1.0/growth_kappa(area, spp)));
              // these are "probabilities" of growing into size bin, r given in size bin r-1. ABeet
              growthprob_phi(area, spp, yr,1) = 1/delta_t(1);
              for (int isize=2;isize<=Nsizebins; isize++) {
                growthprob_phi(area, spp, yr, isize) = 1/(delta_t(isize) - delta_t(isize-1));
              }
        break;
        case 2:       //exponential with covariates
              // these "probabilitlies of growing out of bin relative to size zero. SGaichas
    	  delta_t = pow((lbinmax(spp)/growth_psi(area, spp)* mfexp(growth_covwt(spp)*trans(growth_cov)(yr))),
	        										(1.0/growth_kappa(area, spp)));
              // these are "probabilities" of growing into size bin, r given in size bin r-1. ABeet
              growthprob_phi(area, spp, yr,1) = 1/delta_t(1);
              for (int isize=2;isize<=Nsizebins; isize++) {
                growthprob_phi(area, spp, yr, isize) = 1/(delta_t(isize) - delta_t(isize-1));
              }
        break;
        case 3:       //VonB no covariates          
          for (size=1;size<=Nsizebins;size++) {
            if (lbinmin(spp,size)>=vonB_Linf(area, spp) || lbinmax(spp,size)>=vonB_Linf(area, spp)) {
             growthprob_phi(area, spp, yr, size) = 0.0;
            }
            if (lbinmax(spp,size)<vonB_Linf(area, spp)) {
               growthprob_phi(area, spp, yr, size) = vonB_k(area, spp)/log(
                                                   (vonB_Linf(area, spp)-lbinmin(spp,size))/
                                                   (vonB_Linf(area, spp)-lbinmax(spp,size)));
            }
          }
        break;
        case 4:       //VonB with covariates
          growthprob_phi(area, spp, yr) = vonB_k(area, spp)/log(
                                          elem_div((vonB_Linf(area, spp)*mfexp(growth_covwt(spp)*trans(growth_cov)(yr))-lbinmin(spp)),
                                                   (vonB_Linf(area, spp)*mfexp(growth_covwt(spp)*trans(growth_cov)(yr))-lbinmax(spp))));
        break;
        default:
          cout<<"undefined growth type, check .dat file"<<endl;
          exit(1);
        }
      growthprob_phi(area, spp, yr)(Nsizebins) = 0.0; //set prob of outgrowing highest bin to 0
      double tempmax =  max(growthprob_phi(area, spp, yr));
      phimax = max(tempmax,phimax);
	  }
	}
    growthprob_phi(area) /= phimax;  //rescale so no group has >1 prob growing out
  }
//  growthprob_phi /= phimax;   //rescale so no group has >1 prob growing out--not working on 4d array
  Nstepsyr = round(phimax);            //set model timestep to phimax
  Tottimesteps = Nstepsyr*Nyrs;        //for scaling state variable arrays
  intake_alpha.allocate(1,Nareas,1,Nspecies,"intake_alpha");
  intake_beta.allocate(1,Nareas,1,Nspecies,"intake_beta");
  intake.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins);
  for (area=1; area<=Nareas; area++){
	for(spp=1; spp<=Nspecies; spp++){
      for(yr=1; yr<=Nyrs; yr++){
        intake(area, spp, yr) = 24.0 * (intake_alpha (area, spp) *
                              mfexp(intake_beta (area, spp) * obs_temp (area,yr))) *
                              mean_stomwt(area, spp,yr) * //daily intake in g
                              365.0 / //annual intake
                              Nstepsyr;  //intake per model timestep
      }
    }
  }
  isprey.allocate(1,Nareas,1,Nspecies,1,Nspecies,"isprey");
 Npreypar = 0;
 Npred = 0;
 Npreypar = sum(isprey(1));
 for (spp=1;spp<=Nspecies;spp++) {
  if(sum(extract_column(isprey(1),spp))>0) Npred += 1;
 }
  preferred_wtratio.allocate(1,Nareas,1,Nspecies,"preferred_wtratio");
  sd_sizepref.allocate(1,Nspecies,"sd_sizepref");
  wtratio.allocate(1,Nareas,1,Nspecies,1,Totsizebins,1,Nsizebins);
  for (area=1; area<=Nareas; area++){
  	for (pred=1; pred<=Nspecies; pred++){
    	for(prey=1; prey<=Nspecies; prey++){
			dmatrix wttemp = outer_prod(wtatlbinmidpt(prey), 1.0/wtatlbinmidpt(pred));// ijth =  prey size i/pred size j
			wttemp.rowshift(prey*Nsizebins-(Nsizebins-1));
                    // since wttemp is inserted into a larger matrix you need to set the .rowmin() property to the row it will be inseted into
                  wtratio(area, pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins) = wttemp;
		}
    }
  } //
  sizepref.allocate(1,Nareas,1,Nspecies,1,Totsizebins,1,Nsizebins);
  // log normal distribution mu's and sigmas, read in. wtratioprey variable.
  for (area=1; area<=Nareas; area++){
  	for (pred=1; pred<=Nspecies; pred++){
    	for(prey=1; prey<=Totsizebins; prey++){
     	    for(int isize=1; isize<=Nsizebins; isize++){
              double wtratioprey = wtratio(area, pred, prey, isize);
			  sizepref(area, pred, prey, isize) =
              1/(wtratioprey*sd_sizepref(pred)*sqrt(2*M_PI))*exp(-square(log(wtratioprey)-preferred_wtratio(area, pred))/(2*square(sd_sizepref(pred))));


              }
		}
	}
  } //ok
  B0.allocate(1,Nareas,1,Nspecies,"B0");
  Nguilds.allocate("Nguilds");
  catchToDiscardsGuild.allocate(1,Nareas,1,Nguilds);
  catchToDiscardsSpecies.allocate(1,Nareas,1,Nspecies);
  maxGuildThreshold.allocate(1,Nareas,1,Nguilds);
  maxSpeciesThreshold.allocate(1,Nareas,1,Nspecies);
  guildMembers.allocate(1,Nspecies,"guildMembers");
  fleetMembers.allocate(1,Nguilds,"fleetMembers");
  AssessmentPeriod.allocate("AssessmentPeriod");
  B0_guilds.allocate(1,Nareas,1,Nguilds);
 for (area=1; area<=Nareas; area++) {
     for (iguild=1; iguild<=Nguilds; iguild++ ) {
          for (spp=1; spp<=Nspecies; spp++) {
               if (guildMembers(spp)== iguild) {
                  // sum up equilibr biomass for each guild
                  B0_guilds(area,iguild) += B0(area,spp);

              }
          }
      }
 }
  flagRamp.allocate("flagRamp");
  minExploitation.allocate(1,Nfleets,"minExploitation");
  maxExploitation.allocate(1,Nfleets,"maxExploitation");
  minMaxExploitation.allocate(1,2,"minMaxExploitation");
  minMaxThreshold.allocate(1,2,"minMaxThreshold");
  Nthresholds.allocate("Nthresholds");
  threshold_proportion.allocate(1,Nthresholds,"threshold_proportion");
  exploitation_levels.allocate(1,Nthresholds,"exploitation_levels");
  threshold_species.allocate(1,Nspecies,"threshold_species");
  AssessmentOn.allocate("AssessmentOn");
  speciesDetection.allocate("speciesDetection");
  LFI_size.allocate("LFI_size");
  scaleInitialN.allocate("scaleInitialN");
  effortScaled.allocate(1,Nareas,1,Nspecies,"effortScaled");
  discard_Coef.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nsizebins,"discard_Coef");
  discardSurvival_Coef.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nsizebins,"discardSurvival_Coef");
  predOrPrey.allocate(1,Nspecies,"predOrPrey");
  bandwidth_metric.allocate("bandwidth_metric");
  baseline_threshold.allocate("baseline_threshold");
  indicator_fishery_q.allocate(1,Nareas,1,Nfleets,1,Nspecies,"indicator_fishery_q");
 Nqpars = sum(indicator_fishery_q)-(Nfleets*Nareas);
  f_map.allocate(1,Nareas,1,Nfleets);
 dim2 = Nqpars;
 if (dim2 == 0) dim2 = 1;
  q_map.allocate(1,dim2,1,3);
 f_map = 0;
 q_map = 0;
 dum = 0;
 for(int area=1;area<=Nareas;area++) {
   for (int ifleet=1;ifleet<=Nfleets;ifleet++) {
     for (int species=1;species<=Nspecies;species++) {
       if (Nqpars >0) {
       if (f_map(area,ifleet)!=0 && indicator_fishery_q(area,ifleet,species) == 1) {
        dum += 1;
        q_map(dum,1) = area;
        q_map(dum,2) = species;
        q_map(dum,3) = ifleet;
       }
       }
       if (f_map(area,ifleet)==0 && indicator_fishery_q(area,ifleet,species) == 1) f_map(area,ifleet) = species;
     }
 
   } 
 }
 cout << "q par map" << endl;
 cout << Nqpars << endl;
 cout << f_map << endl;
 cout << q_map << endl;
  AR_parameters.allocate(1,3,"AR_parameters");
 rho_AR_Survey =  AR_parameters(1);
 rho_AR_Recruitment = AR_parameters(2);
 rho_AR_Catch = AR_parameters(3);
  sim_survey_error.allocate(1,Nareas,1,Nspecies,1,Nyrs);
  sim_recruit_error.allocate(1,Nareas,1,Nspecies,1,Nyrs);
  sim_catch_error.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nyrs);
  sim_extreme_recruit_error.allocate(1,Nareas,1,Nspecies,1,Nyrs);
  flagMSE.allocate("flagMSE");
  residentTime.allocate(1,Nareas,1,Nspecies,"residentTime");
  areaMortality.allocate(1,Nareas,1,Nspecies,"areaMortality");
  eof.allocate("eof");
  if(debug==1){
 cout<<"flagRamp: "<<endl<<flagRamp<<endl;
 cout<<"minExploitation: "<<endl<<minExploitation<<endl;
 cout<<"maxExploitation: "<<endl<<maxExploitation<<endl;
 cout<<"minMaxExploitation: "<<endl<<minMaxExploitation<<endl;
 cout<<"minMaxThreshold: "<<endl<<minMaxThreshold<<endl;
 cout<<"Nthresholds: "<<endl<<Nthresholds<<endl;
 cout<<"threshold_proportion: "<<endl<<threshold_proportion<<endl;
 cout<<"exploitation_levels: "<<endl<<exploitation_levels<<endl;
 cout<<"threshold_species: "<<endl<<threshold_species<<endl;
 cout<<"AssessmentOn: "<<endl<<AssessmentOn<<endl;
 cout<<"speciesDetection: "<<endl<<speciesDetection<<endl;
 cout<<"LFI_size: "<<endl<<LFI_size<<endl;
 cout<<"scaleInitialN: "<<endl<<scaleInitialN<<endl;
 cout<<"effortScaled: "<<endl<<effortScaled<<endl;
 cout<<"discard_Coef: "<<endl<<discard_Coef<<endl;
 cout<<"discardSurvival_Coef: "<<endl<<discardSurvival_Coef<<endl;
 cout<<"predOrPrey: "<<endl<<predOrPrey<<endl;
 cout<<"bandwidth_metric: "<<endl<<bandwidth_metric<<endl;
 cout<<"baseline_threshold: "<<endl<<baseline_threshold<<endl;
 cout<<"indicator_fishery_q: "<<endl<<indicator_fishery_q<<endl;
 cout<<"AR_parameters: "<<endl<<AR_parameters<<endl;
 cout<<"flagMSE: "<<endl<<flagMSE<<endl;
 cout<<"residentTime: "<<endl<<residentTime<<endl;
 cout<<"areaMortality: "<<endl<<areaMortality<<endl;
 cout<<"eof: "<<endl<<eof<<endl;
   }
ad_comm::change_datafile_name(datfilename);
  Nsurvey_obs.allocate("Nsurvey_obs");
cout << Nsurvey_obs << endl;
  obs_survey_biomass.allocate(1,Nsurvey_obs,1,5,"obs_survey_biomass");
  Nsurvey_size_obs.allocate("Nsurvey_size_obs");
 int ncol = Nsizebins+5;
  obs_survey_size.allocate(1,Nsurvey_size_obs,1,ncol,"obs_survey_size");
  Ncatch_obs.allocate("Ncatch_obs");
  obs_catch_biomass.allocate(1,Ncatch_obs,1,6,"obs_catch_biomass");
  Ncatch_size_obs.allocate("Ncatch_size_obs");
 ncol = Nsizebins+6;
  obs_catch_size.allocate(1,Ncatch_size_obs,1,ncol,"obs_catch_size");
  Ndietprop_obs.allocate("Ndietprop_obs");
 ncol = Nspecies+6;
  obs_dietprop.allocate(1,Ndietprop_obs,1,ncol,"obs_dietprop");
  if(debug==1){
 cout<<"Nsurvey_obs: "<<endl<<Nsurvey_obs<<endl;
 cout<<"obs_survey_biomass: "<<endl<<obs_survey_biomass<<endl;
 cout<<"Nsurvey_size_obs: "<<endl<<Nsurvey_size_obs<<endl;
 cout<<"obs_survey_size: "<<endl<<obs_survey_size<<endl;
 cout<<"Ncatch_obs: "<<endl<<Ncatch_obs<<endl;
 cout<<"obs_catch_biomass: "<<endl<<obs_catch_biomass<<endl;
 cout<<"Ncatch_size_obs: "<<endl<<Ncatch_size_obs<<endl;
 cout<<"obs_catch_size: "<<endl<<obs_catch_size<<endl;
 cout<<"Ndietprop_obs: "<<endl<<Ndietprop_obs<<endl;
 cout<<"obs_dietprop: "<<endl<<obs_dietprop<<endl;
   }
  if (debug == 1)
    {
    cout<<"Nyrs\n"<<Nyrs<<endl;
    cout<<"Nspecies\n"<<Nspecies<<endl;
    cout<<"Nsizebins\n"<<Nsizebins<<endl;
    cout<<"Nareas\n"<<Nareas<<endl;
    cout<<"Nfleets\n"<<Nfleets<<endl;
    cout<<"wtconv\n"<<wtconv<<endl;
    cout<<"Totsizebins\n"<<Totsizebins<<endl;
    cout<<"binwidth\n"<<binwidth<<endl;
    cout<<"lenwt_a\n"<<lenwt_a<<endl;
    cout<<"lenwt_b\n"<<lenwt_b<<endl;
    cout<<"lbinmax\n"<<lbinmax<<endl;
    cout<<"lbinmin\n"<<lbinmin<<endl;
    cout<<"lbinmidpt\n"<<lbinmidpt<<endl;
    cout<<"wtbinmax\n"<<wtbinmax<<endl;
    cout<<"wtbinmin\n"<<wtbinmin<<endl;
    cout<<"wtatlbinmidpt\n"<<wtatlbinmidpt<<endl;
    cout<<"binavgwt\n"<<binavgwt<<endl;
    cout<<"Nrecruitment_cov\n"<<Nrecruitment_cov<<endl;
    cout<<"Nmaturity_cov\n"<<Nmaturity_cov<<endl;
    cout<<"Ngrowth_cov\n"<<Ngrowth_cov<<endl;
    cout<<"recruitment_cov\n"<<recruitment_cov<<endl;
    cout<<"maturity_cov\n"<<maturity_cov<<endl;
    cout<<"growth_cov\n"<<growth_cov<<endl;
    cout<<"obs_survey_biomass\n"<<obs_survey_biomass<<endl;
    cout<<"obs_survey_size\n"<<obs_survey_size<<endl;
    cout<<"obs_catch_biomass\n"<<obs_catch_biomass<<endl;
    cout<<"obs_catch_size\n"<<obs_catch_size<<endl;    
    cout<<"obs_dietprop\n"<<obs_dietprop<<endl;        
    cout<<"mean_stomwt\n"<<mean_stomwt<<endl;
    cout<<"obs_temp\n"<<obs_temp<<endl;
    cout<<"recruitment_covwt\n"<<recruitment_covwt<<endl;
    cout<<"rectype\n"<<rectype<<endl;
    cout<<"stochrec\n"<<stochrec<<endl;
    cout<<"rec_alpha\n"<<rec_alpha<<endl;
    cout<<"rec_shape\n"<<rec_shape<<endl;
    cout<<"rec_beta\n"<<rec_beta<<endl;
    cout<<"fecund_d\n"<<fecund_d<<endl;
    cout<<"fecund_h\n"<<fecund_h<<endl;
    cout<<"fecund_theta\n"<<fecund_theta<<endl;
    cout<<"fecundity\n"<<fecundity<<endl;
    cout<<"maturity_nu\n"<<maturity_nu<<endl;
    cout<<"maturity_omega\n"<<maturity_omega<<endl;
    cout<<"maturity_covwt\n"<<maturity_covwt<<endl;
    cout<<"growth_psi\n"<<growth_psi<<endl;
    cout<<"growth_kappa\n"<<growth_kappa<<endl;
    cout<<"growth_covwt\n"<<growth_covwt<<endl;
    cout<<"vonB_Linf\n"<<vonB_Linf<<endl;
    cout<<"vonB_k\n"<<vonB_k<<endl;
    cout<<"growthtype (1 power, 2 power/covariates, 3 vonB, 4 vonB covariates)\n"<<growthtype<<endl;
    cout<<"growthprob_phi\n"<<growthprob_phi<<endl;
    cout<<"phimax\n"<<phimax<<endl;
    cout<<"Nstepsyr\n"<<Nstepsyr<<endl;
    cout<<"Tottimesteps\n"<<Tottimesteps<<endl;
    cout<<"intake_alpha\n"<<intake_alpha<<endl;
    cout<<"intake_beta\n"<<intake_beta<<endl;
    cout<<"intake\n"<<intake<<endl;
   // cout<<"M1ann\n"<<M1ann<<endl;
   // cout<<"M1\n"<<M1<<endl;
    cout<<"isprey\n"<<isprey<<endl;
    cout<<"Npred\n"<<Npred<<endl;
    cout<<"preferred_wtratio\n"<<preferred_wtratio<<endl;
    cout<<"sd_sizepref\n"<<sd_sizepref<<endl;
    cout<<"wtratio\n"<<wtratio<<endl;
    cout<<"sizepref\n"<<sizepref<<endl;
    //cout<<"suitability\n"<<suitability<<endl;
    cout<<"B0\n"<<B0<<endl;
    cout<<"Nguilds\n"<<Nguilds<<endl;
    cout<<"guildMembers\n"<<guildMembers<<endl;
    cout<<"AssessmentPeriod\n"<<AssessmentPeriod<<endl;
    cout<<"eof\n"<<eof<<endl;
    }
  if(eof != 54321) {cout<<"Stop, data input failed"<<endl<<"eof: "<<eof<<endl; exit(1);}
  if (debug == 1) {cout<<"\nManually exiting at end of data section..."<<endl;  exit(-1);}
}

void model_parameters::initializationfunction(void)
{
}

model_parameters::model_parameters(int sz,int argc,char * argv[]) : 
 model_data(argc,argv) , function_minimizer(sz)
{
  initializationfunction();
  effort_updated.allocate(1,Nareas,1,Nfleets,"effort_updated");
  #ifndef NO_AD_INITIALIZE
    effort_updated.initialize();
  #endif
  obs_effortAssess.allocate(1,Nareas,1,Nfleets,1,Nyrs,"obs_effortAssess");
  #ifndef NO_AD_INITIALIZE
    obs_effortAssess.initialize();
  #endif
obs_effortAssess = obs_effort;
  ln_yr1N.allocate(1,Nareas,1,Nspecies,1,Nsizebins,yr1Nphase,"ln_yr1N");
  yr1N.allocate(1,Nareas,1,Nspecies,1,Nsizebins,"yr1N");
  #ifndef NO_AD_INITIALIZE
    yr1N.initialize();
  #endif
  recruitment_alpha.allocate(1,Nareas,1,Nspecies,recphase,"recruitment_alpha");
  recruitment_shape.allocate(1,Nareas,1,Nspecies,recphase,"recruitment_shape");
  recruitment_beta.allocate(1,Nareas,1,Nspecies,recphase,"recruitment_beta");
  propmature.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"propmature");
  #ifndef NO_AD_INITIALIZE
    propmature.initialize();
  #endif
  eggprod.allocate(1,Nareas,1,Nspecies,1,Nyrs,"eggprod");
  #ifndef NO_AD_INITIALIZE
    eggprod.initialize();
  #endif
  ln_avg_recruitment.allocate(1,Nareas,1,Nspecies,avg_rec_phase,"ln_avg_recruitment");
  avg_recruitment.allocate(1,Nareas,1,Nspecies,"avg_recruitment");
  #ifndef NO_AD_INITIALIZE
    avg_recruitment.initialize();
  #endif
  recruitment_devs.allocate(1,Nareas,1,Nspecies,2,Nyrs,dev_rec_phase,"recruitment_devs");
  recruitment.allocate(1,Nareas,1,Nspecies,2,Nyrs,"recruitment");
  #ifndef NO_AD_INITIALIZE
    recruitment.initialize();
  #endif
  ln_recsigma.allocate(1,Nareas,1,Nspecies,recsigmaphase,"ln_recsigma");
  recsigma.allocate(1,Nareas,1,Nspecies,"recsigma");
  #ifndef NO_AD_INITIALIZE
    recsigma.initialize();
  #endif
  rec_procError.allocate(1,Nareas,1,Nspecies,1,Nyrs,"rec_procError");
  #ifndef NO_AD_INITIALIZE
    rec_procError.initialize();
  #endif
  avg_F.allocate(1,Nareas,1,Nfleets,avg_F_phase,"avg_F");
  F_devs.allocate(1,Nareas,1,Nfleets,1,Nyrs,dev_F_phase,"F_devs");
  Fyr.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nyrs,"Fyr");
  #ifndef NO_AD_INITIALIZE
    Fyr.initialize();
  #endif
  suitpreybio.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"suitpreybio");
  #ifndef NO_AD_INITIALIZE
    suitpreybio.initialize();
  #endif
cout << "Nprey " << Nprey << endl;
  vulnerability.allocate(1,Nareas,1,Nspecies,1,Nspecies,"vulnerability");
  #ifndef NO_AD_INITIALIZE
    vulnerability.initialize();
  #endif
  suitability.allocate(1,Nareas,1,Nspecies,1,Totsizebins,1,Nsizebins,"suitability");
  #ifndef NO_AD_INITIALIZE
    suitability.initialize();
  #endif
  biomass_prey_avail_no_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,1,Nprey,"biomass_prey_avail_no_size");
  #ifndef NO_AD_INITIALIZE
    biomass_prey_avail_no_size.initialize();
  #endif
  N.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"N");
  #ifndef NO_AD_INITIALIZE
    N.initialize();
  #endif
  Narea.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"Narea");
  #ifndef NO_AD_INITIALIZE
    Narea.initialize();
  #endif
  Nnotarea.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"Nnotarea");
  #ifndef NO_AD_INITIALIZE
    Nnotarea.initialize();
  #endif
  B.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"B");
  #ifndef NO_AD_INITIALIZE
    B.initialize();
  #endif
  F.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"F");
  #ifndef NO_AD_INITIALIZE
    F.initialize();
  #endif
  C.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"C");
  #ifndef NO_AD_INITIALIZE
    C.initialize();
  #endif
  Z.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"Z");
  #ifndef NO_AD_INITIALIZE
    Z.initialize();
  #endif
  M2.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"M2");
  #ifndef NO_AD_INITIALIZE
    M2.initialize();
  #endif
  eatN.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"eatN");
  #ifndef NO_AD_INITIALIZE
    eatN.initialize();
  #endif
  discardN.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"discardN");
  #ifndef NO_AD_INITIALIZE
    discardN.initialize();
  #endif
  otherDead.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"otherDead");
  #ifndef NO_AD_INITIALIZE
    otherDead.initialize();
  #endif
  D.allocate(1,Nareas,1,Nspecies,1,Tottimesteps,1,Nsizebins,"D");
  #ifndef NO_AD_INITIALIZE
    D.initialize();
  #endif
  fishsel_pars.allocate(1,2,1,Nfleets,fsphase,"fishsel_pars");
  fishsel_c.allocate(1,Nspecies,1,Nfleets,"fishsel_c");
  #ifndef NO_AD_INITIALIZE
    fishsel_c.initialize();
  #endif
  fishsel_d.allocate(1,Nspecies,1,Nfleets,"fishsel_d");
  #ifndef NO_AD_INITIALIZE
    fishsel_d.initialize();
  #endif
  fishsel.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nsizebins,"fishsel");
  #ifndef NO_AD_INITIALIZE
    fishsel.initialize();
  #endif
  Ffl.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Tottimesteps,1,Nsizebins,"Ffl");
  #ifndef NO_AD_INITIALIZE
    Ffl.initialize();
  #endif
  Dfl.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Tottimesteps,1,Nsizebins,"Dfl");
  #ifndef NO_AD_INITIALIZE
    Dfl.initialize();
  #endif
  Cfl.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Tottimesteps,1,Nsizebins,"Cfl");
  #ifndef NO_AD_INITIALIZE
    Cfl.initialize();
  #endif
  ln_fishery_q.allocate(1,Nqpars,fqphase,"ln_fishery_q");
  fishery_q.allocate(1,Nareas,1,Nspecies,1,Nfleets,"fishery_q");
  #ifndef NO_AD_INITIALIZE
    fishery_q.initialize();
  #endif
  mean_guild_fishery_q.allocate(1,Nareas,1,Nguilds,1,Nfleets,"mean_guild_fishery_q");
  #ifndef NO_AD_INITIALIZE
    mean_guild_fishery_q.initialize();
  #endif
  ln_survey_q.allocate(1,Nsurveys,1,Nspecies,-30,2,sqphase,"ln_survey_q");
  survey_q.allocate(1,Nsurveys,1,Nspecies,"survey_q");
  #ifndef NO_AD_INITIALIZE
    survey_q.initialize();
  #endif
  survey_selpars.allocate(1,2,1,Nsurveys,ssphase,"survey_selpars");
  survey_sel.allocate(1,Nsurveys,1,Nspecies,1,Nsizebins,"survey_sel");
  #ifndef NO_AD_INITIALIZE
    survey_sel.initialize();
  #endif
  avByr.allocate(1,Nareas,1,Nspecies,1,Nyrs,"avByr");
  #ifndef NO_AD_INITIALIZE
    avByr.initialize();
  #endif
  SSB.allocate(1,Nareas,1,Nspecies,1,Nyrs,"SSB");
  #ifndef NO_AD_INITIALIZE
    SSB.initialize();
  #endif
  eaten_biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"eaten_biomass");
  #ifndef NO_AD_INITIALIZE
    eaten_biomass.initialize();
  #endif
  discard_biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"discard_biomass");
  #ifndef NO_AD_INITIALIZE
    discard_biomass.initialize();
  #endif
  otherDead_biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"otherDead_biomass");
  #ifndef NO_AD_INITIALIZE
    otherDead_biomass.initialize();
  #endif
  total_biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"total_biomass");
  #ifndef NO_AD_INITIALIZE
    total_biomass.initialize();
  #endif
  eaten_biomass_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"eaten_biomass_size");
  #ifndef NO_AD_INITIALIZE
    eaten_biomass_size.initialize();
  #endif
  discard_biomass_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"discard_biomass_size");
  #ifndef NO_AD_INITIALIZE
    discard_biomass_size.initialize();
  #endif
  otherDead_biomass_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"otherDead_biomass_size");
  #ifndef NO_AD_INITIALIZE
    otherDead_biomass_size.initialize();
  #endif
  total_biomass_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"total_biomass_size");
  #ifndef NO_AD_INITIALIZE
    total_biomass_size.initialize();
  #endif
  catch_biomass_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"catch_biomass_size");
  #ifndef NO_AD_INITIALIZE
    catch_biomass_size.initialize();
  #endif
  predation_mortality.allocate(1,Nareas,1,Nspecies,1,Nyrs,"predation_mortality");
  #ifndef NO_AD_INITIALIZE
    predation_mortality.initialize();
  #endif
  fishing_mortality.allocate(1,Nareas,1,Nspecies,1,Nyrs,"fishing_mortality");
  #ifndef NO_AD_INITIALIZE
    fishing_mortality.initialize();
  #endif
  predation_mortality_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"predation_mortality_size");
  #ifndef NO_AD_INITIALIZE
    predation_mortality_size.initialize();
  #endif
  fishing_mortality_size.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"fishing_mortality_size");
  #ifndef NO_AD_INITIALIZE
    fishing_mortality_size.initialize();
  #endif
  catch_biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"catch_biomass");
  #ifndef NO_AD_INITIALIZE
    catch_biomass.initialize();
  #endif
  fleet_catch_biomass.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nyrs,"fleet_catch_biomass");
  #ifndef NO_AD_INITIALIZE
    fleet_catch_biomass.initialize();
  #endif
  resid_bio.allocate(1,Nareas,1,Nspecies,1,Nyrs,"resid_bio");
  #ifndef NO_AD_INITIALIZE
    resid_bio.initialize();
  #endif
  totcatch_fit.allocate(1,Nareas,1,Nspecies,"totcatch_fit");
  #ifndef NO_AD_INITIALIZE
    totcatch_fit.initialize();
  #endif
  catchcomp_fit.allocate(1,Nareas,1,Nspecies,"catchcomp_fit");
  #ifndef NO_AD_INITIALIZE
    catchcomp_fit.initialize();
  #endif
  totbio_fit.allocate(1,Nareas,1,Nspecies,"totbio_fit");
  #ifndef NO_AD_INITIALIZE
    totbio_fit.initialize();
  #endif
  biocomp_fit.allocate(1,Nareas,1,Nspecies,"biocomp_fit");
  #ifndef NO_AD_INITIALIZE
    biocomp_fit.initialize();
  #endif
  pred_catch_biomass.allocate(1,Ncatch_obs,"pred_catch_biomass");
  #ifndef NO_AD_INITIALIZE
    pred_catch_biomass.initialize();
  #endif
  resid_catch.allocate(1,Ncatch_obs,"resid_catch");
  #ifndef NO_AD_INITIALIZE
    resid_catch.initialize();
  #endif
  nll_catch.allocate(1,Ncatch_obs,"nll_catch");
  #ifndef NO_AD_INITIALIZE
    nll_catch.initialize();
  #endif
 int Nsize_obs = 0;
 for (int i=1;i<=Ncatch_size_obs;i++) {
    for (int ilen=1;ilen<=Nsizebins;ilen++) 
      if (obs_catch_size(i,6+ilen)>=0) Nsize_obs += 1;
 }
  pred_catch_size.allocate(1,Nsize_obs,"pred_catch_size");
  #ifndef NO_AD_INITIALIZE
    pred_catch_size.initialize();
  #endif
  nll_catch_size.allocate(1,Nsize_obs,"nll_catch_size");
  #ifndef NO_AD_INITIALIZE
    nll_catch_size.initialize();
  #endif
  pred_survey_index.allocate(1,Nsurvey_obs,"pred_survey_index");
  #ifndef NO_AD_INITIALIZE
    pred_survey_index.initialize();
  #endif
  resid_survey.allocate(1,Nsurvey_obs,"resid_survey");
  #ifndef NO_AD_INITIALIZE
    resid_survey.initialize();
  #endif
  nll_survey.allocate(1,Nsurvey_obs,"nll_survey");
  #ifndef NO_AD_INITIALIZE
    nll_survey.initialize();
  #endif
 Nsize_obs = 0;
 for (int i=1;i<=Nsurvey_size_obs;i++) {
    for (int ilen=1;ilen<=Nsizebins;ilen++) 
      if (obs_survey_size(i,5+ilen)>=0) Nsize_obs += 1;
 }
  pred_survey_size.allocate(1,Nsize_obs,"pred_survey_size");
  #ifndef NO_AD_INITIALIZE
    pred_survey_size.initialize();
  #endif
  nll_survey_size.allocate(1,Nsize_obs,"nll_survey_size");
  #ifndef NO_AD_INITIALIZE
    nll_survey_size.initialize();
  #endif
 Nsize_obs = 0;
 for (int i=1;i<=Ndietprop_obs;i++) {
    for (int ilen=1;ilen<=Nspecies;ilen++) 
      if (obs_dietprop(i,5+ilen)>=0) Nsize_obs += 1;
    if (obs_dietprop(i,6+Nspecies)>=0) Nsize_obs += 1;
 }
  pred_dietprop.allocate(1,Nsize_obs,"pred_dietprop");
  #ifndef NO_AD_INITIALIZE
    pred_dietprop.initialize();
  #endif
  nll_dietprop.allocate(1,Nsize_obs,"nll_dietprop");
  #ifndef NO_AD_INITIALIZE
    nll_dietprop.initialize();
  #endif
 Nsize_obs = Nspecies*Nareas*Nyrs;
  recdev.allocate(1,Nsize_obs,"recdev");
  #ifndef NO_AD_INITIALIZE
    recdev.initialize();
  #endif
  nll_recruit.allocate("nll_recruit");
  #ifndef NO_AD_INITIALIZE
  nll_recruit.initialize();
  #endif
  index_Simpsons_N.allocate(1,Nareas,1,Nyrs,"index_Simpsons_N");
  #ifndef NO_AD_INITIALIZE
    index_Simpsons_N.initialize();
  #endif
  index_Simpsons_Nrecip.allocate(1,Nareas,1,Nyrs,"index_Simpsons_Nrecip");
  #ifndef NO_AD_INITIALIZE
    index_Simpsons_Nrecip.initialize();
  #endif
  index_Simpsons_C.allocate(1,Nareas,1,Nyrs,"index_Simpsons_C");
  #ifndef NO_AD_INITIALIZE
    index_Simpsons_C.initialize();
  #endif
  index_Simpsons_Crecip.allocate(1,Nareas,1,Nyrs,"index_Simpsons_Crecip");
  #ifndef NO_AD_INITIALIZE
    index_Simpsons_Crecip.initialize();
  #endif
  index_LFI_Biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_LFI_Biomass");
  #ifndef NO_AD_INITIALIZE
    index_LFI_Biomass.initialize();
  #endif
  index_LFI_Catch.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_LFI_Catch");
  #ifndef NO_AD_INITIALIZE
    index_LFI_Catch.initialize();
  #endif
  index_LFI_N.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_LFI_N");
  #ifndef NO_AD_INITIALIZE
    index_LFI_N.initialize();
  #endif
  LFI_threshold.allocate(1,Nareas,1,Tottimesteps,"LFI_threshold");
  #ifndef NO_AD_INITIALIZE
    LFI_threshold.initialize();
  #endif
  prob_species.allocate(1,Nspecies,"prob_species");
  #ifndef NO_AD_INITIALIZE
    prob_species.initialize();
  #endif
  LF_Biomass.allocate("LF_Biomass");
  #ifndef NO_AD_INITIALIZE
  LF_Biomass.initialize();
  #endif
  B_total.allocate(1,Nspecies,"B_total");
  #ifndef NO_AD_INITIALIZE
    B_total.initialize();
  #endif
  B_largestClass.allocate(1,Nspecies,"B_largestClass");
  #ifndef NO_AD_INITIALIZE
    B_largestClass.initialize();
  #endif
  N_tot.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"N_tot");
  #ifndef NO_AD_INITIALIZE
    N_tot.initialize();
  #endif
  B_tot.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"B_tot");
  #ifndef NO_AD_INITIALIZE
    B_tot.initialize();
  #endif
  C_tot.allocate(1,Nareas,1,Nspecies,1,Nyrs,1,Nsizebins,"C_tot");
  #ifndef NO_AD_INITIALIZE
    C_tot.initialize();
  #endif
  Cfl_tot.allocate(1,Nareas,1,Nspecies,1,Nfleets,1,Nyrs,1,Nsizebins,"Cfl_tot");
  #ifndef NO_AD_INITIALIZE
    Cfl_tot.initialize();
  #endif
  index_predBio.allocate(1,Nareas,1,Nyrs,"index_predBio");
  #ifndef NO_AD_INITIALIZE
    index_predBio.initialize();
  #endif
  index_preyBio.allocate(1,Nareas,1,Nyrs,"index_preyBio");
  #ifndef NO_AD_INITIALIZE
    index_preyBio.initialize();
  #endif
  index_predToPreyRatio.allocate(1,Nareas,1,Nyrs,"index_predToPreyRatio");
  #ifndef NO_AD_INITIALIZE
    index_predToPreyRatio.initialize();
  #endif
  index_plankToPiscRatio.allocate(1,Nareas,1,Nyrs,"index_plankToPiscRatio");
  #ifndef NO_AD_INITIALIZE
    index_plankToPiscRatio.initialize();
  #endif
  index_catch.allocate(1,bandwidth_metric,"index_catch");
  #ifndef NO_AD_INITIALIZE
    index_catch.initialize();
  #endif
  index_biomass.allocate(1,bandwidth_metric,"index_biomass");
  #ifndef NO_AD_INITIALIZE
    index_biomass.initialize();
  #endif
  index_stdev_catch.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_stdev_catch");
  #ifndef NO_AD_INITIALIZE
    index_stdev_catch.initialize();
  #endif
  index_stdev_biomass.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_stdev_biomass");
  #ifndef NO_AD_INITIALIZE
    index_stdev_biomass.initialize();
  #endif
  index_ExploitationRate.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_ExploitationRate");
  #ifndef NO_AD_INITIALIZE
    index_ExploitationRate.initialize();
  #endif
  index_SystemExploitationRate.allocate(1,Nareas,1,Nyrs,"index_SystemExploitationRate");
  #ifndef NO_AD_INITIALIZE
    index_SystemExploitationRate.initialize();
  #endif
  exploitation_update.allocate(1,Nareas,1,Nfleets,1,Nyrs,"exploitation_update");
  #ifndef NO_AD_INITIALIZE
    exploitation_update.initialize();
  #endif
  index_status_species.allocate(1,Nareas,1,Nspecies,1,Nyrs,"index_status_species");
  #ifndef NO_AD_INITIALIZE
    index_status_species.initialize();
  #endif
  index_status_guild.allocate(1,Nareas,1,Nguilds,1,Nyrs,"index_status_guild");
  #ifndef NO_AD_INITIALIZE
    index_status_guild.initialize();
  #endif
  exploitationLevelSpecies.allocate(1,Nareas,1,Nspecies,"exploitationLevelSpecies");
  #ifndef NO_AD_INITIALIZE
    exploitationLevelSpecies.initialize();
  #endif
  exploitationLevelGuild.allocate(1,Nareas,1,Nguilds,"exploitationLevelGuild");
  #ifndef NO_AD_INITIALIZE
    exploitationLevelGuild.initialize();
  #endif
  newExploitationLevel.allocate(1,Nareas,1,Nfleets,"newExploitationLevel");
  #ifndef NO_AD_INITIALIZE
    newExploitationLevel.initialize();
  #endif
  objfun_areaspp.allocate(1,Nareas,1,Nspecies,"objfun_areaspp");
  #ifndef NO_AD_INITIALIZE
    objfun_areaspp.initialize();
  #endif
  rec_EventError.allocate(1,Nareas,1,Nspecies,1,Nyrs,"rec_EventError");
  #ifndef NO_AD_INITIALIZE
    rec_EventError.initialize();
  #endif
  objfun.allocate("objfun");
  prior_function_value.allocate("prior_function_value");
  likelihood_function_value.allocate("likelihood_function_value");
    if (debug == 2)
      {
       cout<<"rectype\n"<<rectype<<endl;
       cout<<"recruitment_alpha\n"<<recruitment_alpha<<endl;
       cout<<"recruitment_shape\n"<<recruitment_shape<<endl;
       cout<<"recruitment_beta\n"<<recruitment_beta<<endl;
      //cout<<"aAge1\n"<<aAge1<<endl<<"aFt\n"<<aFt<<endl;
      //for (i=1; i<=nsp; i++)  {
      //  cout<<"species: "<<i<<endl;
      //  cout<<"idAge1\n"<<idAge1(i)<<endl<<"idFt\n"<<idFt(i)<<endl;
      //  cout<<"iagesel\n"<<iagesel(i)<<endl<<"iFICsel\n"<<iFICsel(i)<<endl;
      //  cout<<"iYr1\n"<<iYr1(i)<<endl<<endl;
      //  }
      //cout<<"iRho\n"<<iRho<<endl;
      cout<<"\nManually exiting at the end of the parameter section...\n"<<endl;
      exit(-1);
      }
  ln_M1ann.allocate(1,Nareas,1,Nspecies,m1_phase,"ln_M1ann");
  M1.allocate(1,Nareas,1,Nspecies,1,Nsizebins,"M1");
  #ifndef NO_AD_INITIALIZE
    M1.initialize();
  #endif
  ln_otherFood_base.allocate(oF1_phase,"ln_otherFood_base");
  otherFood_dev.allocate(1,Npred-1,oFdev_phase,"otherFood_dev");
  otherFood.allocate(1,Nspecies,"otherFood");
  #ifndef NO_AD_INITIALIZE
    otherFood.initialize();
  #endif
}

void model_parameters::preliminary_calculations(void)
{

#if defined(USE_ADPVM)

  admaster_slave_variable_interface(*this);

#endif
  recruitment_alpha = rec_alpha;
  recruitment_shape = rec_shape;
  recruitment_beta = rec_beta;
  // for (int i=1;i<=Nsurveys;i++)
  //  for (int k=1;k<=Nspecies;k++)
  //  for (int j=1;j<=Nsizebins;j++)
  // // need to add survey selectivity at length, but for now set at 1 for all.
  //     survey_sel(i,k,j) = 1.;
  //propmature do once for whole cov time series, estimate maturity params, covwt, or both in later phases
  //propmature = 1/(1+exp(-(maturity_nu+maturity_omega*lbinmidpt)*sum(maturity_covwt*maturity_cov)))
  // first calculate the covarate part to add. andybeet
  for (spp=1; spp<=Nspecies; spp++) {
      for (yr=1; yr<=Nyrs; yr++) {
          for (int icov=1; icov<=Nmaturity_cov;icov++) {
              covariates_M(spp,yr) += maturity_covwt(spp,icov)*maturity_cov(icov,yr);
          }
      }
  }
}

void model_parameters::userfunction(void)
{
  objfun =0.0;
  transform_parameters(); if (debug == 4) {cout<<"completed parameter transform"<<endl;}
  for (area=1; area<=Nareas; area++){
   for(spp=1; spp<=Nspecies; spp++){
          M1(area, spp)  = 1.0 - pow((1.0 - mfexp(ln_M1ann(area, spp))), (1.0 / Nstepsyr)) ; //scale for steps per year to equal annual input from dat  
    }
   }
  // Other Food - fill in the other food vector
   otherFood = 0.;
   int j=0;
   for(spp=1; spp<=Nspecies; spp++){
    if (sum(extract_column(isprey(1),spp))>0) {
      if (j==0) otherFood(spp) = mfexp(ln_otherFood_base);
      if (j>=1) otherFood(spp) = mfexp(ln_otherFood_base + otherFood_dev(j));
      j = j+1;
    }
    else
    {otherFood(spp) = mfexp(ln_otherFood_base);}   //GF 11/14/22 added trap to avoid 0 other food for non-predators, need to check full implications of why this is needed [nans in M2 calcs otherwise but want to check it's not using this info and this is just a product of looping over all species]
   }
  //cout << "other food" << endl;
  //cout << otherFood << endl;
  //suitability calcs - previously in data section
    //suitability = sizepref * vulnerability
    for (area=1; area<=Nareas; area++){
      for (pred=1; pred<=Nspecies; pred++){
        for(prey=1; prey<=Nspecies; prey++){
                      double sumOfSizePrefs = sum(sizepref(area,pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins));
        suitability(area, pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins) =
              sizepref(area, pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins)*
            //  (sizepref(area, pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins)/sumOfSizePrefs)* // normalize rates
              vulnerability(area, prey, pred);
               }
    }
    }
  //ofstream popout("popstructure.out");
  //ofstream recout("recstructure.out");
  calc_initial_states();  if (debug == 4) {cout<<"completed Initial States"<<endl;}
  yrct=1;
  for (t=1; t<=Tottimesteps; t++)
     {
		//if (debug == 3) {cout<<yrct<<" "<<t<<endl;}
                if (t>1 && (Nstepsyr == 1 || t % Nstepsyr == 1)) {yrct++;} // first time step in new year = > increment year
                if (t>1) calc_update_N(); // N(t) = N(t-1)
                  // add recruits at start of year.  update N to add recruits to bin 1
                if (t>1) calc_recruitment(); if (debug == 4) {cout<<"completed Recruitment"<<endl;}
                //if (t % Nstepsyr == 1) recout << yrct << " " << recruitment(1,2,yrct) << endl;
                calc_available_N();
                calc_pred_mortality(); if (debug == 4) {cout<<"completed Predation Mortality"<<endl;}
                calc_fishing_mortality(); if (debug == 4) {cout<<"completed Fishing Mortality"<<endl;}
                calc_total_mortality(); // We calculate Z(t) = M1 + M2 + F
    //cout << t << " " << Z(1,1,t) << endl;
    //cout << t << " " << Z(1,1,t) << " " << M1(1,1) << " " << M2(1,1,t) << " " << F(1,1,t) << " " << D(1,1,t) << endl;
		calc_catch_etc(); if (debug == 4) {cout<<"completed Catch"<<endl;} // split F among fleets
    //for (int spp=1;spp<=Nspecies;spp++)
		//popout << t << " " << spp << " " << N(1,spp,t) << " " << Z(1,spp,t) << " " << M1(1,spp) << " " << M2(1,spp,t) << " " << F(1,spp,t) << " " << D(1,spp,t) << endl;
    calc_pop_dynamics(); if (debug == 4) {cout<<"completed Pop Dynamics"<<endl;} // update N - death + growth
                calc_SSB();
		calc_movement(); if (debug == 4) {cout<<"completed Movement"<<endl;}
                calc_survey_abundance();  if (debug == 4) {cout<<"completed Survey Abundance"<<endl;}
                // // enter assessment module if turned on in data file, if end of year, if curent year is a multiple of assessmentPeriod
                // if (AssessmentOn == 1) {
                //  // if end of year and enough years have passed to perform assessment.
                //  // every AssessmentPeriod we monitor stocks and adjust the effort for the future
                //   if ((t % Nstepsyr == 0) && (yrct <= (Nyrs-AssessmentPeriod))) {
                //    if( yrct % AssessmentPeriod == 0) {
                //     if (flagRamp == 0) {    // step function
                //      calc_assessment_strategy_Step(); if (debug == 4) {cout<<"completed calc_assessment_strategy"<<endl;}
                //     } else { // linear function
                //      calc_assessment_linear_independent_fleet(); if (debug == 4) {cout<<"completed calc_assessment_strategy"<<endl;}
                //     }
                //    }
                //   }
                // }
	 }
  if (debug == 4) {cout<<"completed timestep loop"<<endl;}
  calculate_predicted_values(); {cout<<"completed predicted values for surveys"<<endl;}
  evaluate_the_objective_function(); if (debug == 4) {cout<<"completed Log Likelihood"<<endl;}
 //  // calculates the mean q for each fleet ignoring zero q's.
 //  // this is used to update effort when an assessment dictates
 // for (area=1; area<=Nareas; area++) {
 //           for (int ifleet=1;ifleet<=Nfleets;ifleet++) {
 //             int icount = 0;
 //             mean_fishery_q(area,ifleet) = 0;
 //               for (spp=1; spp<=Nspecies; spp++) {
 //                    if (fishery_q(area,spp,ifleet) < 1e-29) {
 //                      //ignore
 //                    } else {
 //                       icount = icount + indicator_fishery_q(area,ifleet,spp);
 //                       mean_fishery_q(area,ifleet) += indicator_fishery_q(area,ifleet,spp)*fishery_q(area,spp,ifleet);
 //                    }
 //              }
 //              if (icount == 0) { // then all q's are < 1-e29. This occurs during testing a new fleet with no information
 //                 mean_fishery_q(area,ifleet) = 0;
 //              } else {
 //                 mean_fishery_q(area,ifleet) =  mean_fishery_q(area,ifleet)/icount;
 //              }
 //          }
 // }
}

void model_parameters::transform_parameters(void)
{
  yr1N = mfexp(ln_yr1N);
  avg_recruitment = mfexp(ln_avg_recruitment);
  recsigma = mfexp(ln_recsigma);
  //fishery_q = mfexp(ln_fishery_q);
  fishery_q.initialize();
  // fishery catchabilities  //gavinfay March 2022
  for (area=1;area<=Nareas;area++) {
    for (int ifleet=1;ifleet<=Nfleets;ifleet++) {
      for (int species=1;species<=Nspecies;species++) fishery_q(area,species,ifleet) = 1e-15; //0.;
      fishery_q(area,f_map(area,ifleet),ifleet) = 1.;
    }
   }
  if (Nqpars > 0) {
  for (int ipar=1;ipar<=Nqpars;ipar++) {
    fishery_q(q_map(ipar,1),q_map(ipar,2),q_map(ipar,3)) = mfexp(ln_fishery_q(ipar));
  }
  }
  //cout << "fishery q" << endl;
  //cout << fishery_q << endl;
  //exit(-1);
  //fishery selectivity
  for (int species=1;species<=Nspecies;species++) {
   for (int ifleet=1;ifleet<=Nfleets;ifleet++) {
     fishsel_c(species,ifleet) = mfexp(fishsel_pars(1,ifleet));
     fishsel_d(species,ifleet) = mfexp(fishsel_pars(2,ifleet));
   }
  }
  //cout << "fishery selectivit pars" << endl;
  //cout << fishsel_c << endl;
  //cout << fishsel_d << endl;
  //exit(-1);
  dvariable neglog19 = -1.*log(19.);
  for (int i=1;i<=Nsurveys;i++)
   for (int k=1;k<=Nspecies;k++) {
   for (int j=1;j<=Nsizebins;j++) {
  // need to add survey selectivity at length, but for now set at 1 for all.
  //survey_sel(i,k,j) = 1/(1 + mfexp(-1.*mfexp(survey_selpars(1,i))*(lbinmidpt(k,j)-mfexp(survey_selpars(2,i)))));
  survey_sel(i,k,j) = 1./(1.+mfexp(neglog19*(lbinmidpt(k,j)-mfexp(survey_selpars(1,i)))/mfexp(survey_selpars(2,i))));
                                     }
    survey_sel(i,k) /= max(survey_sel(i,k));
    }
   survey_q = mfexp(ln_survey_q);
  // surv_sigma = mfexp(ln_surv_sigma);
  // catch_sigma = mfexp(ln_catch_sigma);
  //vulnerabilities
  int iprey = 0;
  //cout << "vulnerability" << endl;
  //cout << logit_vuln << endl;
  //cout << vulnerability << endl;
  //exit(-1);
}

void model_parameters::calc_initial_states(void)
{
  propmature.initialize();
  eggprod.initialize();
  recruitment.initialize();
  rec_procError.initialize();
  suitpreybio.initialize();
  Fyr.initialize();
  fishsel.initialize(); Ffl.initialize(); Dfl.initialize(); Cfl.initialize();
  N.initialize(); B.initialize(); F.initialize(); D.initialize(); C.initialize(); Narea.initialize();Nnotarea.initialize();
  Z.initialize(); M2.initialize(); eatN.initialize(); otherDead.initialize();discardN.initialize();
  avByr.initialize(); SSB.initialize();
  Cfl_tot.initialize(); C_tot.initialize();
  N_tot.initialize(); B_tot.initialize();
  eaten_biomass.initialize();
  otherDead_biomass.initialize();
  discard_biomass.initialize();
  // surv_obsError.initialize();
  // catch_obsError.initialize();
  // est_survey_biomass.initialize(); est_catch_biomass.initialize();
  //  // andy beet
  // est_survey_guild_biomass.initialize();
  // est_fleet_catch_guild_biomass.initialize();
  // est_catch_guild_biomass.initialize();
  // est_survey_biomass_assessment.initialize();
  // est_fleet_catch_guild_assessment.initialize();
  covariates_M.initialize();
  index_predBio.initialize();
  index_preyBio.initialize();
  index_predToPreyRatio.initialize();
  index_plankToPiscRatio.initialize();
  exploitation_update.initialize();
  catchToDiscardsSpecies.initialize(); catchToDiscardsGuild.initialize();
  eaten_biomass_size.initialize();
  otherDead_biomass_size.initialize();
  discard_biomass_size.initialize();
  total_biomass_size.initialize();
  catch_biomass_size.initialize();
  rec_EventError.initialize();
  //andybeet
  fleet_catch_biomass.initialize(); //est_fleet_catch_biomass.initialize();
  catch_biomass.initialize();
  index_stdev_catch.initialize();
  index_stdev_biomass.initialize();
  index_status_species.initialize();
  index_status_guild.initialize();
  //gavinfay
  biomass_prey_avail_no_size.initialize();
  totcatch_fit.initialize(); catchcomp_fit.initialize();
  totbio_fit.initialize(); biocomp_fit.initialize();
  //need year 1 N to do recruitment, pred mort, N for following years
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
         N(area, spp, 1) = yr1N(area, spp)*scaleInitialN;
         B(area, spp, 1) = wtconv*elem_prod(N(area, spp, 1),binavgwt(spp));
         avByr(area, spp, 1) = sum(B(area,spp,1))/Nstepsyr;
      }
  }
  // //propmature do once for whole cov time series, estimate maturity params, covwt, or both in later phases
  // //propmature = 1/(1+exp(-(maturity_nu+maturity_omega*lbinmidpt)*sum(maturity_covwt*maturity_cov)))
  // // first calculate the covarate part to add. andybeet
  // for (spp=1; spp<=Nspecies; spp++) {
  //     for (yr=1; yr<=Nyrs; yr++) {
  //         for (int icov=1; icov<=Nmaturity_cov;icov++) {
  //             covariates_M(spp,yr) += maturity_covwt(spp,icov)*maturity_cov(icov,yr);
  //         }
  //     }
  // }
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
		for(yr=1; yr<=Nyrs; yr++){
                   for (int isizebin=1; isizebin<=Nsizebins; isizebin++) {
                    // make an exception for dogfish, (species 1). SR relationship used only females. therefore SSB should only use females.
                    // females considered to be only members of largest size class and only class that can reproduce
                    // this isn't smart coding. ideally we'd want a function that would create this and we'd just pass parameter values in dat file
                     if ((spp == 1) && (isizebin < Nsizebins)) {
                        propmature(area,spp,yr,isizebin) = 0;
                     } else if ((spp == 1) && (isizebin == Nsizebins)) {
                        propmature(area,spp,yr,isizebin) = 1;// eventually code for covariates on dogfish
                     } else {
			propmature(area,spp,yr,isizebin) = 1/(1+mfexp(-1.*(maturity_nu(area, spp) +
                                          maturity_omega(area, spp)*lbinmidpt(spp,isizebin)) +
                                          covariates_M(spp,yr)));
                    }
                   }
		}
    }
  }
  //as long as growth is fit outside the model and transition probs done once at the beginning, could move here
  //fill F arrays; either start with avg F and devs by fleet, or calculate from q and effort by fleet
  // effort is scaled by species depending on how S-R data was assembled. GB or region wide
  for (int iyr =1; iyr<=Nyrs; iyr++) {
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
	  for(fleet=1; fleet<=Nfleets; fleet++){
          //fill Fyr array with area, species, fleet, year specific Fs
          // Fyr(area,spp,fleet) = avg_F(area,spp,fleet) + F_devs(spp,fleet); //WARNING ONLY WORKS WITH 1 AREA:REDO
            Fyr(area,spp,fleet,iyr) = fishery_q(area,spp,fleet)*mfexp(avg_F(area,fleet)+F_devs(area,fleet,iyr));  //gavinfay March 2022 - modding for F
            //cout << iyr << " " << area << " " << spp << " " << fleet << " " << Fyr(area,spp,fleet,iyr) << endl;
      }
    }
  }
  }
  //exit(-1);
    // now given the distribution of errors for extreme events we calculate the error
    //sim_extreme_recruit_error
   //////////// HERE /////////////////////
  if (debug == 15){
    cout<<"Ninit\n"<<N<<endl;
    cout<<"propmature\n"<<propmature<<endl;
    cout<<"Fyr\n"<<Fyr<<endl;
    // cout<<"surv_obsError\n"<<surv_obsError<<endl;
    // cout<<"catch_obsError\n"<<catch_obsError<<endl;
    cout<<"rec_procError\n"<<rec_procError<<endl;
    cout<<endl<<"manually exiting after calc_initial_states...\n"<<endl;
    exit(-1);
  }
  //other covariate sums here too? time series will be input
}

void model_parameters::calc_update_N(void)
{
 for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
            for(int isize=1; isize<=Nsizebins; isize++){
               N(area,spp,t,isize) = N(area,spp,t-1,isize);
            }
         }
  }
}

void model_parameters::calc_recruitment(void)
{
  //recruitment(t) =  recruitment_alpha  * pow (egg production(t-1),recruitment_shape) *
  //              exp(-recruitment_beta * egg production(t-1) +
  //              sumover_?(recruitment_covwt * recruitment_cov(t)))
  if ((Nstepsyr == 1 || t % Nstepsyr == 1) && (yrct <= Nyrs)) {  // recruits enter at start of year
    // simulate a vector of size Nspecies from uniform distribution between 0, 1 - probabilities
    // if prob < threshold then extreme event occurs and we sample from alternative distribution otherwise from ricker, beverton etc
    for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
		// switch (rectype(spp)){
  //         case 1:	  				//egg production based recruitment, 3 par gamma (Ricker-ish)
		// 	eggprod(area,spp)(yrct-1) /= Nstepsyr; //average egg production for a single "spawning" timestep
		// 	//eggprod(area,spp)(yrct) = recruitment_shape(area,spp)/recruitment_beta(area,spp);
		// 	recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * pow(eggprod(area,spp)(yrct-1), recruitment_shape(area,spp)) *
  //                                         mfexp(-recruitment_beta(area,spp) * eggprod(area,spp)(yrct-1) +
  //                                              recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
  //     //cout << spp << " " << yrct << " " << recruitment(area,spp)(yrct) << " " <<
  //     //recruitment_alpha(area,spp) << " " << eggprod(area,spp)(yrct-1) << " " << recruitment_shape(area,spp) << " " <<
  //     //                                    recruitment_beta(area,spp) << " " << 
  //     //                                         recruitment_covwt(spp) << " " << recruitment_cov(yrct-1) << endl;
  //     //exit(-1);
		//   break;
	 //  case 2:                   //SSB based recruitment, 3 par Deriso-Schnute; see Quinn & Deriso 1999 p 95
		//     //SSB(area,spp)(yrct) /= Nstepsyr; //use? average spawning stock bio for a single "spawning" timestep, now SSB is at time t
  //                       recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1) *
  //                                          pow((1-recruitment_beta(area,spp)*recruitment_shape(area,spp)*SSB(area,spp)(yrct-1)),
  //                                           (1/recruitment_shape(area,spp)));
  //                                    //"effective recruitment" with env covariates; see Quinn & Deriso 1999 p 92
  //                       recruitment(area,spp)(yrct) *= mfexp(-recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
		//   break;
  //         case 3:	  				//SSB based recruitment, 3 par gamma (Ricker-ish)
		// 	//SSB(area,spp)(yrct) /= Nstepsyr; //average SSB for a single "spawning" timestep, now SSB is at time t
		// 	recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * pow(SSB(area,spp)(yrct-1), recruitment_shape(area,spp)) *
  //                                         mfexp(-recruitment_beta(area,spp) * SSB(area,spp)(yrct-1) +
  //                                              recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
		//   break;
  //         case 4:	  				//SSB based recruitment, 2 par Ricker
		// 	//SSB(area,spp)(yrct) /= Nstepsyr; //average SSB for a single "spawning" timestep, now SSB is at time t
		// 	recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1) *
  //                                         mfexp(-recruitment_beta(area,spp) * SSB(area,spp)(yrct-1) +
  //                                              recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
		//   break;
  //         case 5:	  				//SSB based recruitment, 2 par Beverton Holt
		// 	//SSB(area,spp)(yrct) /= Nstepsyr; //average SSB for a single "spawning" timestep, now SSB is at time t
		// 	recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1) /
  //                                        (1 + (recruitment_beta(area,spp) * SSB(area,spp)(yrct-1)));
  //                                    //"effective recruitment" with env covariates; see Quinn & Deriso 1999 p 92
  //             /////////////////////////////////////////////// WHY -ve recruitment_covwt /////////////////////////////////////////////////////
  //                                     recruitment(area,spp)(yrct) *= mfexp(-recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
		//   break;
  //          case 6:
		// 	//SSB(area,spp)(yrct) /= Nstepsyr; //average SSB for a single "spawning" timestep, now SSB is at time t
		// 	recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1) /
  //                                        (1 +  pow(value( SSB(area,spp)(yrct-1)/recruitment_beta(area,spp)),recruitment_shape(area,spp)) );
  //                                    //"effective recruitment" with env covariates; see Quinn & Deriso 1999 p 92
  //                                     recruitment(area,spp)(yrct) *= mfexp(recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
  //                break;
  //          case 7:  // Hockey Stick Stock recruitment
		// 	//SSB(area,spp)(yrct) /= Nstepsyr; //average SSB for a single "spawning" timestep, now SSB is at time t
  //                       if(SSB(area,spp)(yrct-1) <= recruitment_shape(area,spp)) { // S*
		// 	               recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1); // alpha.SSB
  //                       }  else {
		// 	               recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * recruitment_shape(area,spp); // alpha.SSB*
  //                       }
  //                                    //"effective recruitment" with env covariates; see Quinn & Deriso 1999 p 92
  //                                     recruitment(area,spp)(yrct) *= mfexp(recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
  //                break;
  //          case 8:  // Segmented Regression with breakpoint
		// 	//SSB(area,spp)(yrct) /= Nstepsyr; //average SSB for a single "spawning" timestep, now SSB is at time t
  //                       if(SSB(area,spp)(yrct-1) <= recruitment_shape(area,spp)) { // breakpoint
		// 	               recruitment(area,spp)(yrct) = recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1); // alpha.SSB
  //                       }  else {
		// 	               recruitment(area,spp)(yrct) = (recruitment_alpha(area,spp) * SSB(area,spp)(yrct-1)) +
  //                                            (recruitment_beta(area,spp) *( SSB(area,spp)(yrct-1)-recruitment_shape(area,spp)) ); // alpha.SSB + beta(ssB-breakpoint)
  //                       }
  //                       // check to see if recruitment goes below zero. which it is possible to do
  //                       if ( recruitment(area,spp)(yrct) < 0) {
  //                          recruitment(area,spp)(yrct) = 0.0;
  //                       }
  //                                    //"effective recruitment" with env covariates; see Quinn & Deriso 1999 p 92
  //                                     recruitment(area,spp)(yrct) *= mfexp(recruitment_covwt(spp) * trans(recruitment_cov)(yrct-1));
  //                break;
  //          case 9:                   //Average recruitment plus devs--giving up on functional form
                       //recruitment(area,spp)(yrct) = mfexp(avg_recruitment(area,spp)+recruitment_devs(area,spp,yrct));
                       recruitment(area,spp)(yrct) = avg_recruitment(area,spp)*mfexp(recruitment_devs(area,spp,yrct)-0.5*recsigma(area, spp)*recsigma(area, spp));  //GF 2022/03/04, avg_recruitment is already in real space. This equation does not include lognormal bias correction (yet)
      //cout << spp << " " << yrct << " " << recruitment(area,spp)(yrct) << " " << avg_recruitment(area,spp) << " " << recruitment_devs(area,spp,yrct) << endl;
      //exit(-1);
		//   break;
  //          default:
  //           exit(1);
		// } //end switch
        // if(stochrec(spp)){                //simulate devs around recruitment curve
        //  // we allow the option of a "large" recruitment event (larger than under log normal) every so often as recommended by
        //  // CIE review team (Daniel Howell). We sample a random number from uniform distribution and based on frequency of large event
        //  // (from literature) determine if event should occur for species. We then sample from a distribution of event magnitudes.
        //  // NOT YET IMPLEMENTED
        //   if (rec_EventError(area,spp,yrct) >= 0) { // U~[0,1] to determine an extreme event x% of time
        //    // assumes log normal error. R = S.exp(Z) where Z = N(-sig2/2, sig2). In expectation R has mean = S. Slightly diff if Z = AR1
        //      recruitment(area,spp)(yrct) *=  mfexp(sim_recruit_error(area,spp,yrct));
        //    } else {   // extreme event
        //     //  recruitment(area,spp)(yrct)  = some other transformation depending on error structure (sim_extreme_recruit_error)
        //     ///////////  place holder for now ///////////////////
        //     recruitment(area,spp)(yrct) *=  mfexp(sim_recruit_error(area,spp,yrct));
        //    }
        // }  //end if stochastic
        // Now add recruitment to 1st size class
        N(area,spp,t,1) = N(area,spp,t,1) + recruitment(area,spp,yrct);
      }  //end spp
    }  //end area
  }  //end if last timestep in year
}

void model_parameters::calc_available_N(void)
{
 // simply make Narea(t) = N(t)
 for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
            for(int isize=1; isize<=Nsizebins; isize++){
               Narea(area,spp,t,isize) = N(area,spp,t,isize);
            }
         }
  }
  //adjust Narea based on proportion of population in management area
  for (area=1; area<=Nareas; area++){
     for(spp=1; spp<=Nspecies; spp++){
         Narea(area,spp,t) = N(area,spp,t)*residentTime(area,spp);
     }
  }
}

void model_parameters::calc_pred_mortality(void)
{
  //M2.initialize();
  //totalconsumedbypred = allmodeledprey(pred,predsize) + otherprey
  for (area=1; area<=Nareas; area++){
  	for(pred=1; pred<=Nspecies; pred++){
	    for(prey=1; prey<=Nspecies; prey++){
               // select the rows of suitability given predator (in blocks of Nsizebins )
               // suittemp is a Nsizebins x Nsizebins matrix.each value is suitability of pred size (col) on prey size(row)
		  dvar_matrix suittemp = suitability(area,pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins);
               // when using .sub on a higher order array, even if a matrix is the result the .rowmin() value is not set to 1
               // it uses the value of the row it occupied in the large array. This .rowmin() value determins if matrices can be multiplied
               // so we need to use .rowshif to designate the matrix to have rows starting from .rowmin()=1
		  suittemp.rowshift(1); //needed to match up array bounds
                  // vector * matrix = vector. result = [ sum(v*mat[,1]),sum(v*mat[,2]),sum(v*mat[,3]),sum(v*mat[,4]),sum(v*mat[,5])]
                  // standard  matrix  multiplication
                  //cout << pred << " " << prey << " " << suittemp << endl;
	      suitpreybio(area,pred,t) += wtconv*(elem_prod(binavgwt(prey),Narea(area,prey,t)) *  suittemp);
        for (int ipredsize=1;ipredsize<=Nsizebins;ipredsize++)     
          biomass_prey_avail_no_size(area,pred,yrct,ipredsize,prey) += sum(elem_prod(elem_prod(binavgwt(prey),Narea(area,prey,t)), column(suittemp,ipredsize)));
             }
        for (int ipredsize=1;ipredsize<=Nsizebins;ipredsize++)     
          biomass_prey_avail_no_size(area,pred,yrct,ipredsize,Nprey) += otherFood(pred); //suitability of other food needed?  //mod GF 11/14/22 to allow for predator-specific other food
        }
  } //ok
  /// NB: IN INITAL GAICHAS CODE ISSUE WITH THE MATRIX MULTIPLICATION OVER "INCORRECT" DIMENSION. THIS WAS CHANGED TO INCLUDE NESTED SIZE LOOPS
  //M2(area, prey, preysize,t) = sumover_preds_predsizes(intake*N(area,pred,predsize,t)*suitability(area,predpreysize)/
  //								sumover_preds_predsizes(totalconsumedbypred))
  //cout << "PM1 " << suitability(1,1) << endl;
  //cout  << "PM2 " << intake(1,1,yrct) << endl;
  //cout  << "PM3 " << suitpreybio(1,1,t) << endl;
  //cout  << "PM4 " << otherFood << endl;
  //cout  << "PM5 " << M2(1,1,t) << endl;
   for (area=1; area<=Nareas; area++){
  	for(prey=1; prey<=Nspecies; prey++){
               for(pred=1; pred<=Nspecies; pred++){
		  dvar_matrix suittemp2 = suitability(area,pred).sub(prey*Nsizebins-(Nsizebins-1), prey*Nsizebins);
                  // see above description of why row shif is needed
		  suittemp2.rowshift(1); //needed to match up array bounds
                  for (int ipreysize =1; ipreysize<=Nsizebins; ipreysize++) {
                   for (int ipredsize =1; ipredsize<=Nsizebins; ipredsize++) {                     
                     M2(area,prey,t,ipreysize) += (intake(area,pred,yrct,ipredsize)*Narea(area,pred,t,ipredsize) * suittemp2(ipreysize,ipredsize)) /
                           (suitpreybio(area,pred,t,ipredsize) + otherFood(pred));    //Hall et al 2006 other prey too high
                     //if (prey ==1) cout << "M2 " << pred << " " << ipreysize << " " << ipredsize << " " << M2(area,prey,t,ipreysize) << " " << intake(1,pred,yrct,ipredsize) << " " << suittemp2(ipreysize,ipredsize) << " " << suitpreybio(1,pred,t,ipredsize) << endl;
                    }
                  }
               } //pred
    } //prey
  } // ok
  //cout  << "PM6 " << M2(1,1,t) << endl;
  // Beet big dumb loop was written to explore issues with original M2. See 1_1_2 for details
}

void model_parameters::calc_fishing_mortality(void)
{
  //NOTE: Ftots are by area, species, and should be separated by fleet
  //not currently set up that way, assuming each fleet has same Ftot and they sum to F
  //selectivities are not currently by area, assuming fleet selectivity same in each area
  dvariable neglog19 = -1.*log(19.);
  for (area=1; area<=Nareas; area++){
      for(spp=1; spp<=Nspecies; spp++){
           for(fleet=1; fleet<=Nfleets; fleet++){
               for(int isizebin=1; isizebin<=Nsizebins; isizebin++) { //abeet added this loop to avoid compilation warnings.
               // could be created in calc_initial_sattes since it is not time dependent
                //fishsel(area,spp,fleet,isizebin) = 1/(1 + mfexp(-1.*fishsel_c(spp,fleet)*
                 //                    (lbinmidpt(spp,isizebin)-fishsel_d(spp,fleet))));
                fishsel(area,spp,fleet,isizebin) = 1./(1.+mfexp(neglog19*(lbinmidpt(spp,isizebin)-fishsel_c(1,fleet))/fishsel_d(2,fleet)));                                     
                                     }
                                     fishsel(area,spp,fleet) /= max(fishsel(area,spp,fleet));
                for(int isizebin=1; isizebin<=Nsizebins; isizebin++) { 
                 // Ffl(area,spp,fleet,t,isizebin) = fishsel(area,spp,fleet,isizebin)*(Fyr(area,spp,fleet,yrct))/Nstepsyr; //Andy Beet
                  // "catch mortality by fleet"  multiply by 1-p(discard) .i.e all landable catch:  p(no discard)
                  Ffl(area,spp,fleet,t,isizebin) = (1-discard_Coef(area,spp,fleet,isizebin))*fishsel(area,spp,fleet,isizebin)*(Fyr(area,spp,fleet,yrct))/Nstepsyr; //Andy Beet
                  // discard mortality by fleet" multiply by p(discard).(1-p(survive|discard))
                  Dfl(area,spp,fleet,t,isizebin) = (discard_Coef(area,spp,fleet,isizebin)*(1-discardSurvival_Coef(area,spp,fleet,isizebin))
                                                  *fishsel(area,spp,fleet,isizebin))*(Fyr(area,spp,fleet,yrct))/Nstepsyr; //Andy Beet
                  // partition fishing mortality,F  into "landings mortality", and "discard mortality", D
                  //  (1-p(discard)).F    +   p(discard).(1-p(discard|survive)).F
                  // == F - F.p(discard).p(survive|discard). See documentation
               }
               // sum mortalities over fleet
               D(area,spp,t) += Dfl(area,spp,fleet,t);
               F(area,spp,t) += Ffl(area,spp,fleet,t);
      }
    }
  }
}

void model_parameters::calc_total_mortality(void)
{
 for (area=1; area<=Nareas; area++){
     for(spp=1; spp<=Nspecies; spp++){
       //mort components, with all fleets already in F and D
       // F is mortality due to Fishing - landed species, D is discard mortality
       // Split F up in calc_catch_etc. Catch = F (landings) + D (discards)
       Z(area,spp,t) = M1(area,spp) +  M2(area,spp,t) +  F(area,spp,t) + D(area,spp,t);
     }
 }
}

void model_parameters::calc_catch_etc(void)
{
  //calculate Catch numbers at size (C), total catch_biomass, and N/biomass eaten and dead of other causes
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
      //temp vectors for holding proportions
      dvar_vector Fprop = elem_div(F(area,spp,t),Z(area,spp,t)); //prop of death due to fishing of each size class
      dvar_vector M2prop = elem_div(M2(area,spp,t),Z(area,spp,t)); //prop of death due to predation of each size class
      dvar_vector M1prop = elem_div(M1(area,spp),Z(area,spp,t)); // prop of death due to other mortality. M1 read in from Data file
      dvar_vector Dprop = elem_div(D(area,spp,t),Z(area,spp,t)); // prop of death due to Discards of each size class
      dvar_vector Ndeadtmp = elem_prod((1-exp(-Z(area,spp,t))),Narea(area,spp,t));// total number dead in each size class
      // note: Z = total mortality
      //these are numbers at size dying each timestep from fishing, predation, and M1 (other)
      C(area,spp,t) = elem_prod(Fprop, Ndeadtmp); //fishing catch on GB
      eatN(area,spp,t) = elem_prod(M2prop, Ndeadtmp); // predation, M2
      discardN(area,spp,t) = elem_prod(Dprop,Ndeadtmp); // discards on vessel either not target species or not allowed to land
      otherDead(area,spp,t) = Ndeadtmp - C(area,spp,t) - eatN(area,spp,t)- discardN(area,spp,t); // M1
      // // all catch is considered discard since can not be landed if found to be so in assessment.
      // // catchTtoDiscards is a binary vector indicating threshold exceedance. Default all = 0
      // if (catchToDiscardsSpecies(area,spp) == 1) {
      //    discardN(area,spp,t) =  discardN(area,spp,t) + C(area,spp,t);
      //    C(area,spp,t) = 0.0;
      // }
      // size class level
      eaten_biomass_size(area,spp,yrct) += wtconv*elem_prod(eatN(area,spp,t),binavgwt(spp));
      discard_biomass_size(area,spp,yrct) +=  wtconv*elem_prod(discardN(area,spp,t),binavgwt(spp));
      otherDead_biomass_size(area,spp,yrct) += wtconv*elem_prod(otherDead(area,spp,t),binavgwt(spp));
      total_biomass_size(area,spp,yrct) += wtconv*elem_prod(Narea(area,spp,t),binavgwt(spp));
      //these are annual total biomass losses for comparison with production models
      eaten_biomass(area,spp,yrct) += sum(wtconv*elem_prod(eatN(area,spp,t),binavgwt(spp)));
      discard_biomass(area,spp,yrct) +=  sum(wtconv*elem_prod(discardN(area,spp,t),binavgwt(spp)));
      otherDead_biomass(area,spp,yrct) += sum(wtconv*elem_prod(otherDead(area,spp,t),binavgwt(spp)));
      total_biomass(area,spp,yrct) += sum(wtconv*elem_prod(Narea(area,spp,t),binavgwt(spp)));
      //do fleet specific catch in numbers, biomass, sum for total catch
      for(fleet=1; fleet<=Nfleets; fleet++){
	  dvar_vector Fflprop = elem_div(Ffl(area,spp,fleet,t),F(area,spp,t));// proportion dead due to fleet in each size class. vec length= num classes
          Cfl(area,spp,fleet,t) = elem_prod(Fflprop, C(area,spp,t)); // numbers dying from fleet by sizeclass
          fleet_catch_biomass(area,spp,fleet,yrct) += sum(wtconv*elem_prod(Cfl(area,spp,fleet,t),binavgwt(spp)));
          catch_biomass_size(area,spp,yrct) += wtconv*elem_prod(Cfl(area,spp,fleet,t),binavgwt(spp));
          catch_biomass(area,spp,yrct) += sum(wtconv*elem_prod(Cfl(area,spp,fleet,t),binavgwt(spp)));
         // est_fleet_catch_biomass(area,spp,fleet,yrct) = fleet_catch_biomass(area,spp,fleet,yrct) * exp(catch_sigma(area,spp,fleet)
         //                                * catch_obsError(area,spp,fleet,yrct)
         //                                - 0.5 * catch_sigma(area,spp,fleet) * catch_sigma(area,spp,fleet)  ); //add obs error
   //        if (t % Nstepsyr == 0){//if we are just about to end the year //andybeet
   //              est_catch_biomass(area,spp,yrct) += est_fleet_catch_biomass(area,spp,fleet,yrct);
	  // }//end if
          for (int isize=1; isize<=Nsizebins; isize++){
              // used for indices- LFI
              Cfl_tot(area,spp,fleet,yrct,isize) +=  Cfl(area,spp,fleet,t,isize);// fishing. total number by size/species/fleet each year. summed over t
              C_tot(area,spp,yrct,isize) += Cfl(area,spp,fleet,t,isize); // fishing. total number by size/species each yr summed over fleet and Nstepsyr timesteps
          }
      }//end fleet loop
    }//end species loop
  }//end area loop
 // // aggregate catch to guild level at end of year Andy Beet
 // // also calculate predation rate and fishingRate
 //   if ((t % Nstepsyr == 0) && (yrct <= Nyrs)){
 //   for(area=1; area<=Nareas; area++){
 //          for (spp=1; spp<=Nspecies; spp++) {
 //             for (int isize = 1; isize<=Nsizebins; isize++ ) {
 //             // look out for nans
 //                if (total_biomass_size(area,spp,yrct,isize) < .001) { // zero
 //                  predation_mortality_size(area,spp,yrct,isize) = 0;
 //                  fishing_mortality_size(area,spp,yrct,isize) = 0;
 //                } else {
 //                  predation_mortality_size(area,spp,yrct,isize) = eaten_biomass_size(area,spp,yrct,isize)/(total_biomass_size(area,spp,yrct,isize)/Nstepsyr);
 //                  fishing_mortality_size(area,spp,yrct,isize) = (catch_biomass_size(area,spp,yrct,isize)+discard_biomass_size(area,spp,yrct,isize))/(total_biomass_size(area,spp,yrct,isize)/Nstepsyr);
 //               }
 //             }
 //             if (total_biomass(area,spp,yrct) <.001) {
 //               predation_mortality(area,spp,yrct) = 0;
 //               fishing_mortality(area,spp,yrct) = 0;
 //             } else {
 //                predation_mortality(area,spp,yrct) = eaten_biomass(area,spp,yrct)/(total_biomass(area,spp,yrct)/Nstepsyr);
 //                fishing_mortality(area,spp,yrct) = (catch_biomass(area,spp,yrct)+discard_biomass(area,spp,yrct))/(total_biomass(area,spp,yrct)/Nstepsyr);
 //             }
 //          }
 //   }
 //   //  test<< "ttt = "<< t <<", yr =  "<<yrct <<endl;
 //   for(area=1; area<=Nareas; area++){
 //       for (int iguild=1; iguild<=Nguilds; iguild++) {
 //          for (spp=1; spp<=Nspecies; spp++) {
 //            for (fleet=1; fleet<=Nfleets; fleet++) {
 //                 if (guildMembers(spp) == iguild) {
 //                // cout<<iguild<<","<<spp<<","<<fleet<<endl;
 //                    est_fleet_catch_guild_biomass(area,iguild,fleet,yrct) += est_fleet_catch_biomass(area,spp,fleet,yrct);
 //                    est_catch_guild_biomass(area,iguild,yrct) += est_fleet_catch_biomass(area,spp,fleet,yrct);
 //                 }
 //            }
 //          }
 //       }
 //   }
 //  } // end if t%
}

void model_parameters::calc_pop_dynamics(void)
{
 // For species not resident in area.
 // Assume contant total mortality rate for population not in management area.
 // Adjust that proportion of population
  //ofstream popout("popstructure.out");
  for(area = 1; area <=Nareas; area++) {
       for (spp = 1; spp <=Nspecies; spp++) {
           for(int isize=1; isize <= Nsizebins; isize++){
              // For pop outside of management area => entire population * proportion of population out of area * mortality rate
              Nnotarea(area,spp,t,isize) = N(area,spp,t,isize)*(1.0-residentTime(area,spp))*(1.0-areaMortality(area,spp));
           }
       }
  }
  //cout << "A "<< t << " " << Nnotarea(1,1,t) << endl;
  // POP DYNAMICS for Area of interest
  //for all older than recruits,
  //pop is composed of survivors from previous size growing into current size and staying in area
  //plus survivors in current size not growing out of current size and staying in area
  //plus immigrants of current size from other areas
  //minus emigrants of current size to other areas
  //movement is not yet specified, so we leave out the immigration and emigration parts for now
  // Recruits added already in recuitment module
  //N(area, spp,t,bin) +=
  //                       N(area, spp,t,bin-1)*S(area,spp,t,bin-1)*growthprob_phi(area,spp,bin-1) +
  //                       N(area, spp,t,bin)*S(area,spp,t,bin)*(1-growthprob_phi(area,spp,bin)))
  //cout << "C "<< t << " " << Z(1,1,t) << endl;
  //cout << "D "<< t << " " << growthprob_phi(1,1,yrct) << endl;
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
        // For all bins except smallest. execute from largest to smallest. Remember N(t) = N(t-1) in first step
        //N = surviving and growing from smaller bin and surviving and staying in current bin
        for(int isize=Nsizebins; isize>=2; isize--){
       	 Narea(area,spp,t,isize) = Narea(area,spp,t,isize-1) * exp(-Z(area,spp,t,isize-1)) * growthprob_phi(area,spp,yrct,isize-1)
                            +  Narea(area,spp,t,isize)* exp(-Z(area,spp,t,isize))  * (1-growthprob_phi(area,spp,yrct,isize));
         //popout << spp << " " << t << " " << isize << " " << Narea(area,spp,t,isize) << endl;
         N_tot(area,spp,yrct,isize) += Narea(area,spp,t,isize);// cumulate sum. averaged in indices
        }//end size loop
        // smallest size class. Survivors that stay in same size class
        // we added recruits at start of year to current time. they were then fished in this time period
	Narea(area,spp,t,1) = Narea(area,spp,t,1)* exp(-Z(area,spp,t,1))*(1-growthprob_phi(area,spp,yrct,1));
        //popout << spp << " " << t << " " << 1 << " " << Narea(area,spp,t,1) << endl;
        N_tot(area,spp,yrct,1) += Narea(area,spp,t,1); // running total for the year. Used for indices
      }//end species loop
  }//end area loop
  // Add two populations (in management area, outside management area)
   for(area = 1; area <=Nareas; area++) {
       for (spp = 1; spp <=Nspecies; spp++) {
           N(area,spp,t) = Nnotarea(area,spp,t) + Narea(area,spp,t);
       }
   }
       //  cout<<endl;
}

void model_parameters::calc_SSB(void)
{
  //egg production(t) = sumover_length(fecundity*prop mature(t)*sexratio*N(t))
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
	  dvar_vector fecundmature = elem_prod(fecundity(area,spp), propmature(area, spp)(yrct));
          dvar_vector sexratioN = sexratio(area, spp) * N(area,spp)(t);
          eggprod(area,spp)(yrct) += sum(elem_prod(fecundmature, sexratioN));  //accumulates eggs all year--appropriate?
          dvar_vector Nmature = elem_prod(propmature(area, spp)(yrct), N(area,spp)(t));
                //SSB(area,spp)(yrct) += sum(wtconv*elem_prod(Nmature,binavgwt(spp)));  //accumulates SSB all year; not appropriate
          SSB(area,spp)(yrct) = sum(wtconv*elem_prod(Nmature,binavgwt(spp)));  //SSB in this timestep, overwrites previous
          // Final SSB(year) = SSB in time step 5, 1- etc
    }
  }
}

void model_parameters::calc_movement(void)
{
  //not yet specified will probably have migration in array and add random too
  int probmovein = 0.0;        //will be an array for area to area movement
  int probmoveout = 0.0;       //as will this
  for (area=1; area<=Nareas; area++){
  	for(spp=1; spp<=Nspecies; spp++){
			  //N(area,spp,t) += N(area,spp,t) * probmovein(area,spp);
			 // N(area,spp,t) -= N(area,spp,t) * probmoveout(area,spp);
   // ******************************************************************************
   // weight/length is not linear. The following line  will underestimate B
      B(area,spp,t) = wtconv*elem_prod(Narea(area,spp,t),binavgwt(spp));  //do after movement
      for (int isize=1;isize<=Nsizebins;isize++) {
          // add up B over t for each year keeping size class structure. used in indices
          B_tot(area,spp,yrct,isize) += B(area,spp,t,isize);
      }
    }
  }
}

void model_parameters::calc_survey_abundance(void)
{
  for (area=1; area<=Nareas; area++){
      for(spp=1; spp<=Nspecies; spp++){
	   avByr(area,spp)(yrct) += sum(B(area,spp,t))/Nstepsyr;
          //  if(yrct == 1) {
          //    est_survey_biomass(area,spp,yrct) *= exp(rho_AR_Survey*xts(area,spp,1) +
          //                               surv_sigma(area,spp)*surv_obsError(area,spp,yrct)*pow(1.0 -pow(rho_AR_Survey,2),0.5)
          //                               - 0.5 * surv_sigma(area,spp) * surv_sigma(area,spp)  ); //add obs error
          //  } else {
          //    est_survey_biomass(area,spp,yrct) *= exp(rho_AR_Survey*xts(area,spp,yrct-1) +
          //                               surv_sigma(area,spp)*surv_obsError(area,spp,yrct)*pow(1.0 -pow(rho_AR_Survey,2),0.5)
          //                               - 0.5 * surv_sigma(area,spp) * surv_sigma(area,spp)  ); //add obs error
          //  }
      }
  }
 // Added by Andy Beet
 // we need to sum up the biomass over each guild and check for excedences.
 // Do at end of year only. Used in assessment module and health indices module
  // if ((t % Nstepsyr == 0) && (yrct <= Nyrs)){
  // //  test<< "ttt = "<< t <<", yr =  "<<yrct <<endl;
  //  for(area = 1; area<=Nareas; area++){
  //      for (iguild=1; iguild<=Nguilds; iguild++) {
  //         for (spp=1; spp<=Nspecies; spp++) {
  //            if (guildMembers(spp) == iguild) {
  //              est_survey_guild_biomass(area,iguild,yrct) += est_survey_biomass(area,spp,yrct);
  //            }
  //         }
  //      }
  //  }
  // } // end if t%
}

void model_parameters::calculate_predicted_values(void)
{
    // assume survey covers all areas, and uses average biomass for year, rathter than timing-specific suruvey
    pred_survey_index.initialize();
    for (int i=1;i<=Nsurvey_obs;i++) {
      int survey = obs_survey_biomass(i,1);
      int year = obs_survey_biomass(i,2);
      int spp = obs_survey_biomass(i,3);
      for (area=1; area<=Nareas; area++){
        for (int ilen=1;ilen<=Nsizebins;ilen++) {
                  //if (year == 80 && spp == 10 && survey ==2) cout << ilen << " " <<B_tot(area,spp,year,ilen) << " " << survey_sel(survey,spp,ilen) << " " << survey_q(survey,spp) << endl; 
            pred_survey_index(i) +=  B_tot(area,spp,year,ilen)*survey_sel(survey,spp,ilen)*survey_q(survey,spp)/Nstepsyr; 
        }
      }       
    }
}

void model_parameters::evaluate_the_objective_function(void)
{
  dvariable eps = 1.e-07;
  cout << "starting commercial catch nll" << endl;
    // Ncatch_obs
    pred_catch_biomass.initialize();
    resid_catch.initialize();
    nll_catch.initialize(); 
    for (int i=1;i<=Ncatch_obs;i++) {
      //cout << "cat obs " << i << endl;
      int fleet = obs_catch_biomass(i,1);
      int area = obs_catch_biomass(i,2);
      int year = obs_catch_biomass(i,3);
      int spp = obs_catch_biomass(i,4);
      dvariable value = obs_catch_biomass(i,5)+eps;
      dvariable cv = obs_catch_biomass(i,6);
      // if (fleet==0) // add case when catch is aggregated over fleets (fleet = 0 in data file)
      pred_catch_biomass(i) = fleet_catch_biomass(area,spp,fleet,year); //predicted value for this data point
      resid_catch(i) = log(value/(pred_catch_biomass(i)+eps));
      nll_catch(i) = dlnorm(value, log(pred_catch_biomass(i)+eps), cv);
    }
  cout << "done commercial catch nll" << endl;
  cout << "starting commercial catch at length nll" << endl;
   //Ncatch_size_obs
  int j=0;
  pred_catch_size.initialize();
  nll_catch_size.initialize();
  for (int i=1;i<=Ncatch_size_obs;i++) {
     //cout << "obs row " << i << endl;
     int fleet = obs_catch_size(i,1); //cout << "fleet" << fleet << endl;
     int area = obs_catch_size(i,2);  //cout << "area" << area << endl;
     int year = obs_catch_size(i,3);  //cout << "year" << year << endl;
     int spp = obs_catch_size(i,4);  //cout << "spp" << spp << endl;
     int type = obs_catch_size(i,5);  //cout << "type" << type << endl;//not yet used
     int effN = obs_catch_size(i,6);   //cout << "effN" << effN << endl;
     dvar_vector Lobs(1,Nsizebins);
     Lobs.initialize();
     for (int ilen=1;ilen<=Nsizebins;ilen++) Lobs(ilen) = obs_catch_size(i,6+ilen) + 0.0001;
     Lobs = Lobs/sum(Lobs);
     dvar_vector Lpred(1,Nsizebins);
     Lpred.initialize();
     for (int ilen=1;ilen<=Nsizebins;ilen++)
      Lpred(ilen) = Cfl_tot(area,spp,fleet,year,ilen); // predicted catch at length for this observation
     Lpred = (eps+Lpred)/sum(eps + Lpred);
     //cout << "Lpred" << Lpred << endl;
     for (int ilen=1;ilen<=Nsizebins;ilen++) {
      if (Lobs(ilen) > 0)
       {
        j+=1;
        // create table for data base of sizes
        // jth row of this table
        pred_catch_size(j) = Lpred(ilen);  //change for better storage table
        nll_catch_size(j) = -1.*effN*Lobs(ilen)*log(Lpred(ilen)/Lobs(ilen));
       } 
     }
  }
  cout << "done commercial catch at length nll" << endl;
    // Nsurvey_obs
  resid_survey.initialize();
  nll_survey.initialize();
    for (int i=1;i<=Nsurvey_obs;i++) {
      //cout << i << endl;
      //if (i==881) cout << obs_survey_biomass(881) << endl;
      int survey = obs_survey_biomass(i,1);
      int year = obs_survey_biomass(i,2);
      int spp = obs_survey_biomass(i,3);
      dvariable value = obs_survey_biomass(i,4)+eps;
      dvariable cv = obs_survey_biomass(i,5);
      //predicted value now calculated in function 'calculate_predicted_values()'
      //pred_survey_index(i) = est_survey_biomass(survey,spp,year); //survey is area here! need to change survey definitions
      resid_survey(i) = log(value/(pred_survey_index(i)+eps));
      nll_survey(i) = dlnorm(value, log(pred_survey_index(i)+eps), cv);
    }
  cout << "done survey abundance nll" << endl;
  if(std::isinf(value(sum(nll_survey)))) {
    cout << " INFINITE OBJ FUN" << endl;
    gavjunk << survey_q << endl;
    gavjunk << ln_survey_q << endl;
    gavjunk << "survey biomass data, predicted, residual, nll" << endl;
  for (int i=1;i<=Nsurvey_obs;i++)
    gavjunk << obs_survey_biomass(i) << " " << pred_survey_index(i) << " " << resid_survey(i) << " " << nll_survey(i) << endl;
  exit(-1);
  }
  //
 //Survey Catch-at-length
    //Nsurvey_size_obs
   j=0;
   pred_survey_size.initialize();
   nll_survey_size.initialize();
   for (int i=1;i<=Nsurvey_size_obs;i++) {
      int survey = obs_survey_size(i,1);
      int year = obs_survey_size(i,2);
      int spp = obs_survey_size(i,3);
      int type = obs_survey_size(i,4);  //not yet used
      int effN = obs_survey_size(i,5);
      dvar_vector Lobs(1,Nsizebins);
      Lobs.initialize();
      for (int ilen=1;ilen<=Nsizebins;ilen++) Lobs(ilen) = obs_survey_size(i,5+ilen) + 0.0001;
      Lobs = Lobs/sum(Lobs);
      dvar_vector Lpred(1,Nsizebins);
      Lpred.initialize();
      for (int area=1;area<=Nareas;area++)
       Lpred += N_tot(area,spp,year);
      Lpred = eps + survey_q(survey,spp)*elem_prod(survey_sel(survey,spp),Lpred)/Nstepsyr; //est_survey_size(survey, year, spp, ilen);// predicted survey at length for this observation
      Lpred = Lpred/sum(Lpred);
      for (int ilen=1;ilen<=Nsizebins;ilen++) {
       if (Lobs(ilen) > 0)
        {
         j+=1;
         // create table for data base of sizes
         // jth row of this table
         pred_survey_size(j) = Lpred(ilen);  //change for better storage table
         nll_survey_size(j) = -1.*effN*Lobs(ilen)*log(Lpred(ilen)/Lobs(ilen));
         //cout << j << " " << nll_survey_size(j) << endl;
        } 
      }
   }
  cout << "done survey size comp nll" << endl;
   j=0;
   pred_dietprop.initialize();
   nll_dietprop.initialize();
   for (int i=1;i<=Ndietprop_obs;i++) {
      int survey = obs_dietprop(i,1);
      int year = obs_dietprop(i,2);
      int spp = obs_dietprop(i,3);
      int size = obs_dietprop(i,4);  
      int effN = obs_dietprop(i,5);
      dvar_vector Pobs(1,Nprey);
      Pobs.initialize();
      for (int ilen=1;ilen<=Nprey;ilen++) Pobs(ilen) = obs_dietprop(i,5+ilen) + 0.0001;
      Pobs = Pobs/sum(Pobs);
      dvar_vector Ppred(1,Nprey);
      Ppred.initialize();
      for (int ilen=1;ilen<=Nprey;ilen++)
       for (int area=1;area<=Nareas;area++)
        Ppred(ilen) += eps + biomass_prey_avail_no_size(area,spp,year,size,ilen);
      Ppred = Ppred/sum(Ppred);
      for (int ilen=1;ilen<=Nprey;ilen++) {
       if (Pobs(ilen) > 0)
        {
         j+=1;
         // create table for data base of sizes
         // jth row of this table
         pred_dietprop(j) = Ppred(ilen);  //change for better storage table
         nll_dietprop(j) = -1.*effN*Pobs(ilen)*log(Ppred(ilen)/Pobs(ilen));
        } 
      }
   }
  cout << "done survey prey proportions nll" << endl;
   j = 0;
   dvar_vector resid(1,Nareas*Nspecies*(Nyrs-1));
   dvar_vector sdrec(1,Nareas*Nspecies*(Nyrs-1));
   resid.initialize();
   sdrec.initialize();
   nll_recruit.initialize();
   for (int area=1;area <=Nareas;area++) {
    for (int spp=1;spp <=Nspecies;spp++) {
    for (int year=2;year <=Nyrs;year++) {
      j +=1;
      recdev(j) = recruitment_devs(area,spp,year);
      resid(j) = recdev(j); //+0.5*square(recsigma(area,spp));
      sdrec(j) = recsigma(area,spp);
    }}}
      //dvariable sigma_use = recsigma(area,spp);
   nll_recruit = dnorm(resid,sdrec);
  cout << "done recruitment nll" << endl;
   objfun = 0.;
   objfun += sum(nll_survey);
   objfun += sum(nll_survey_size);
   objfun += sum(nll_catch);
   objfun += sum(nll_catch_size);
   objfun += sum(nll_dietprop);
   objfun += nll_recruit;  
   for (int area=1;area <=Nareas;area++) {
    for (int spp=1;spp <=Nfleets;spp++) {
     objfun += dnorm(F_devs(area,spp),1.0); }}
   cout << "nll_survey: " << sum(nll_survey) << endl;
   cout << "nll_survey_size: " << sum(nll_survey_size) << endl;
   cout << "nll_catch: " << sum(nll_catch) << endl;
   cout << "nll_catch_size: " << sum(nll_catch_size) << endl;
   cout << "nll_dietprop: " << sum(nll_dietprop) << endl;
   cout << "nll_recruit: " << nll_recruit << endl;
   cout << "nll_total: " << objfun << endl;
  // //est and observed survey biomass and fishery catch are 3darrays(area,spp,yr)
  // //fit matrices are area by spp
  //  resid_catch.initialize();
  //  resid_bio.initialize();
  //  totcatch_fit.initialize();
  //  totbio_fit.initialize();
  //  objfun_areaspp.initialize();
  // for (area=1; area<=Nareas; area++){
  // 	for(spp=1; spp<=Nspecies; spp++){
  //      resid_catch(area,spp) = log(obs_catch_biomass(area,spp)+o)-log(est_catch_biomass(area,spp)+o);
  //      totcatch_fit(area,spp) = norm2(resid_catch(area,spp));
  //      resid_bio(area,spp) = log(obs_survey_biomass(area,spp)+o)-log(est_survey_biomass(area,spp)+o);
  //      totbio_fit(area,spp) = norm2(resid_bio(area,spp));
  //   }
  // }
  // //cout<<"resid_catch\n"<<resid_catch<<endl;
  // //cout<<"totcatch_fit\n"<<totcatch_fit<<endl;
  // //cout<<"totbio_fit\n"<<totbio_fit<<endl;
  // objfun_areaspp = totcatch_fit + totbio_fit;
  // //cout<<"objfun_areaspp\n"<<objfun_areaspp<<endl;
  // objfun = sum(objfun_areaspp);
}

void model_parameters::report(const dvector& gradients)
{
 adstring ad_tmp=initial_params::get_reportfile_name();
  ofstream report((char*)(adprogram_name + ad_tmp));
  if (!report)
  {
    cerr << "error trying to open report file"  << adprogram_name << ".rep";
    return;
  }
  report << "Nstepsyr model timesteps per year " << endl;  
  report << Nstepsyr << endl;
  report << "EstNsize Estimated total numbers of fish " << endl;
  report << N << endl;
  report << "EstBsize Estimated total biomass of fish " << endl;
  report << B << endl;
  report << "EstRec Estimated recruitment " << endl;
  report << recruitment << endl;
  report << "EstFsize Estimated fishing mortality " << endl;
  report << F << endl;
  report << "EstM2size Estimated predation mortality " << endl;
  report << M2 << endl;
  report << "survey biomass data, predicted, residual, nll" << endl;
  for (int i=1;i<=Nsurvey_obs;i++)
    report << obs_survey_biomass(i) << " " << pred_survey_index(i) << " " << resid_survey(i) << " " << nll_survey(i) << endl;
  // report << "EstSurvB Estimated survey biomass of fish " << endl;
  // report << est_survey_biomass << endl;
  // report << "ObsSurvB Observed survey biomass of fish " << endl;
  // report << obs_survey_biomass << endl;
  report << "catch data, predicted, residual, nll" << endl;
  for (int i=1;i<=Ncatch_obs;i++)
    report << obs_catch_biomass(i) << " " << pred_catch_biomass(i) << " " << resid_catch(i) << " " << nll_catch(i) << endl;
  // report << "EstCatchB Estimated catch biomass of fish " << endl;
  // report << est_catch_biomass << endl;
  // report << "ObsCatchB Observed catch biomass of fish " << endl;
  // report << obs_catch_biomass << endl;
   report << "pred_catch_size" << endl;
   report << pred_catch_size << endl;
   report << "nll_catch_size" << endl;
   report << nll_catch_size << endl;
   report << "pred_survey_size" << endl;
   report << pred_survey_size << endl;
   report << "nll_survey_size" << endl;
   report << nll_survey_size << endl;
   report << "pred_dietprop" << endl;
   report << pred_dietprop << endl;
   report << "nll_dietprop" << endl;
   report << nll_dietprop << endl;
   report << "fishsel" << endl;
   for (int i=1;i<=Nspecies;i++) {
    for (int j=1;j<=Nfleets;j++) {
     report << i << " " << j << " " << fishsel(1,i,j) << endl;
    }
   }
   report << "survey_sel" << endl;
   for (int i=1;i<=Nspecies;i++) {
    for (int j=1;j<=Nsurveys;j++) {
     report << i << " " << j << " " << survey_sel(j,i) << endl;
    }
   }
  report << "Fyr" << endl;
  for (int i=1;i<=Nspecies;i++) {
   for (int j=1;j<=Nfleets;j++) {
     report << i << " " << j << " " << Fyr(1,i,j) << endl;
  }}
}

model_data::~model_data()
{}

model_parameters::~model_parameters()
{}

void model_parameters::final_calcs(void){}

void model_parameters::set_runtime(void){}

#ifdef _BORLANDC_
  extern unsigned _stklen=10000U;
#endif


#ifdef __ZTC__
  extern unsigned int _stack=10000U;
#endif

  long int arrmblsize=0;

int main(int argc,char * argv[])
{
    ad_set_new_handler();
  ad_exit=&ad_boundf;
 // arrmblsize = 8000000;  //Increase amount of available dvar memory
 // gradient_structure::set_CMPDIF_BUFFER_SIZE(6000000);
 // gradient_structure::set_GRADSTACK_BUFFER_SIZE(3000000);
 arrmblsize = 800000000;
 gradient_structure::set_CMPDIF_BUFFER_SIZE(1200000000);
 gradient_structure::set_GRADSTACK_BUFFER_SIZE(600000000);
    gradient_structure::set_NO_DERIVATIVES();
#ifdef DEBUG
  #ifndef __SUNPRO_C
std::feclearexcept(FE_ALL_EXCEPT);
  #endif
#endif
    gradient_structure::set_YES_SAVE_VARIABLES_VALUES();
    if (!arrmblsize) arrmblsize=15000000;
    model_parameters mp(arrmblsize,argc,argv);
    mp.iprint=10;
    mp.preliminary_calculations();
    mp.computations(argc,argv);
#ifdef DEBUG
  #ifndef __SUNPRO_C
bool failedtest = false;
if (std::fetestexcept(FE_DIVBYZERO))
  { cerr << "Error: Detected division by zero." << endl; failedtest = true; }
if (std::fetestexcept(FE_INVALID))
  { cerr << "Error: Detected invalid argument." << endl; failedtest = true; }
if (std::fetestexcept(FE_OVERFLOW))
  { cerr << "Error: Detected overflow." << endl; failedtest = true; }
if (std::fetestexcept(FE_UNDERFLOW))
  { cerr << "Error: Detected underflow." << endl; }
if (failedtest) { std::abort(); } 
  #endif
#endif
    return 0;
}

extern "C"  {
  void ad_boundf(int i)
  {
    /* so we can stop here */
    exit(i);
  }
}
