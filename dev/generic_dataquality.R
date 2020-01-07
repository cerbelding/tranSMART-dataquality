setwd("C:/Users/corny/Dropbox/Universitat/MA/tranSMART-dataquality/dev/agp")

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
zero_NAs <- which(NAs$na_count == 0)
NAs_only <- NAs[-zero_NAs,]
rm(zero_NAs)

# Variablen ohne jeden Wert
# entspricht Spalten mit 100% NAs

tmp <- subset(NAs, NAs$na_relation == 1)
tmf1013 <- (NROW(tmp)/NCOL(input_data))
tmf1013_names <- rownames(tmp)
rm(tmp)

