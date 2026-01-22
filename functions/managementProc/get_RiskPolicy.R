##### Risk Policy function


get_RiskPolicy <- function(stockEnv){
  weighting <- "NEFMC"
  
  nefmc <- c(0.17, 0.16, 0.15, 0.15, 0.1, 0.17, 0.1)
  uniform <- rep(1/7, 7)

  weights <- data.frame(factor = c("ssb", "recruit", "assessment", "climate", "condition", "commercial", "recreational"),
                        weight = if(weighting == "uniform"){uniform}else{nefmc})
  
  res <- stockEnv$res
  s <- stockEnv$stockName

  ###### Summarize necessary information for dynamic factors
  
  ### SSB
  ssb_ratio <- tail(res$SSB,1)/res$SSBMSY 
  
  ### Recruitment
  # assign annual recruitment values into low, medium, and high groups by percentiles
  r_group <- cut(res$R,
                 quantile(res$R, probs = c(0, 1/3, 2/3, 1)),
                 labels = c('Low', 'Medium', 'High'),
                 include.lowest = TRUE)
  
  r_table <- table(tail(r_group, 5))  # summarize the last five years
  
  low <- table(tail(r_group, 6))["Low"]==6
  
  em_cor <- s %in% c("codWGOM", "Haddock")  ## Hard code stocks for Recruitment = 0 due to trends in projections
#  em_cor <- F     ## Hard code to allow recruitment trends to drive the factor score, regardless of stock/EM specs
  
  
  ### Collect in a dataframe
  rp <- data.frame(stock = s,
                   year = y,
                   ssb_ratio = ssb_ratio,
                   r_Nlow = r_table["Low"],
                   r_Nmed = r_table["Medium"],
                   r_Nhigh = r_table["High"],
                   low_r = low,
                   em_cor = em_cor)
  
  
  
  ##### Factor scoring
  rp <- rp %>% mutate(
    
    # SSB scoring
    rp_ssb = case_when(ssb_ratio > 1.5 ~ -4,
                       between(ssb_ratio, 1, 1.5) ~ -2,
                       between(ssb_ratio, 0.75, 1) ~ 0,
                       between(ssb_ratio, 0.5, 0.75) ~ 2,
                       ssb_ratio < 0.5 ~ 4,
                       .default = NA),
    
    # Recruitment scoring
    rp_recruit = case_when(r_Nhigh>2 ~ -4,
                           r_Nhigh == 2 ~ -2,
                           (r_Nlow >3 ) & low_r == F  ~ 2,
                           low_r == T ~ 4,
                           .default = 0),
    
    rp_recruit = case_when(em_cor == T ~ 0,
                           .default = rp_recruit),
    
    ##### Static factors     
    # Assessment type scoring
    rp_assessment = case_when(stock == "codWGOM" ~ 0,
                              stock == "haddockGOM" ~ 0,
                              stock == "witch" ~ 3,
                              .default = NA),

    # Climate vulnerability scoring, fixed at contemporary score (Hare et al)
    rp_climate = case_when(stock == "codWGOM" ~ 2,
                           stock == "haddockGOM" ~ 1,
                           stock == "witch" ~ 4,
                           .default = NA),
    
    # Fish condition scoring, fixed at demonstrated contemporary score (RP scoring tech report)
    rp_condition = case_when(stock == "codWGOM" ~ 0,
                             stock == "haddockGOM" ~ 0,
                             stock == "witch" ~ 1,
                             .default = NA),
    
    # Fishery outlook scoring, both fixed at 0
    rp_commercial = 0, # commercial fishery factor fixed at score of 0
    rp_recreational = 0 # commercial fishery factor fixed at score of 0
    )
  
  
  ##### Calculate Z-score and recommended probability (logistic output)
  z <- rp %>% select(starts_with("rp_")) %>% 
    pivot_longer(cols = everything(), names_to = "factor", names_prefix = "rp_", values_to = "score") %>%
    left_join(weights, by = "factor") %>% 
    mutate(weighted_score = score * weight) %>% 
    pull(weighted_score) %>% sum()
  
  logistic_out <- 1/(1+exp(-z))
  
  ##### Calculate percent of Fmsy for Risk Policy integrated control rules
  lower<- 0.5+0.5/3
  upper <- 1-0.5/3
  

  
  rp <- rp %>% mutate(z = z, logistic_out = logistic_out,
                      rec_prob = ifelse(logistic_out<0.5, 0.5, logistic_out),
                      prop_dynamic = 1-(rec_prob-0.5),
                      prop_tiered = case_when(rec_prob<lower ~ 1,
                                              between(rec_prob,lower, upper) ~ 0.75,
                                              rec_prob>upper ~ 0.5))
  
  # if(HCR == "dynamic"){prop <- rp %>% pull(prop_dynamic)}
  # if(HCR == "tiered"){prop <- rp %>% pull(prop_tiered)}
  
  # out <- list(prop = prop, rp = rp)
  
  return(rp) ### just returns the proportions of Fmsy for control rules, should do more accounting/saving
  
}
