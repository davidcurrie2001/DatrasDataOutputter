#
# This is a template project for WKSEATEC DATRAS QC apps. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



shinyUI(fluidPage(
  
  # Application title
  titlePanel("DATRAS Data Input"),
  
  fluidRow(
    column(2,textInput("surveyInput",label="Survey",value="IE-IGFS")),
    #column(2,textInput("yearInput",label="Year",value="2018")),
    column(2,selectInput("yearInput",label="Year",choices=NULL)),
    #column(1,textInput("haulInput",label="Haul",value="94")),
    column(2,selectInput("haulInput",label="Haul",choices= c("Any"="Any"))),
    #column(2,textInput("speciesInput",label="Species",value="127146")),
    column(3,selectInput("speciesInput",choices=NULL,label="Species")),
    #column(2,textInput("sexInput",label="Sex",value="F"))
    column(2,selectInput("sexInput",label="Sex",choices= c("Any"="Any","Female"= "F", "Male" = "M", "Unidentified" = "U")))

  ),
  
  fluidRow(
    column(2,textInput("lengthInput",label="Length (cm)"))
  ),
  fluidRow(
    column(2,actionButton("go", label = "Go"))
    #column(2,actionButton("save", label = "Save"))
  ),
  fluidRow(
    column(12,htmlOutput("myResults"))
  ),
  
  fluidRow(
     column(12,plotlyOutput("mainPlot"))
   )
  
  
))
