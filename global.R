library(shiny)
library(DATRAS)
library(plotly)

DefaultText <- "Any"

# File names
AllDataFile <- "data/DATRAS_Exchange_Data.csv"
myFilters <- "data/myFilters.csv"

# Save to the DATRAS exchange format
saveDatras <- function(HHtoSave, HLtoSave, CAtoSave, filename){
  

  # Try and remove any added columns
  HHcolsToRemove <- list("haul.id","Abstime","TimeOfYear","TimeShotHour","Lon","Lat","Roundfish","abstime","timeOfYear","lon","lat")
  HHtoSave <- HHtoSave[, !(names(HHtoSave) %in%  HHcolsToRemove)]
  
  HLcolsToRemove <- list("haul.id","LngtCm","Species","HaulDur","DataType","Count")
  HLtoSave <- HLtoSave[, !(names(HLtoSave) %in%  HLcolsToRemove)]
  
  CAcolsToRemove <- list("haul.id","StatRec","LngtCm","Species")
  CAtoSave <- CAtoSave[, !(names(CAtoSave) %in%  CAcolsToRemove)]
  
  # HH
  write.table(HHtoSave, file= filename, sep=",", append=FALSE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  
  # HL
  write.table(HLtoSave, file= filename, sep=",", append=TRUE,quote=FALSE, row.names=FALSE, col.names = TRUE)
 
  # CA
  write.table(CAtoSave, file= filename, sep=",", append=TRUE,quote=FALSE, row.names=FALSE, col.names = TRUE)
  
  
   
}