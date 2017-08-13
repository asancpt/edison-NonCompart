localLibPath <- "./lib/"
.libPaths(localLibPath)
mylib <- c("NonCompart", "dplyr", "ggplot2", "dplyr", "markdown", "knitr", "tibble")
install.packages(mylib, lib = localLibPath)

