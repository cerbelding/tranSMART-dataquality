library("jsonlite")

json_file <- paste(getwd(), "/dev/input.json", sep="")
json_data <- fromJSON(paste(readLines(json_file), collapse=""))
loaded_variables <- json_data

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
  output <- calculate_dataquality(tmp.var2)
  output_json <- toJSON(output)
  #write(output_json, file=paste(getwd(),"/export.JSON",sep=""))
}

calculate_dataquality <- function(input_data){
  splitted_input <- split_dataset(input_data = input_data)
  input_data_numeric <- splitted_input$input_data_numeric
  input_data_categorical <- splitted_input$input_data_categorical
  
  missingvalues_return <- missingvalues(input_data = input_data)
  rate_missing <- missingvalues_return$rate_missing
  rate_missing_cleaned <- missingvalues_return$rate_missing_cleaned
  NAs <- missingvalues_return$NAs
  
  rate_vollstaendigkeit <- completeness(input_data = input_data, NAs = NAs)
  
  ausreisser <- outliers(input_data_numeric = input_data_numeric)
  
  return_value <- list("input_data_numeric"=input_data_numeric,"input_data_categorical"=input_data_categorical, "rate_missing"=rate_missing, "rate_missing_cleaned"=rate_missing_cleaned, "rate_vollstaendigkeit"=rate_vollstaendigkeit, "NAs"=NAs, "ausreisser"=ausreisser)
}
  

#eigene Funktionen, tmp.var2 ist Haupt-Variable (input_data)
split_dataset <- function(input_data){
  ## Schritt 0.2: Aufteilen in numerische und kategorielle Daten
  isnumeric <- sapply(input_data, is.numeric)
  input_data_numeric <- input_data[,isnumeric]
  input_data_categorical <- input_data[,!isnumeric]
  rm(isnumeric) #entfernen d. temporaeren Variable
  return_value <- list("input_data_numeric"=input_data_numeric, "input_data_categorical"=input_data_categorical)
}

missingvalues <- function(input_data){
  ## Schritt 1: Fehlende Werte
  # Erstelle DataFrame mit absoluter Anzahl der NAs pro Variable
  na_count <- sapply(input_data, function(input_data) sum(length(which(is.na(input_data)))))
  NAs <- as.data.frame(na_count)
  rm(na_count)
  
  # fuege Relation der NAs hinzu
  for (i in 1:length(NAs$na_count)) {
    NAs$na_relation[i] <- NAs$na_count[i]/NROW(input_data)
  }
  rm(i)
  
  # entferne alle Variablen ohne NAs
  NAs_only <- NAs[-(which(NAs$na_count == 0)),]
  
  # Variablen ohne jeden Wert
  # entspricht Spalten mit 100% NAs
  NAs_complete <- subset(NAs, NAs$na_relation == 1)
  NAs_complete_rate <- (NROW(NAs_complete)/NCOL(input_data))
  NAs_complete_names <- rownames(NAs_complete)
  
  # entferne zusaetzlich alle Variablen ohne jeden Wert (100% NAs)
  NAs_cleaned <- NAs_only[-(which(NAs$na_relation == 1)),]
  
  # RATE_MISSING
  rate_missing <- sum(NAs_only$na_count) / (NROW(input_data)*NCOL(input_data))
  rate_missing_cleaned <- sum(NAs_cleaned$na_count) / (NROW(input_data)*(NCOL(input_data)-NROW(NAs_complete)))
  return_value <- list("rate_missing" = rate_missing, "rate_missing_cleaned" = rate_missing_cleaned, "NAs"=NAs)
}

completeness <- function(input_data, NAs){
  ## Schritt 2: Vollstaendige Erfassung
  # Liste von Variablen mit Anzahl von NAs = 0
  NAs_noNA <- NAs[which(NAs$na_count == 0),]
  
  # RATE_VOLLSTANDIGKEIT
  rate_vollstandigkeit <- NROW(NAs_noNA)/NROW(input_data)
}

outliers <- function(input_data_numeric){
  ## Schritt 3: Ausreisser bestimmen
  # nur fuer numerische Daten anwendbar
  library(dlookr)
  ausreisser <- diagnose_outlier(input_data_numeric)
}
