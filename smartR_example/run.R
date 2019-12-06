remoteScriptDir <- "C:/Users/corny/Dropbox/Universitat/MA/tranSMART-dataquality/smartR_example"
## Loading functions ##
utils <- paste(remoteScriptDir, "/_shared_functions/Generic/utils.R", sep = "")
limmaUtils <- paste(remoteScriptDir, "/_shared_functions/GEX/limmaUtils.R", sep = "")
dataFrameUtils <- paste(remoteScriptDir, "/_shared_functions/GEX/DataFrameAndGEXmatrixUtils.R", sep = "")
heatmapUtils <- paste(remoteScriptDir, "/_shared_functions/Clustering/heatmapUtils.R", sep = "")

source(utils)
source(limmaUtils)
source(dataFrameUtils)
source(heatmapUtils)
#######################


SUBSET1REGEX <- "_s1$"  # Regex identifying columns of subset 1.

main <- function(max_rows = 100, sorting = "nodes", ranking = "coef", selections = list(), geneCardsAllowed = FALSE) {
    
    ## Returns a list containing two variables named HD and LD
    data.list <- parseInput()
    
    ## Splitting up input into low dim and high dim vars 
    hd.df = data.list$HD
    ld.list = data.list$LD    
    
    if (sorting == "nodes") {

    } else {
        colNames <- colnames(hd.df[, -c(1,2)])
        subjects <- as.numeric(sub("_.+", "", colNames))
        subsets <- as.numeric(substring(colNames, first=nchar(colNames), last=nchar(colNames)))
        ordering <- order(as.numeric(paste(subjects, subsets, sep="")))
        hd.df <- cbind(hd.df[, c(1,2)], hd.df[, -c(1,2)][, ordering])
    }
    
    write.table(
        hd.df,
        "heatmap_orig_values.tsv",
        sep = "\t",
        na = "",
        row.names = FALSE,
        col.names = TRUE
    )
    
    ## Creating the extended diff expr analysis data frame containing besides the input data,
    ## a set of statistics. The returned data frame is ranked according to provided ranking statistic
    hd.df          <- addStats(hd.df, ranking, max_rows)
    
    hd.df          <- mergeDuplicates(hd.df)
    
    ## Filtering down the hd.df to retain only the n top ranked rows
    hd.df          <- hd.df[1:min(max_rows, nrow(hd.df)), ]  
    
    if (!is.null(selections$selectedRownames) && length(selections$selectedRownames > 0)) {
        hd.df <- hd.df[!hd.df$ROWNAME %in% selections$selectedRownames, ]
    }
    
    ## High dimensional value data frame with unpivoted data structure
    ## Providing intensity values and zscore for given patient, sample id/colname,
    ## probe id/rowname and subset
    fields.df      <- buildFields(hd.df)
    

    
    ## High dimensional annotation data frame with unpivoted data structure
    ## providing the information on which sample/colnames belongs to which cohort
    extraFieldsHighDim.df <- buildExtraFieldsHighDim(fields.df)

    
    ## Low dimensional annotation data frame  
    extraFieldsLowDim.df = buildExtraFieldsLowDim(ld.list, extraFieldsHighDim.df$COLNAME)
    

    ldd_rownames.vector = as.vector(unique(extraFieldsLowDim.df[, "ROWNAME"]))
    ldd_rownames.vector = c("Cohort", ldd_rownames.vector)
    

    
    ## rowNames reflect here the unique identifiers of the GEX matrix this means "probeID--geneSymbol"
    rowNames        <- hd.df[, 1]
    
    ## colNames should reflect here only the sample names (e.g. "67_Breast_s1")
    colNames = colnames(hd.df)[grep("^\\d+_.+_s\\d$", colnames(hd.df), perl = TRUE)]

    significanceValues <- hd.df["SIGNIFICANCE"][,1]
    
    
    ## A df containing the computed values for
    ## all possible statistical methods
    statistics_hd.df = getAllStatForExtDataFrame(hd.df)

    write.table(statistics_hd.df,
                "heatmap_data.tsv",
                sep = "\t",
                na = "",
                row.names = FALSE,
                col.names = TRUE)
    ## Concatenating the two extraField types (that have been generated
    ## for the low and high dim data) 
    extraFields.df = rbind(extraFieldsHighDim.df, extraFieldsLowDim.df)
    
    
    ## The returned jsn object that will be dumped to file
    jsn <- list(
        "fields"              = fields.df,
        "patientIDs"          = getSubject(colNames),
        "colNames"            = colNames,
        "rowNames"            = rowNames,
        "ranking"             = ranking,
        "extraFields"         = extraFields.df,
        "features"            = ldd_rownames.vector,
        "maxRows"             = max_rows,
        "allStatValues"      = statistics_hd.df,
        "warnings"            = c() # initiate empty vector
    )
 

    
    ## Transforming the output list to json format
    jsn <- toJSON(jsn, pretty = TRUE, digits = I(17))
    
    
    write(jsn, file = "methheatmap.json")
    # json file be served the same way
    # like any other file would - get name via
    # /status call and then /download

    msgs <- c("Finished successfully")
    list(messages = msgs)
}




## SE: For debug purposes
#out = main(ranking = "median")



