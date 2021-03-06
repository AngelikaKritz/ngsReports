% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/importHisat2Logs.R
\name{importHisat2Logs}
\alias{importHisat2Logs}
\alias{importBowtie2Logs}
\title{Read Hisat2/Bowtie2 Log Files}
\usage{
importHisat2Logs(x, useBasename = TRUE)

importBowtie2Logs(x, useBasename = TRUE)
}
\arguments{
\item{x}{\code{character}. Vector of paths to log files}

\item{useBasename}{\code{logical}. Strip file paths from the Filename column
in the returned tibble?}
}
\value{
A \code{tibble}
}
\description{
Import one or more hisat2/bowtie2 log files as a data frame.
}
\examples{
# NB bowtie2 & hista2 logs are the identical format
fl <- c("bowtie2PE.txt", "bowtie2SE.txt")
bowtie2Logs <- system.file("extdata", fl, package = "ngsReports")
df <- importBowtie2Logs(bowtie2Logs)

}
