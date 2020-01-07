setwd("C:/Users/corny/Dropbox/Universitat/MA/tranSMART-dataquality/dev/agp")

#Laden der Daten
input_data <- read.delim("clinical/subjects_data.tsv", na.strings="N/A")
input_data_excluded <- read.delim("clinical/excl_subjects_data.tsv", na.strings="N/A")
#Anschauen der Daten
# View(input_data)

##TMF-1013 - TMF-1017

#Erstelle 'NAs' als dataframe
na_count <- sapply(input_data, function(input_data) sum(length(which(is.na(input_data)))))
NAs <- as.data.frame(na_count)
rm(na_count)

for (i in 1:length(NAs$na_count)) {
  NAs$na_relation[i] <- NAs$na_count[i]/NROW(input_data)
}
rm(i)
#TMF-1013 - Anteil fehlender Datenelemente
# entspricht Spalten mit 100% NAs

tmp <- subset(NAs, !NAs$na_relation != 1)
tmf1013 <- (NROW(tmp)/NCOL(input_data))
tmf1013_names <- rownames(tmp)
rm(tmp)

#TMF-1014 - Anteil fehlender Werte bei mandatorischen Datenelementen
#TMF-1015 - Anzahl fehlender Werte bei optionalen Datenelementen
#keine Info welche Elemente mandatorisch
#daher: zaehle alle NAs, dann in Relation zu Anzahl Variablen setzen
tmf1015 <- (sum(NAs$na_relation/NROW(NAs)))

#TMF-1016 - Anteil von Datenelementen mit unbekanntem Wert
#nicht beantwortbar

#TMF-1017 - Datenelemente mit bestehenden Eintraegen bei allen Beobachtungseinheiten
#alle Elemente mit na_relation=0
tmp <- subset(NAs, !NAs$na_relation != 0)
tmf1017 <- (NROW(tmp)/NROW(NAs))
tmf1017_names <- rownames(tmp)
rm(tmp)

# entferne alle Variablen aus 'input_data', zu denen ueberhaupt kein Eintrag besteht
# setzt alle EIntraege zu Text statt numeric
library(data.table)
t_input_data <- transpose(input_data)
colnames(t_input_data) <- rownames(input_data)
rownames(t_input_data) <- colnames(input_data)
t_input_data_cleaned <- subset(t_input_data, subset = NAs$na_relation < 1)
input_data_cleaned <- transpose(t_input_data_cleaned)
colnames(input_data_cleaned) <- rownames(t_input_data_cleaned)
rownames(input_data_cleaned) <- colnames(t_input_data_cleaned)
rm(t_input_data,t_input_data_cleaned)

#TMF-1007 - Bevorzugung bestimmter Endziffern
#betrifft die Variablen age_years, bmi, weight_kg und height_cm
#nur bedingt aussagekraeftig, da gemessen
tmp.nums <- unlist(lapply(input_data, is.numeric))
input_data_numeric <- input_data[, tmp.nums]
library(stringr)
tmf1007 <- NULL

for (i in 1:NROW(input_data_numeric)) {
  tmf1007$age_years[i]  <- str_sub(input_data_numeric$age_years[i], start = -1)
  tmf1007$bmi[i]  <- str_sub(floor(input_data_numeric$bmi[i]), start = -1) #abrunden
  tmf1007$height_cm[i]  <- str_sub(input_data_numeric$height_cm[i], start = -1)
  tmf1007$weight_kg[i]  <- str_sub(input_data_numeric$weight_kg[i], start = -1)
}
table(tmf1007$age_years)
table(tmf1007$bmi)
table(tmf1007$bmi)
table(tmf1007$height_cm)
table(tmf1007$weight_kg)

#------- Allgemeine Berechnungen
library(dlookr)
tmp.describe <- describe(input_data)
tmp.diagnose <- diagnose(input_data)
tmp.diagnose.category <- diagnose_category(input_data)
tmp.diagnose.numerical <- diagnose_numeric(input_data)
tmp.diagnose.outlier <- diagnose_outlier(input_data)
diagnose_report(input_data, output_format = "html")
diagnose_report(input_data_excluded, output_format = "html")

eda_report(input_data, output_format = "html")

