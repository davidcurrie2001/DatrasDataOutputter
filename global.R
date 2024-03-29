library(shiny)
library(DATRAS)
library(plotly)
library(data.table)

DefaultText <- "Any"

# File names
AllDataFile <- "data/DATRAS_Exchange_Data.csv"
myFilters <- "data/myFilters.csv"

# Save to the DATRAS exchange format
saveDatras <- function(HHtoSave, HLtoSave, CAtoSave, filename){
  
  ## TODO: we might need to convert NAs into -9s before we save the data
  
  # Convert NAs to -9 for HL$Sex
  HLtoSave$Sex <- NAsAsMinus9(HLtoSave$Sex)
  

  # Try and remove any added columns
  HHcolsToRemove <- list("haul.id","Abstime","TimeOfYear","TimeShotHour","Lon","Lat","Roundfish","abstime","timeOfYear","lon","lat")
  HHtoSave <- HHtoSave[, !(names(HHtoSave) %in%  HHcolsToRemove)]
  
  HLcolsToRemove <- list("haul.id","LngtCm","Species","HaulDur","DataType","Count")
  HLtoSave <- HLtoSave[, !(names(HLtoSave) %in%  HLcolsToRemove)]
  
  CAcolsToRemove <- list("haul.id","StatRec","LngtCm","Species")
  CAtoSave <- CAtoSave[, !(names(CAtoSave) %in%  CAcolsToRemove)]
  
  # HH
  #write.table(HHtoSave, file= filename, sep=",", append=FALSE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  fwrite(HHtoSave, file= filename, sep=",", append=FALSE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  
  # HL
  #write.table(HLtoSave, file= filename, sep=",", append=TRUE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  fwrite(HLtoSave, file= filename, sep=",", append=TRUE,quote=FALSE, row.names=FALSE, col.names = TRUE)
 
  # CA
  #write.table(CAtoSave, file= filename, sep=",", append=TRUE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  fwrite(CAtoSave, file= filename, sep=",", append=TRUE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  
   
}

FilterHLData <- function(HL, Year, Survey, Species, Haul, Sex, Length){
  
  HLoutput <- HL
  
  if (Year != DefaultText){
    HLoutput <- HLoutput[HLoutput$Year == Year,]
  }
  
  if (Survey != DefaultText){
    HLoutput <- HLoutput[HLoutput$Survey == Survey,]
  }
  
  if (Species != DefaultText){
    HLoutput <- HLoutput[HLoutput$Valid_Aphia == Species,]
  }
  
  if (Haul != DefaultText){
    HLoutput <- HLoutput[HLoutput$HaulNo == Haul,]
  }
  
  if (Sex != DefaultText){
    #HLoutput <- HLoutput[HLoutput$Sex == Sex,]
    HLoutput <- HLoutput[NAsAsMinus9(HLoutput$Sex) == Sex,]
  }
  
  if (Length != DefaultText){
    HLoutput <- HLoutput[HLoutput$LngtClas == Length,]
  }
  
  HLoutput

}

NAsAsMinus9 <- function (myList){
  
  myList <- as.character(myList)
  myList[is.na(myList)]<-"-9"
  myList <- as.factor(myList)
  myList
  
}

