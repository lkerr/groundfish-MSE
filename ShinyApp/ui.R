library(shiny)
library(markdown)
library(ggmap)
library(shinythemes)

# ----------------------------------------#
# MAIN USER INTERFACE FOR THE APPLICATION #
# ----------------------------------------#

#Beginning of user interface code. This part sets up the first page, in this case, the 'about' page.
#You can write a markdown to add any blocks of text. 
shinyUI(fluidPage(theme = shinytheme("cerulean"),
                  navbarPage("New England Groundfish MSE",
                             tabPanel("About",
                                      mainPanel(tabsetPanel(
                                        tabPanel(includeMarkdown("AboutE.md")))
                                      )
                             ),
                             
                             
                             #This part sets up the second page, in this case, the 'specifications' page.
                             tabPanel("Specifications",
                                      fillPage(div(helpText("Specifcations"), style = "font-size:100%"),
                                               tags$div(selectInput("OMScenario", "OM and Misspecification Scenario:", #Select input allows the user to pick an optino from a dropdown. 
                                                                    c("Overfished Scneario 1" = "overfish1",
                                                                      "Overfished Scenario 2" = "overfish2",
                                                                      "Not Overfished Scenario 1"= "notoverfish1",
                                                                      "Not Overfished Scenario 2" = "notoverfish2",
                                                                      "Misspecified Scenario 1" = "misspec1",
                                                                      "Misspecified Scenario 2" = "misspec2")),
                                                        style = "font-size:100%"),
                                               tags$div(selectInput("RefPoints", "Reference Points:",
                                                                    c("Climate responsive" = "Refclimresp",
                                                                      "Temperature linked" = "Reftemplink",
                                                                      "Status quo"= "Refstatquo")),
                                                        style = "font-size:100%"), 
                                               tags$div(selectInput("sa", "Stock assessment:",
                                                                    c("Temperature incorporated" = "tempinc",
                                                                      "Time-varying process" = "tvproc",
                                                                      "Status quo"= "Sastatquo")),
                                                        style = "font-size:100%"), 
                               mainPanel(#plotOutput can create a plot based on user input. 
                                        plotOutput("CTL2",width="400px",height="300px"),
                                        actionButton("do", "Do projections"),#Creates a button that will initiate an action. 
                                        plotOutput("plts")),
                             ), # Specifications
                             
                  ))))

