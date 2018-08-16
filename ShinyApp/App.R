############################################################
## Introduction to Shiny and example app for COCA Groundfish MSE
## A.E. Weston
## 6/14/2018
################################################
setwd("C:/Users/aweston/OneDrive - Gulf of Maine Research Institute/COCA/Shiny/rsconnect/shinyapps.io/aweston")

# cheat sheet - super helpful!
#https://shiny.rstudio.com/images/shiny-cheatsheet.pdf
#install.packages("shiny")

### General template to follow (4 parts):
#library(shiny)

#ui <- fluidPage("put things here") # organize user interface page layout here

#server <- function(input, output) {}

#shinyApp(ui = ui, server = server)

### Notes:
# think in terms of inputs and outputs

# Input options include; buttons, checkboxes, checkbox group, date input, date range, 
# file input, numeric input, password,radio buttons, select box, sliders, text

# output options include; interactive tables, images, html, plots, text


#shinyapp.io to create an account
# this allows you to create a shareable website for shiny app
#library(rsconnect)
#http://shiny.rstudio.com/articles/shinyapps.html

# examples of other shiny apps
# IPCH : https://iphc.shinyapps.io/MSAB/
# MADMF: https://madmf.shinyapps.io/ibs2/-
# Punt Tuna MSE: https://puntapps.shinyapps.io/tunamse/


# testing 
library(shiny)

ui <- fluidPage(
  headerPanel("Management Strategy Evaluation for New England Groundfish Fisheries in a Changing Climate"),# title of the page
    sidebarLayout( # page will have a side bar and then a main section on the page 
    sidebarPanel( # format sidebar inputs
      # include a selection for species
      HTML("<p>Choose a species, climate scenario, biological reference point, and havest control rule below:</p>"), #insert raw text
      radioButtons(inputId  = "Spp", "Species:", c("Cod", "Haddock", "Yellowtail Flounder")),
      radioButtons(inputId = "climate", "Climate Scenario:", c("High Emissions (RCP 8.5)", "Low Emissions (RCP 4.5)")),
      radioButtons(inputId = "BRP", "Biological Reference Point:", c("FMSY", "FSPR")), # Biological reference point options 
      radioButtons(inputId = "HCR", "Harvest Control Rule:", c("Ramp", "Constant Rate" , "Constant Catch")), # I made these up - will need actual descriptors
      plotOutput("CR") #plot of HCRs 
    ),
    mainPanel( # setup for creating output plots 
       plotOutput("SSB"),
       plotOutput("REC")
      )
  )
)

server <- function(input, output) {   # code to create output using render
  #source("runSim.R") # dont need this 
  output$CR <- renderPlot({
    if (input$HCR == "Ramp") {
      r <- c(0.0, 0.0, 0.1, 0.2, 0.3, 0.3, 0.3)
    }
    if (input$HCR == "Constant Rate") {
      r <- rep(0.3, 7)
    }
    if (input$HCR == "Constant Catch"){
      r <- c(0.3, 0.25, 0.23, 0.22, 0.21, 0.20, 0.20)
    }
    plot(r, type = 'l', ylab = "Fishing Mortality", xlab = "Spawning Stock Biomass", xaxt = 'n', main = "Harvest Control Rule", cex.lab = 1.5, cex.axis = 1.5)
  })
  load("omval2018-06-20_155605_8254.RData") # read in the output 
  
  #spawning stock biomass over forecast years
  output$SSB <- renderPlot({ # could eventually plot mean and 95% confidence intervals from all simulations 
    options(scipen = 999)
    if (input$HCR == "Ramp") {
      i <- 1
    }
    if (input$HCR == "Constant Rate") {
      i <- 2 
    }
    if (input$HCR == "Constant Catch"){
      i <- 3
    }
    der_1 <- omval$SSB[,i,]
    der_1_mean <- colMeans(der_1)
    library('matrixStats')
    quants <- colQuantiles(der_1, probs = c(0.025, 0.975))
    plot(der_1_mean, type = 'l', xlab = "Forecast Year", ylab = "Spawning Stock Biomass (mt)", ylim = c(0, 15000), lwd = 2, cex.lab = 1.5, cex.axis = 1.5)
    polygon(c(seq(1:11), rev(seq(1:11))), c(quants[,1], rev(quants[,2])), col = adjustcolor("gray45", alpha.f = 0.10), border = NA)
    })
  
  #recruitment over forecast years
  output$REC <- renderPlot({ # could eventually plot mean and 95% confidence intervals from all simulations 
    if (input$HCR == "Ramp") {
      i <- 1
    }
    if (input$HCR == "Constant Rate") {
      i <- 2 
    }
    if (input$HCR == "Constant Catch"){
      i <- 3
    }
    der_2 <- omval$R[,i,]
    der_2_mean <- colMeans(der_2)
    quants_2 <- colQuantiles(der_2, probs = c(0.025, 0.975))
    plot(der_2_mean, type = 'l', xlab = "Forecast Year", ylab = "Recruitment", ylim = c(0,1000000), lwd = 2, cex.lab = 1.5, cex.axis = 1.5)
    polygon(c(seq(1:11), rev(seq(1:11))), c(quants_2[,1], rev(quants_2[,2])), col = adjustcolor("gray45", alpha.f = 0.10), border = NA)
    
    })
}

shinyApp(ui, server)


### publishing the app will give you a web address so others can access:
#rsconnect::deployApp("C:/Users/aweston/OneDrive - Gulf of Maine Research Institute/COCA/Shiny")

