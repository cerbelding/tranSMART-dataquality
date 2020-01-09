setwd("C:/Users/corny/Dropbox/Universitat/MA/tranSMART-dataquality/dev")

## Schritt 0.1: Laden der Daten
input_data <- read.delim("clinical/subjects_data.tsv", na.strings="N/A")

## Schritt 0.2: Aufteilen in numerische und kategorielle Daten
isnumeric <- sapply(input_data, is.numeric)
input_data_numeric <- input_data[,isnumeric]
input_data_categorical <- input_data[,!isnumeric]
rm(isnumeric)


## Schritt 1: Fehlende Werte
# fuer numerische und kategorielle Werte gleich

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

# entferne alle Variablen ohne jeden Wert (100% NAs)
NAs_cleaned <- NAs_only[-(which(NAs$na_relation == 1)),]

# RATE_MISSING
rate_missing <- sum(NAs_only$na_count) / (NROW(input_data)*NCOL(input_data))
rate_missing_cleaned <- sum(NAs_cleaned$na_count) / (NROW(input_data)*NCOL(input_data))

## Schritt 2: Vollstaendige Erfassung
# Liste von Variablen mit Anzahl von NAs = 0
NAs_noNA <- NAs[which(NAs$na_count == 0),]

# RATE_VOLLSTANDIGKEIT
rate_vollstandigkeit <- NROW(NAs_noNA)/NROW(input_data)

## Schritt 3: Ausreisser
# Ausreisser fur numerische Daten
library(dlookr)
ausreisser <- diagnose_outlier(input_data_numeric)
#Erkennung durch boxplot.stats Package: Ausreisser = Punkte außerhalb des 1.5-fachen IQR

#numerische Ausreisser visualisieren
plot_outlier(input_data_numeric)

