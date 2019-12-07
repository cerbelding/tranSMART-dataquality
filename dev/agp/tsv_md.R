# Vorher: Datensatz IMMER mit einem Editor angucken, oder mit "head" drüberschauen
setwd("C:/Users/corny/Dropbox/Universitat/MA/tranSMART-dataquality/agp")

#Laden der Daten
dat <- read.delim("clinical/subjects_data.tsv", na.strings="N/A")
#Anschauen der Daten
# View(dat)


# Die Spaltenindizes eines Dataframes kommen bei R vor den Zeilen,
# das Ergebnis ist ein Named Boolean
isnum <- sapply(dat, is.numeric)
iscat <- sapply(dat, is.numeric)
# Numerischer Teildatensatz
numdat <- dat[,isnum]
summary(numdat)

# Schnelle Übersicht: Zentriert auf Mittelwert und normiert auf Standardabwichung
boxplot(sapply(numdat, scale), main="Skalierte Daten",ylab="x-fache Abweichung von Standardabweichung")

# Schmutziger Trick: Immer eine Nonsens-Korrelation mit durchlaufen lassen
round(cor(numdat), 3)

#### Ab hier Ausreißer-Visualisierung über mehrere Variablen hinweg!!! -> Mahalanobis-Distanz

# Vorbereitung für ein multivariates Ausreißerkriterium namens "Mahalanobisdistanz"
# Interpretation als "Abstand" von der mehrdimensionalen Punktwolke
med <- sapply(numdat, median, na.rm=T)
sd <- cov(numdat)
# Etwas außerhalb der Spezifikation, wegen der Ausreißer in den Mittelwerten
md <- mahalanobis(center=med, cov=sd, numdat)

# Hier: Die "schlechtesten" (im Sinne der MD) 1% an numerischen Daten
# Aufpassen: freier Parameter! Ist definitiv Hindernis für eine Automatisierung!
(q<-quantile(md, 0.99))
numdat[which(md>=q),]
# Hier wären Wahrscheinlichkeiten für Ausreißer vermutlich verständlicher, 
# das löst aber das Problem der freien Parameter nicht
# Vgl. https://de.wikipedia.org/wiki/Ausrei%C3%9Fer

# Erst mal anschauen (Boxplot als einfachster Ausreißerdetektor?):
hst<-hist(lmd<-log(1+md), n=40)  # Streng monoton wachsende Transformation, bildet 0 auf 0 ab.
bxp<-boxplot(lmd, horizontal=T, add=T, col="red", pch=20, boxwex=max(hst$counts)/15)
str(bxp)
(trshld <- bxp$stats[5])
# Wie viele Daten betrifft das?
length(wc <- which(lmd > trshld))
# Welche genau sind es?
numdat[wc,]
