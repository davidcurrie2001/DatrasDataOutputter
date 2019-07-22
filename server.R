#
# You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


shinyServer(function(input, output, session) {
  
  
  myOutput <- reactiveValues(description = "Loading data", plotData = NULL)
  
  myAllData <- readICES(AllDataFile ,strict=FALSE)
  myHL <- myAllData[["HL"]]
  

 myOutput$plotData <- myHL
 
 myOutput$description <- "Data loaded"
  
  output$myResults <- renderText({
    
    myOutput$description
  })
  
  output$mainPlot <- renderPlotly({
    
    #print("output$mainPlot")
    mySurvey <- input$surveyInput
    mySpecies <- input$speciesInput
    myHaul <- input$haulInput
    mySex <- input$sexInput
    
    HLtoUse <- myOutput$plotData
    
    myRecords <- HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex,]
    
    if(!is.null(myRecords)){
      
         p<-plot_ly(data=myRecords, x = ~LngtClas, y = ~HLNoAtLngt, type = 'bar') %>% 
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


    if (length(myLength)>0 & !is.na(as.numeric(myLength))){
      
      # Convert cm to mm
      myLength <- as.numeric(input$lengthInput) * 10
      
      #HL <- allData[["HL"]]
      #mySurvey <- "IE-IGFS"
      #mySpecies <- 127146
      #myHaul <- 94
      #mySex <- "F"
      #myLength <- as.numeric("28") * 10
      
      HLtoUse <- myOutput$plotData
      
      #myLengthRecords <- myHL[myHL$Survey == mySurvey & myHL$HaulNo==myHaul & myHL$Valid_Aphia==mySpecies & myHL$Sex==mySex & myHL$LngtClas==myLength,]
      myLengthRecords <- HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex & HLtoUse$LngtClas==myLength,]
      
      #myLengthRecords <- HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex & HL()$LngtClas==myLength,]
      
      
      if (NROW(myLengthRecords)==1){
        myOutput$description <- paste("Length already exists:",myLength)
        
        myCount <- myLengthRecords$HLNoAtLngt
        

        #myHL[myHL$Survey == mySurvey & myHL$HaulNo==myHaul & myHL$Valid_Aphia==mySpecies & myHL$Sex==mySex & myHL$LngtClas==myLength,"HLNoAtLngt"]<-myCount+1
        
        HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex & HLtoUse$LngtClas==myLength,"HLNoAtLngt"]<-myCount+1
        
        myOutput$plotData <- HLtoUse
        
        
        myAllData[["HL"]] <- HLtoUse
        
        # Save the new data
        write.csv(myAllData, file= AllDataFile)
        
        #myOutput$plotData <- myHL[myHL$Survey == mySurvey & myHL$HaulNo==myHaul & myHL$Valid_Aphia==mySpecies & myHL$Sex==mySex,]
        
        
        #myCount <- HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex & HL()$LngtClas==myLength,"HLNoAtLngt"]
        #HL()[HL()$Survey == mySurvey & HL()$HaulNo==myHaul & HL()$Valid_Aphia==mySpecies & HL()$Sex==mySex & HL()$LngtClas==myLength,"HLNoAtLngt"] <- myCount + 1
        
      } else {
        myOutput$description <- paste("Length doesn't exist:",myLength)
        
        
        RecordToDuplicate <- HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex,]
        
        if (NROW(RecordToDuplicate)>=1){

          # Only get the first row          
          RecordToDuplicate <- RecordToDuplicate[1,]
          
          RecordToDuplicate$Survey <- mySurvey
          RecordToDuplicate$HaulNo <- myHaul
          RecordToDuplicate$Valid_Aphia <- mySpecies
          RecordToDuplicate$Sex <- mySex
          RecordToDuplicate$LngtClas <- myLength
          
          RecordToDuplicate$HLNoAtLngt <- 1
          
          dataToSave <- rbind(HLtoUse,RecordToDuplicate)
          
          myAllData[["HL"]] <- dataToSave
          
          myOutput$plotData <- dataToSave
          
          # Save the new data
          write.csv(myAllData, file= AllDataFile)
          
        }
        
      }
      
      
    } else {
      
      myOutput$data <- "Error: input was not a number"
    }
    

    

    

  })
  
  
})