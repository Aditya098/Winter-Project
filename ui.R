
library(shiny)
library(plotly)
library(httr)
library(devtools)
library(twitteR)
library(ggmap)
library(maps)
library(ggplot2)
library(NbClust)
library(httr)
library(devtools)


shinyUI(fluidPage(
  
  navbarPage("Clustering Visz.of Twitter followers on World Map ",
             sidebarLayout(
               sidebarPanel(
                 
                 radioButtons('sep', 'Want to use default Keys or new keys for Twitter API',
                              c(DEFAULT ='default'
                                ),
                              'default'),
                 
                 
                 textInput("usernam", "Enter the username" , value = "oneplus"),
                 numericInput("ab", 
                              label = "How many followers you want to show in the plot ",  
                              value =1500 , max = 6000),
                 hr()
                 
               ),
               
               hr()
               
               
             ),
             mainPanel( 
               plotOutput("plot1")
             )
  )
)
)