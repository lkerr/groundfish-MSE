## Define server logic required to run scripts
## ------------------------------------------------------------------------------------ ##
#Create the serve that allows the user interface to connect to functions.
ffiles <- list.files(path='Functions/', pattern="^.*\\.R$",full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))
shinyServer(function(input, output, session) {
  
  #Plot for HCRs, depends on user input.
  output$CTL2 <- renderPlot({ MSEPlots(input$HCR,input$RefPoints,input$sa) })
  
})  # End of ShinyServer
## ------------------------------------------------------------------------------------ ##




