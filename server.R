#
# This is a template project for WKSEATEC DATRAS QC apps. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


shinyServer(function(input, output, session) {
  
  
  ## STANDARD REACTIVE DATRAS DATA START
  
  # Use reactivePoll so that our data will be updated when the data or filter files are updated
  datrasData <- reactivePoll(1000, session,
                             # This function returns the time that files were last modified
                             checkFunc = function() {
                               myValue <- ''
                               if (file.exists(AllDataFile)) {
                                 myValue <- paste(myValue , file.info(AllDataFile)$mtime[1])
                               }
                               myValue
                             },
                             # This function returns the content the files
                             valueFunc = function() {
                               #print('Loading data')
                               allData <- ''
                               if (file.exists(AllDataFile)) {
                                 allData <- readICES(AllDataFile ,strict=TRUE)
                               }
                               allData
                             }
  )
  
  datrasFilters <- reactivePoll(1000, session,
                                # This function returns the time that files were last modified
                                checkFunc = function() {
                                  myValue <- ''
                                  if (file.exists(myFilters)) {
                                    myValue <- paste(myValue , file.info(myFilters)$mtime[1])
                                  }
                                  myValue
                                },
                                # This function returns the content the files
                                valueFunc = function() {
                                  #print('Loading data')
                                  filters <- ''
                                  if (file.exists(myFilters)){
                                    filters <- read.csv(myFilters, header = TRUE, stringsAsFactors=FALSE, colClasses = c("character"))
                                  }
                                  filters
                                }
  )
  
  
  # Reactive data
  myData<- reactive({
    
    d <- datrasData()
    f <- datrasFilters()
    
    dataToUse <- FilterData(d,f)
    
  })
  
  # Unfiltered data
  myUnfilteredData<- reactive({
    
    d <- datrasData()
    
  })
  
  # Reactive HL data
  HL<- reactive({
    if ("HL" %in% names(myData()))
      myData()[["HL"]]
  })
  
  # Reactive HH data
  HH<- reactive({
    if ("HH" %in% names(myData()))
      myData()[["HH"]]
  })
  
  # Reactive CA data
  CA<- reactive({
    if ("CA" %in% names(myData()))
      myData()[["CA"]]
  })
  
  # Reactive unfiltered HL data
  unfilteredHL<- reactive({
    if ("HL" %in% names(myUnfilteredData()))
      myUnfilteredData()[["HL"]]
  })
  
  # Reactive unfiltered HH data
  unfilteredHH<- reactive({
    if ("HH" %in% names(myUnfilteredData()))
      myUnfilteredData()[["HH"]]
  })
  
  # Reactive unfiltered CA data
  unfilteredCA<- reactive({
    if ("CA" %in% names(myUnfilteredData()))
      myUnfilteredData()[["CA"]]
  })
  
  ## STANDARD REACTIVE DATRAS DATA END
  
  myAllData <- readICES(AllDataFile ,strict=TRUE)
  myHL <- myAllData[["HL"]]
  
  # Add your Shiny app code
  
  # This is just a simple example plot to show the number of CA records
  # output$mainPlot <- renderPlotly({
  #   
  #   countBySpecies <- aggregate(RecordType ~ ScientificName_WoRMS + Sex, data = CA(), length)
  #   
  #   countBySpecies$NameAndSex <- paste(countBySpecies$ScientificName_WoRMS,countBySpecies$Sex,sep="-")
  #   
  #   p<-plot_ly(data=countBySpecies, x = ~NameAndSex, y = ~RecordType, type = 'bar') %>% 
  #     layout(title = 'Biological record counts', xaxis = list(title = 'Species-Sex'),yaxis = list(title = 'Record count'))
  #   
  # })
  
  myOutput <- reactiveValues(data = NULL, plotData = NULL)
  
  output$myResults <- renderText({
    
    myOutput$data
  })
  
  output$mainPlot <- renderPlotly({
    
    print("output$mainPlot")
    #mySurvey <- input$surveyInput
    #mySpecies <- input$speciesInput
    #myHaul <- input$haulInput
    #mySex <- input$sexInput
    
    #myRecords <- HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex,]
    
    if(!is.null(myOutput$plotData)){
      
         p<-plot_ly(data=myOutput$plotData, x = ~LngtClas, y = ~HLNoAtLngt, type = 'bar') %>% 
           layout(title = 'Length record counts', xaxis = list(title = 'Length class'),yaxis = list(title = 'Number at length'))
    } else {
      
      p<-plotly_empty()
    }
    
    

    
  })
  

  observeEvent(input$action, {
    
    myOutput$data <- input$lengthInput

    myLength <- input$lengthInput
    mySurvey <- input$surveyInput
    mySpecies <- input$speciesInput
    myHaul <- input$haulInput
    mySex <- input$sexInput


    
    # Plot the length counts
    myOutput$plotData<-myRecords
    
    if (length(myLength)>0 & !is.na(as.numeric(myLength))){
      
      # Convert cm to mm
      myLength <- as.numeric(input$lengthInput) * 10
      
      #HL <- allData[["HL"]]
      #mySurvey <- "IE-IGFS"
      #mySpecies <- 127146
      #myHaul <- 94
      #mySex <- "F"
      #myLength <- as.numeric("28") * 10
      
      myLengthRecords <- myHL[myHL$Survey == mySurvey & myHL$HaulNo==myHaul & myHL$Valid_Aphia==mySpecies & myHL$Sex==mySex & myHL$LngtClas==myLength,]
      
      #myLengthRecords <- HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex & HL()$LngtClas==myLength,]
      
      
      if (NROW(myLengthRecords)==1){
        myOutput$data <- paste("Length already exists:",myLength)
        
        myCount <- myLengthRecords$HLNoAtLngt
        
        myHL[myHL$Survey == mySurvey & myHL$HaulNo==myHaul & myHL$Valid_Aphia==mySpecies & myHL$Sex==mySex & myHL$LngtClas==myLength,"HLNoAtLngt"]<-myCount+1
        
        myOutput$plotData <- myHL[myHL$Survey == mySurvey & myHL$HaulNo==myHaul & myHL$Valid_Aphia==mySpecies & myHL$Sex==mySex,]
        
        
        #myCount <- HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex & HL()$LngtClas==myLength,"HLNoAtLngt"]
        #HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex & HL()$LngtClas==myLength,"HLNoAtLngt"] <- myCount + 1
        
      } else {
        myOutput$data <- paste("Length doesn't exist:",myLength)
      }
      
      
    } else {
      
      myOutput$data <- "Error: input was not a number"
    }
    

    

    

  })
  
  
})