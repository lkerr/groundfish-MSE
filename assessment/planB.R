

# Run the planB assessment model (Legault)
# info can be found at:
# https://github.com/cmlegault/PlanBsmooth
# 
# 
# 


# Compile the data for the annual trend
planBdata <- data.frame(Year = sty:y, 
                        avg = get_dwindow(obs_sumIN, sty, y))

planBest <- ApplyPlanBsmooth(dat = planBdata,
                             od = 'results/',
                             my.title = 'planB',
                             terminal.year = NA,
                             nyears = 33,
                             saveplots = FALSE,
                             showplots = FALSE)
