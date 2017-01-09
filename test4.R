#!/SYSTEM/R/3.3.2/bin/Rscript

.libPaths("./lib/")

library(NonCompart)

# test3.r -inp[1] R_test_app_input[]
# test3.r -inp[1] Data[2] Theoph[3]
Args <- commandArgs(trailingOnly = TRUE)
InputParameter <- Args[2] 
if (length(Args) > 3){ 
    InputData=Args[4]
}

Input <- read.table(InputParameter)
DSN <- Input[1, 2] # Data Theoph // Data Indometh ??
if (DSN == "Theoph") {
  Data = Theoph
  colSubj = "Subject"
  colTime = "Time"
  colConc = "conc"
} else {
  Data = Indometh
  colSubj = "Subject"
  colTime = "time"
  colConc = "conc"
}

if (length(intersect(dir(), "result")) == 0) {
    system("mkdir result")
}

write.csv(Data, "result/out.csv", quote=FALSE, row.names=FALSE)

IDs <- unique(Data[,colSubj])
nID <- length(IDs)

Output = vector()
Output[1] = paste("#NumField:",nID)
Output[2] = paste("#LabelX: Time(h), LabelY: Conc(mg/L)")

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

writeLines(Output, paste0("result/result.oneD"))
writeLines(NCA(Data, colSubj, colTime, colConc, Dose=320, Report="Text"),
           "result/CoreOutput.txt")


