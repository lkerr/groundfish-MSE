## Define server logic required to run scripts
## ------------------------------------------------------------------------------------ ##
#Create the serve that allows the user interface to connect to functions.
ffiles <- list.files(path='Functions/', pattern="^.*\\.R$",full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))
shinyServer(function(input, output, session) {
  
  #Plot for HCRs, depends on user input.
  observeEvent(input$do,{
    saveData(input$OMScenario,input$RhoScenario,input$FreqScenario,input$HCR)
    output$plts<-renderPlot(DoPlots(values$Outs,values$Outs$Parms,10))})
  
  observeEvent(input$compare,{#Response if user clicks 'Compare Scenarios'.
    output$spider<-renderPlot({#A plot is formed from the same data from loadData()
      par(mar=c(5.8,4.8,4.8,8.8),xpd=TRUE)
      spiderplot(loadData())#spiderplot function creates a good plot for comparing management strategies
      legend("topright",legend=rows,bty='n',pch=16,col=colors_line,cex=1,pt.cex=3)},
      height = 600, width = 900)})
  
})  # End of ShinyServer
## ------------------------------------------------------------------------------------ ##




