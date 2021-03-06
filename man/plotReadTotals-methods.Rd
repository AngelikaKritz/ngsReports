% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotReadTotals.R
\docType{methods}
\name{plotReadTotals}
\alias{plotReadTotals}
\alias{plotReadTotals,character-method}
\alias{plotReadTotals,character}
\alias{plotReadTotals,FastqcFileList-method}
\alias{plotReadTotals,FastqcFileList}
\alias{plotReadTotals,FastqcDataList-method}
\alias{plotReadTotals,FastqcDataList}
\title{Draw a barplot of read totals}
\usage{
plotReadTotals(x, usePlotly = FALSE, labels, duplicated = TRUE,
  bars = c("stacked", "adjacent"), barCols = c("red", "blue"),
  expand.x = c(0, 0.02), ...)

\S4method{plotReadTotals}{character}(x, usePlotly = FALSE, labels,
  duplicated = TRUE, bars = c("stacked", "adjacent"),
  barCols = c("red", "blue"), expand.x = c(0, 0.02), ...)

\S4method{plotReadTotals}{FastqcFileList}(x, usePlotly = FALSE, labels,
  duplicated = TRUE, bars = c("stacked", "adjacent"),
  barCols = c("red", "blue"), expand.x = c(0, 0.02), ...)

\S4method{plotReadTotals}{FastqcDataList}(x, usePlotly = FALSE, labels,
  duplicated = TRUE, bars = c("stacked", "adjacent"),
  barCols = c("red", "blue"), expand.x = c(0, 0.02), ...)
}
\arguments{
\item{x}{Can be a \code{FastqcFile}, \code{FastqcFileList},
\code{FastqcData}, \code{FastqcDataList} or path}

\item{usePlotly}{\code{logical} Default \code{FALSE} will render using
ggplot. If \code{TRUE} plot will be rendered with plotly}

\item{labels}{An optional named vector of labels for the file names.
All filenames must be present in the names.
File extensions are dropped by default.}

\item{duplicated}{\code{logical}. Include deduplicated read total estimates
to plot charts}

\item{bars}{If \code{duplicated = TRUE}, show unique and deduplicated reads
as "stacked" or "adjacent".}

\item{barCols}{Colours for duplicated and unique reads.}

\item{expand.x}{Passed to \code{expand_scale(mult = expand.x)} for the
x-axis.}

\item{...}{Used to pass additional attributes to theme()}
}
\value{
Returns a ggplot or plotly object
}
\description{
Draw a barplot of read totals
}
\details{
Draw a barplot of read totals using the standard ggplot2 syntax.
Read totals will be plotted in millions as this is the most common.
The raw data from \code{\link{readTotals}} can otherwise be used to manually
create a plot.

However, this is based on the value shown on FASTQC reports at the top of
DeDuplicatedTotals plot, and is known to be inaccurate.
As it still gives a good guide as to sequence diversity it is included as the
default.
}
\examples{

# Get the files included with the package
packageDir <- system.file("extdata", package = "ngsReports")
fileList <- list.files(packageDir, pattern = "fastqc.zip", full.names = TRUE)

# Load the FASTQC data as a FastqcDataList object
fdl <- getFastqcData(fileList)

# Plot the Read Totals showing estimated duplicates
plotReadTotals(fdl)

# Plot the Read Totals without estimated duplicates
plotReadTotals(fdl, duplicated = FALSE)

}
