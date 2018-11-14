#!/SYSTEM/R/3.5.1/bin/Rscript

#/SYSTEM/R/3.3.2/bin/Rscript

# Library -----------------------------------------------------------------

library(dplyr)
library(tidyr)
library(tibble)
library(readr)

localLibPath <- "./lib"
if (Sys.info()['sysname'] == 'Linux') { .libPaths(localLibPath) }

library(NonCompart)

if (length(intersect(dir(), "result")) == 0) {
  system("mkdir result")
}

# Argument ----------------------------------------------------------------

Args <- commandArgs(trailingOnly = TRUE) # SKIP THIS LINE IN R if you're testing!
if (identical(Args, character(0))) Args <- c("-inp", "data-raw/input.deck")
InputParameter <- Args[2]

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

#write.csv(Data, "result/out.csv", quote=FALSE, row.names=FALSE)
#writeLines(Output, paste0("result/result.oneD"))

write_csv(Data, "result/out.csv")
write_lines(Output, "result/result.oneD")

tabResult <- NonCompart::tblNCA(Data, 
                   colSubj, 
                   colTime, 
                   colConc, 
                   adm = Input$AdmMode, 
                   down = Input$Log, 
                   dose=Input$Dose)
tabUnit <- tibble(param = attributes(tabResult)[['names']], units = attributes(tabResult)[['units']])

tabResult %>% 
  as_tibble() %>% 
  gather(param, value, -1) %>% 
  left_join(tabUnit, by = 'param') %>% 
  write_csv('result/resultNonCompart.csv')
