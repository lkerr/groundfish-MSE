# add radar plot
do_small_radar_plot <- function(metrics) {
  # metrics is a dataframe of metrics, expecting columns
  # metrics <- tibble(metric = rep(letters[1:5],each=3),
  #                   value = runif(15),
  #                   mp = as.character(rep(1:3,5)))
  # # metric 
  # # value
  # # mp (management procedure)
  summaries <- metrics %>% 
    group_by(metric) %>% 
    summarize(min = min(value, na.rm = TRUE),
              max = max(value, na.rm = TRUE)) %>% 
    #pivot_longer(cols = c(2:3),names_to = "mp",
    #             values_to = "value") %>% 
    #pivot_wider(names_from = metric, values_from = value) %>% 
    #arrange(desc(mp)) %>% 
    I()
  #summaries  
  nmetrics <- length(unique(metrics$metric))
  nmp <- length(unique(metrics$mp))
  
  d <- metrics %>% 
    group_by(mp) %>% 
    left_join(summaries) %>% 
    mutate(value = value/(max + 1e-08)) %>% 
    select(mp, metric, value) %>% 
    pivot_wider(names_from = metric, values_from = value) %>% 
    ungroup()
  
  bounds <- tibble(mp = c("max","min"),
                   #"spawning biomass" = c(1,0),
                   #"total catch" = c(1,0),
                   # "kept:released" = c(1,0),
                   # "kept per trip" = c(1,0),
                   # "not overfishing" = c(1,0),
                   # "not overfished" = c(1,0),
                   # "change_cs" = c(1,0),
                   # #"mulen_keep" = c(1,0),
                   # #"mulen_release" = c(1,0),
                   # #"trophy" = c(1,0),
                   # #"rec_removals" = c(1,0),
                   # "keep_one" = c(1,0)) #,
                   "cat_yield_Ecosystem" = c(1,0),
                   "fleet_yield_1" = c(1,0),
                   "fleet_yield_2" = c(1,0),
                   "iav_catch_Ecosystem" = c(1,0),
                   "prop_above_lim" = c(1,0),
                   "eco_above_bmsy" = c(1,0),
                   # "near_btarg_Piscivores" = c(1,0),
                   # "near_btarg_Benthivores" = c(1,0),
                   # "near_btarg_Planktivores" = c(1,0),
                   "f_reduced" = c(1,0),
                   "foregone_yield" = c(1,0))
  
  #"prop_female" = c(1,0),
  #"ntrips" = c(1,0)) #,
  #filter(metric %in% c("change_cs", "kept per trip", "kept:released", "not overfished", "not overfishing")) %>% 
  #d = c(1,0),
  #e = c(1,0))
  
  dd <- bounds %>% 
    bind_rows(d)
  
  #NEW PLOT
  #colorblind colors
  colors_fill2<-c(alpha("#000000",0.1),
                  alpha("#E69F00",0.1),
                  alpha("#56B4E9",0.1),
                  alpha("#009E73",0.1),
                  alpha("#F0E442",0.1),
                  alpha("#E69F00",0.1),
                  alpha("#56B4E9",0.1),
                  alpha("#009E73",0.1))
  colors_line2<-c(alpha("#000000",0.9),
                  alpha("#E69F00",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#009E73",0.9),
                  alpha("#F0E442",0.9),
                  alpha("#E69F00",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#009E73",0.9))
  colors_line2<-c(alpha("#1b9e77",0.9),
                  alpha("#d95f02",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#dc14cf",0.9),
                  #alpha("#009E73",0.9),
                  alpha("#F0E442",0.9),
                  alpha("#E69F00",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#009E73",0.9))
  
  colors_fill2<-c(alpha("#1b9e77",0.1),
                  alpha("#d95f02",0.1),
                  alpha("#7570b3",0.1),
                  alpha("#e7298a",0.1),
                  alpha("#66a61e",0.1),
                  alpha("#e6ab02",0.1),
                  alpha("#a6761d",0.1),
                  alpha("#d95f02",0.1))
  
  colors_line2<-c(alpha("#1b9e77",0.9),
                  alpha("#d95f02",0.9),
                  alpha("#7570b3",0.9),
                  alpha("#e7298a",0.9),
                  alpha("#66a61e",0.9),
                  alpha("#e6ab02",0.9),
                  alpha("#a6761d",0.9),
                  alpha("#d95f02",0.9))
  
  vlabels <- c("cat_yield_Ecosystem"="Ecosystem yield",
              "fleet_yield_1"="Fleet 1 Yield",
              "fleet_yield_2"="Fleet 2 Yield",
              "iav_catch_Ecosystem"="Interannual variability\nin ecosystem catch",
              "prop_below_lim"="Proportion below limit",
              "eco_above_bmsy"= "Ecosystem above Bmsy",
              "f_reduced"="F reduced",
              "foregone_yield"="Underutilized quota")
  
  
  #colorblind
  radarchart(dd[,-1],seg=5,pcol=colors_line2,
             pfcol=colors_fill2,plwd=2,
             vlabels=vlabels,vlcex = 0.8,
             #=names(dd)[-1], vlcex=0.8,
             plty=c(rep(1,7),rep(2,7)),
             pdensity=0)
  rows<<-rownames(dd[-c(1,2),])
  colors_line<<-colors_line2
  legend(x=0.42,y=-0.90,inset=0,title ="",title.adj = 0.2,
         legend=unique(d$mp),
         pch=16,
         col=colors_line2[1:nmp],
         lty=1, cex=0.75, bty= 'n', y.intersp=1)
  
}

do_small_radar_plot_om <- function(metrics) {
  # metrics is a dataframe of metrics, expecting columns
  # metrics <- tibble(metric = rep(letters[1:5],each=3),
  #                   value = runif(15),
  #                   mp = as.character(rep(1:3,5)))
  # # metric 
  # # value
  # # mp (management procedure)
  summaries <- metrics %>% 
    group_by(metric) %>% 
    summarize(min = min(value, na.rm = TRUE),
              max = max(value, na.rm = TRUE)) %>% 
    #pivot_longer(cols = c(2:3),names_to = "mp",
    #             values_to = "value") %>% 
    #pivot_wider(names_from = metric, values_from = value) %>% 
    #arrange(desc(mp)) %>% 
    I()
  #summaries  
  nmetrics <- length(unique(metrics$metric))
  nmp <- length(unique(metrics$mp))
  
  d <- metrics %>% 
    group_by(scenario) %>% 
    left_join(summaries) %>% 
    mutate(value = value/(max + 1e-08)) %>% 
    select(scenario, metric, value) %>% 
    pivot_wider(names_from = metric, values_from = value) %>% 
    ungroup()
  
  bounds <- tibble(mp = c("max","min"),
                   #"spawning biomass" = c(1,0),
                   #"total catch" = c(1,0),
                   # "kept:released" = c(1,0),
                   # "kept per trip" = c(1,0),
                   # "not overfishing" = c(1,0),
                   # "not overfished" = c(1,0),
                   # "change_cs" = c(1,0),
                   # #"mulen_keep" = c(1,0),
                   # #"mulen_release" = c(1,0),
                   # #"trophy" = c(1,0),
                   # #"rec_removals" = c(1,0),
                   # "keep_one" = c(1,0)) #,
                   "cat_yield_Ecosystem" = c(1,0),
                   "fleet_yield_1" = c(1,0),
                   "fleet_yield_2" = c(1,0),
                   "iav_catch_Ecosystem" = c(1,0),
                   "prop_above_lim" = c(1,0),
                   "eco_above_bmsy" = c(1,0),
                   # "near_btarg_Piscivores" = c(1,0),
                   # "near_btarg_Benthivores" = c(1,0),
                   # "near_btarg_Planktivores" = c(1,0),
                   "f_reduced" = c(1,0),
                   "foregone_yield" = c(1,0))
  
  #"prop_female" = c(1,0),
  #"ntrips" = c(1,0)) #,
  #filter(metric %in% c("change_cs", "kept per trip", "kept:released", "not overfished", "not overfishing")) %>% 
  #d = c(1,0),
  #e = c(1,0))
  
  dd <- bounds %>% 
    bind_rows(d)
  
  #NEW PLOT
  #colorblind colors
  colors_fill2<-c(alpha("#000000",0.1),
                  alpha("#E69F00",0.1),
                  alpha("#56B4E9",0.1),
                  alpha("#009E73",0.1),
                  alpha("#F0E442",0.1),
                  alpha("#E69F00",0.1),
                  alpha("#56B4E9",0.1),
                  alpha("#009E73",0.1))
  colors_line2<-c(alpha("#000000",0.9),
                  alpha("#E69F00",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#009E73",0.9),
                  alpha("#F0E442",0.9),
                  alpha("#E69F00",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#009E73",0.9))
  colors_line2<-c(alpha("#1b9e77",0.9),
                  alpha("#d95f02",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#dc14cf",0.9),
                  #alpha("#009E73",0.9),
                  alpha("#F0E442",0.9),
                  alpha("#E69F00",0.9),
                  alpha("#56B4E9",0.9),
                  alpha("#009E73",0.9))
  
  colors_fill2<-c(alpha("#1b9e77",0.1),
                  alpha("#d95f02",0.1),
                  alpha("#7570b3",0.1),
                  alpha("#e7298a",0.1),
                  alpha("#66a61e",0.1),
                  alpha("#e6ab02",0.1),
                  alpha("#a6761d",0.1),
                  alpha("#d95f02",0.1))
  
  colors_line2<-c(alpha("#1b9e77",0.9),
                  alpha("#d95f02",0.9),
                  alpha("#7570b3",0.9),
                  alpha("#e7298a",0.9),
                  alpha("#66a61e",0.9),
                  alpha("#e6ab02",0.9),
                  alpha("#a6761d",0.9),
                  alpha("#d95f02",0.9))
  
  #colorblind
  radarchart(dd[,-1],seg=5,pcol=colors_line2,
             pfcol=colors_fill2,plwd=2,
             vlabels=names(dd)[-1], vlcex=0.8,
             plty=c(rep(1,7),rep(2,7)),
             pdensity=0)
  rows<<-rownames(dd[-c(1,2),])
  colors_line<<-colors_line2
  # legend("bottomright",inset=0,title ="",title.adj = 0.2,
  #        legend=unique(d$mp),
  #        pch=16,
  #        col=colors_line2[1:nmp],
  #        lty=1, cex=0.8, bty= 'n', y.intersp=1)
  
}

