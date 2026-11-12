##### Risk Policy function


get_RiskPolicy <- function(stockEnv){
  weighting <- "approved" # Defaults to the approved weights, regardless of what is here. Other options are "uniform" and "mock"
  #weighting <- "mock"
  fishery <- 2
  
  
  nefmc_mock <-     c(0.23, 0.21, 0.21, 0.13, 0.23)
  # nefmc_approved <- c(0.23, 0.22, 0.16, 0.15, 0.21)
  nefmc_approved <- c(3.44, 2.89, 2.11, 2.06, 2.83)
  nefmc_approved <- nefmc_approved/sum(nefmc_approved)
  uniform <- rep(1/5, 5)

  weights <- data.frame(factor = c("ssb", "recruit", "climate", "recreational", "commercial"),
                        weight = if(weighting == "uniform"){uniform}else{
                          if(weighting == "mock"){nefmc_mock}else{nefmc_approved}})
  
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
  em_cor <- F     ## Hard code to allow recruitment trends to drive the factor score, regardless of stock/EM specs
  ## For spring 2026 version of Risk Policy, EM cor should always remain F. Left in the option of using it for future explorations.
  
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
    rp_ssb = case_when(ssb_ratio > 1.5 ~ 4,
                       between(ssb_ratio, 1, 1.5) ~ 2,
                       between(ssb_ratio, 0.75, 1) ~ 0,
                       between(ssb_ratio, 0.5, 0.75) ~ -2,
                       ssb_ratio < 0.5 ~ -4,
                       .default = NA),
    
    # Recruitment scoring
    rp_recruit = case_when(r_Nhigh>2 ~ 4,
                           r_Nhigh == 2 ~ 2,
                           (r_Nlow >3 ) & low_r == F  ~ -2,
                           low_r == T ~ -4,
                           .default = 0),
    
    rp_recruit = case_when(em_cor == T ~ 0,
                           .default = rp_recruit),
    
    ##### Static factors     

    # Climate vulnerability scoring, fixed at contemporary score (Hare et al)
    rp_climate = case_when(stock == "codWGOM" ~ -2,
                           stock == "haddockGOM" ~ -1,
                           stock == "witch" ~ -4,
                           .default = NA),
    
    # Fishery outlook scoring, both fixed
    rp_commercial = fishery, # commercial fishery factor fixed at score of 2 (intermediate)
    rp_recreational = fishery # recreational fishery factor fixed at score of 2 (intermediate)
    )
  
  
  ##### Calculate Z-score and recommended probability (logistic output)
  z <- rp %>% select(starts_with("rp_")) %>% 
    pivot_longer(cols = everything(), names_to = "factor", names_prefix = "rp_", values_to = "score") %>%
    left_join(weights, by = "factor") %>% 
    mutate(weighted_score = score * weight) %>% 
    pull(weighted_score) %>% sum()
  
  logistic_out <- 0.5 + (0.5/(1+exp(z)))     # Full sigmoid shape constrained between 0.5 and 1, aligned with revised directionality of factor scoring 
  
  
  ##### Calculate percent of Fmsy for Risk Policy integrated control rules
  
  # Define risk tolerance tiers. Currently equal thirds of the 0.5 to 1 recommended probability space.
  # HighRisk<- 0.5+0.5/3
  # LowRisk <- 1-0.5/3
  
  # Approved risk tiers, based on the second derivative of the logistic function
  HighRisk <- 0.61
  LowRisk <- 0.89
  
  rp <- rp %>% mutate(z = z, logistic_out = logistic_out,
                      rec_prob = ifelse(logistic_out<0.5, 0.5, logistic_out),   # floor of 0.5 for recommended probabilities
                      prop_dynamic = 1-(rec_prob-0.5),                          # linear translation between recommended probability and proportion of Fmsy
                      prop_tiered = case_when(rec_prob<HighRisk ~ 0.92,            # Tiered approach, proportions defined as the mean within each tier if using the dynamic approach
                                              between(rec_prob, HighRisk, LowRisk) ~ 0.75,
                                              rec_prob>LowRisk ~ 0.58),
                      pstar_rp_dynamic = 1-rec_prob)
  
  # if(HCR == "dynamic"){prop <- rp %>% pull(prop_dynamic)}
  # if(HCR == "tiered"){prop <- rp %>% pull(prop_tiered)}
  
  # out <- list(prop = prop, rp = rp)
  
  return(rp) ### just returns the proportions of Fmsy for control rules, should do more accounting/saving
  
}
