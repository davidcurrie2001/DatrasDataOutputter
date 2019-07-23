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
  
  myAllData <- readICES(AllDataFile ,strict=TRUE)
  myHL <- myAllData[["HL"]]
  myCA <- myAllData[["CA"]]
  myHH <- myAllData[["HH"]]
  
  # Set the drop down list values
  
  #Year
  updateSelectInput(session, "yearInput", label = NULL, choices = c("Any"="Any",sort(unique(as.character(myHL$Year)))) ,selected = NULL)
  
  # Hauls
  updateSelectInput(session, "haulInput", label = NULL, choices = c("Any"="Any",sort(unique(as.character(myHL$HaulNo)))) ,selected = NULL)

  # Species
  specChoices <- specCount[specCount$haul.id>500,c("Valid_Aphia","ScientificName_WoRMS")]
  choices = setNames(specChoices$Valid_Aphia,specChoices$ScientificName_WoRMS)
  updateSelectInput(session, "speciesInput", label=NULL, choices = choices, selected=NULL)
  
  
  
  
 myOutput$plotData <- myHL
 
 myOutput$description <- "Data loaded"
  
  output$myResults <- renderText ({
    
    paste('<strong style="color: red;">',myOutput$description,'</strong>',sep='')
    

  })
  
  output$mainPlot <- renderPlotly({
    
    #print("output$mainPlot")
    myYear <- input$yearInput
    mySurvey <- input$surveyInput
    mySpecies <- input$speciesInput
    myHaul <- input$haulInput
    mySex <- input$sexInput
    
    HLtoUse <- myOutput$plotData
    
    #myRecords <- HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex,]
    
    myRecords <- FilterHLData(HL=HLtoUse, Year= myYear, Survey= mySurvey, Species=mySpecies, Haul=myHaul, Sex=mySex, Length=DefaultText)
    
    if(!is.null(myRecords)){
      
         p<-plot_ly(data=myRecords, x = ~LngtClas, y = ~HLNoAtLngt, type = 'bar') %>% 
           layout(title = 'Length record counts', xaxis = list(title = 'Length class'),yaxis = list(title = 'Number at length'))
    } else {
      
      p<-plotly_empty()
    }
    
    

    
  })
  
  # Save the data to the Exchange format cvs file
  # observeEvent(input$save, {
  #   
  #   saveDatras(HHtoSave=myHH, HLtoSave=myOutput$plotData, CAtoSave=myCA, filename=AllDataFile)
  #   
  #   myOutput$description <- "Data saved"
  #   
  # })
  
  # Record the measurement
  observeEvent(input$go, {
    
    myOutput$data <- input$lengthInput

    myLength <- input$lengthInput
    myYear <- input$yearInput
    mySurvey <- input$surveyInput
    mySpecies <- input$speciesInput
    myHaul <- input$haulInput
    mySex <- input$sexInput

    # If we haven't the filtered the data properly then don't go any further
    if (mySurvey==DefaultText | mySpecies==DefaultText | myHaul == DefaultText | mySex == DefaultText){
      myOutput$description <- "You can't update lengths unless you have selected values for all the filters first"
    } 
    # else check if we have an actual number and try and proceed
    else if (length(myLength)>0 & !is.na(as.numeric(myLength))){
      
      # Convert cm to mm
      myLength <- as.numeric(input$lengthInput) * 10
      
      HLtoUse <- myOutput$plotData
      
      #myLengthRecords <- HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex & HLtoUse$LngtClas==myLength,]
      
      myLengthRecords <- FilterHLData(HL=HLtoUse, Year=myYear, Survey= mySurvey, Species=mySpecies, Haul=myHaul, Sex=mySex, Length=myLength)
      

      if (NROW(myLengthRecords)==1){
        myOutput$description <- paste("Length already exists - appending to:",myLength)
        
        myCount <- myLengthRecords$HLNoAtLngt
        
        HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex & HLtoUse$LngtClas==myLength,"HLNoAtLngt"]<-myCount+1
        
        myOutput$plotData <- HLtoUse
        
        myHL <- HLtoUse
        
        saveDatras(HHtoSave=myHH, HLtoSave=myOutput$plotData, CAtoSave=myCA, filename=AllDataFile)
        
        
      } else {
        myOutput$description <- paste("Length doesn't exist - creating new entry for:",myLength)
        
        
        #RecordToDuplicate <- HLtoUse[HLtoUse$Survey == mySurvey & HLtoUse$HaulNo==myHaul & HLtoUse$Valid_Aphia==mySpecies & HLtoUse$Sex==mySex,]
        
        RecordToDuplicate <- FilterHLData(HL=HLtoUse, Year=myYear, Survey= mySurvey, Species=mySpecies, Haul=myHaul, Sex=mySex, Length=DefaultText)
        
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

          myOutput$plotData <- dataToSave
          
          myHL <- dataToSave
          
          saveDatras(HHtoSave=myHH, HLtoSave=myOutput$plotData, CAtoSave=myCA, filename=AllDataFile)
          
        }
        
      }
      
      
    } else {
      
      myOutput$data <- "Error: input was not a number"
    }
    

    

    

  })
  
  
})