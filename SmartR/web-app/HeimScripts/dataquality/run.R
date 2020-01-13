library("jsonlite")

##Input-Daten = variable 'loaded_variables'
main <- function() {
  #uebergebene Parameter zwischenspeichern
  tmp.params <- fetch_params
  
  #uebergebene Variablen zwischenspeichern und zu DataFrame konvertieren
  tmp.var1 <- unlist(loaded_variables, recursive = FALSE)
  tmp.var1 <- as.data.frame(tmp.var1)

  #Duplikat-Spalten entfernen
  tmp.delColumns <- grep("Row.Label", colnames(tmp.var1))
  tmp.delColumns <- tmp.delColumns[2:length(tmp.delColumns)]
  tmp.var2 <- tmp.var1[,-tmp.delColumns]
  
  #temporaere Dateien freigeben
  remove(tmp.var1, tmp.delColumns)
  
  number <- length(tmp.params$ontologyTerms)
  
  tmp.nameList = character(number)
  tmp.keyList = character(number)
  for (i in 1:number) {
    tmp.subIndex <- gregexpr(pattern = "\\\\", tmp.params$ontologyTerms[[i]]$key)[[1]]
    tmp.subLength <- length(tmp.subIndex)
    
    tmp.malus <- 0;
    if (is.null(tmp.params$ontologyTerms[[i]]$metadata$unitValues$normalUnits)) {tmp.malus <- 1}
    
    tmp.nameList[i] <- substr(tmp.params$ontologyTerms[[i]]$key, tmp.subIndex[tmp.subLength-1-tmp.malus]+1, tmp.subIndex[tmp.subLength-tmp.malus]-1)
    tmp.keyList[i] <- substr(tmp.params$ontologyTerms[[i]]$key, tmp.subIndex[3], tmp.subIndex[tmp.subLength-1])
  }
  tmp.nameList <- unique(tmp.nameList);
  tmp.keyList <- unique(tmp.keyList)
  
  ## Format to tmp.var2 design
  tmp.keyList <- gsub(" ", ".", tmp.keyList)
  tmp.keyList <- gsub("\\(", ".", tmp.keyList)
  tmp.keyList <- gsub("\\)", ".", tmp.keyList)
  tmp.keyList <- gsub("-", ".", tmp.keyList)
  tmp.keyList <- gsub("\\/", ".", tmp.keyList)
  tmp.keyList <- gsub("\\\\", ".", tmp.keyList)
  
  colnames(tmp.var2)[1] <- "internalId"
  
  
    for (i in 1:length(tmp.keyList)) {
    tmp.currentCols <- grep(tmp.keyList[i], colnames(tmp.var2))
    tmp.var2[,tmp.currentCols[1]] <- as.character(tmp.var2[,tmp.currentCols[1]])
    
    if (length(tmp.currentCols) > 1) {	
      for (idx in tmp.currentCols[2:length(tmp.currentCols)]) {
        tmp.var2[,tmp.currentCols[1]] <- ifelse(is.na(tmp.var2[,tmp.currentCols[1]]) | tmp.var2[,tmp.currentCols[1]] == "", as.character(tmp.var2[,idx]), tmp.var2[,tmp.currentCols[1]])
      }
      
      tmp.var2 <- tmp.var2[,-tmp.currentCols[2:length(tmp.currentCols)]]
    }
    
    
    
    colnames(tmp.var2)[tmp.currentCols[1]] <- gsub(" ", "", tmp.nameList[i])
  }
}

#tmp.var2 ist Haupt-Variable (input_data)