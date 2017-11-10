## --------------------------------------------------------------------------
library(ngsReports)

## ---- eval = FALSE---------------------------------------------------------
#  fileDir <- system.file("extdata", package = "ngsReports")
#  writeHtmlReport(fileDir)

## ---- eval = FALSE---------------------------------------------------------
#  altTemplate <- file.path("path", "to", "template.Rmd")
#  writeHtmlReport(fileDir, template = altTemplate)

## ---- eval=FALSE-----------------------------------------------------------
#  files <- list.files(fileDir, pattern = "fastqc.zip$", full.names = TRUE)
#  fastqcShiny(files)

## --------------------------------------------------------------------------
fileDir <- system.file("extdata", package = "ngsReports")
files <- list.files(fileDir, pattern = "fastqc.zip$", full.names = TRUE)
fdl <- getFastqcData(files)

## ---- results='hide'-------------------------------------------------------
readTotals(fdl)

## ----plotSummary, fig.cap="Default summary of FastQC flags.", fig.wide = TRUE----
plotSummary(fdl)

## --------------------------------------------------------------------------
plotReadTotals(fdl)

## --------------------------------------------------------------------------
library(ggplot2)
plotReadTotals(fdl, duplicated = FALSE, barCol = "grey50") + 
  geom_hline(yintercept = 25000, linetype = 2) +
  coord_flip() 

## ----sessionInfo, echo=FALSE-----------------------------------------------
sessionInfo()
