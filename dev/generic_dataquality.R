# R-Skript zum Laden eines Datensatzes im TM-BATCH Format und anschliessender Bewertung der Datenqualitaet
# Author: Cornelius Knopp

## Schritt 0.1: Laden der Daten
input_data <- read.delim("agp/clinical/subjects_data.tsv", na.strings="N/A")
 
splitted_input <- split_dataset(input_data = input_data)
input_data_numeric <- splitted_input$input_data_numeric
input_data_categorical <- splitted_input$input_data_categorical

missingvalues_return <- missingvalues(input_data = input_data)
rate_missing <- missingvalues_return$rate_missing
rate_missing_cleaned <- missingvalues_return$rate_missing_cleaned
NAs <- missingvalues_return$NAs

rate_vollstaendigkeit <- completeness(input_data = input_data, NAs = NAs)

ausreisser <- outliers(input_data_numeric = input_data_numeric)

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
