#!/SYSTEM/R/3.3.2/bin/Rscript

# Library -----------------------------------------------------------------

localLibPath <- "./lib"
.libPaths(localLibPath)
mylib <- c("NonCompart", "dplyr", "ggplot2", "dplyr", "markdown", "knitr", "tibble")
lapply(mylib, library, character.only = TRUE) # if needed # install.packages(mylib, lib = localLibPath)

# Argument ----------------------------------------------------------------

Args <- commandArgs(trailingOnly = TRUE) # SKIP THIS LINE IN R if you're testing!
if (identical(Args, character(0))) Args <- c("-inp", "input.deck")

# Data Input --------------------------------------------------------------

Input <- data.frame(t(read.table(InputParameter, row.names = 1, stringsAsFactors = FALSE)), stringsAsFactors = FALSE)
Input$Dose <- as.numeric(Input$Dose)

if (Input$Data == "Theoph") {
    Data <- Theoph
    colSubj <- "Subject"
    colTime <- "Time"
    colConc <- "conc"
} else {
    Data <- Indometh
    colSubj <- "Subject"
    colTime <- "time"
    colConc <- "conc"
}

if (length(intersect(dir(), "result")) == 0) {
    system("mkdir result")
}


IDs <- unique(Data[,colSubj])
nID <- length(IDs)

Output <- vector()
Output[1] <- paste("#NumField:",nID)
Output[2] <- paste("#LabelX: Time(h), LabelY: Conc(mg/L)")

cLineNo = 3

for (i in 1:nID) {
    cID = IDs[i]
    cDAT = Data[Data[,colSubj]==cID,]
    nRec = dim(cDAT)[1]
    Output[cLineNo] = paste0("#Field", cID, ": data, NumPoint:", nRec)
    cLineNo = cLineNo + 1
    for (j in 1:nRec) {
        Output[cLineNo] = paste(sprintf("%10.3f", cDAT[j, colTime]), sprintf("%10.3f",cDAT[j,colConc]))
        cLineNo = cLineNo + 1
    }
}

# Output ------------------------------------------------------------------

write.csv(Data, "result/out.csv", quote=FALSE, row.names=FALSE)
writeLines(Output, paste0("result/result.oneD"))
writeLines(NCA(Data, colSubj, colTime, colConc, Method = Input$Log, AdmMode = Input$AdmMode, 
               Dose=Input$Dose, Report="Text"), "result/CoreOutput.txt")
