#' @title Get the Per Sequence Quality Scores information
#'
#' @description Retrieve the Per Sequence Quality Scores module from one or more
#' FastQC reports
#'
#' @param object Can be a \code{FastqcFile}, \code{FastqcFileList},
#' \code{FastqcData}, \code{fastqcDataList}, or simply a \code{character} vector
#' of paths to fastqc files
#'
#' @include FastqcData.R
#' @include AllGenerics.R
#'
#' @return A single \code{tibble} containing all information combined from all
#' supplied FastQC reports
#'
#' @examples
#'
#' # Get the files included with the package
#' packageDir <- system.file("extdata", package = "ngsReports")
#' fileList <- list.files(packageDir, pattern = "fastqc.zip", full.names = TRUE)
#'
#' # Load the FASTQC data as a FastqcDataList object
#' fdl <- getFastqcData(fileList)
#'
#' # Print the Per_sequence_quality_scores
#' Per_sequence_quality_scores(fdl)
#'
#' @docType methods
#'
#' @export
#' @rdname Per_sequence_quality_scores
#' @aliases Per_sequence_quality_scores
setMethod("Per_sequence_quality_scores", "FastqcData", function(object){
    df <- object@Per_sequence_quality_scores
    if (length(df)) { # Check there is data in the module
        ## Add a Filename column if there is any data
        df$Filename <- fileName(object)
        dplyr::select(df, "Filename", tidyselect::everything())
    }

    df

})

#' @export
#' @rdname Per_sequence_quality_scores
#' @aliases Per_sequence_quality_scores
setMethod("Per_sequence_quality_scores", "FastqcDataList", function(object){
    df <- lapply(object@.Data, Per_sequence_quality_scores)
    nulls <- vapply(df, function(x){length(x) == 0}, logical(1))
    if (sum(nulls) > 0) message(
        sprintf(
            "Per_sequence_quality_scores module missing from %s\n",
            paste(path(object)[nulls], sep = "\n")
        )
    )
    dplyr::bind_rows(df)
})

#' @export
#' @rdname Per_sequence_quality_scores
#' @aliases Per_sequence_quality_scores
setMethod("Per_sequence_quality_scores", "FastqcFile", function(object){
    object <- getFastqcData(object)
    Per_sequence_quality_scores(object)
})

#' @export
#' @rdname Per_sequence_quality_scores
#' @aliases Per_sequence_quality_scores
setMethod("Per_sequence_quality_scores", "FastqcFileList", function(object){
    object <- getFastqcData(object)
    Per_sequence_quality_scores(object)
})

#' @export
#' @rdname Per_sequence_quality_scores
#' @aliases Per_sequence_quality_scores
setMethod("Per_sequence_quality_scores", "character", function(object){
    object <- getFastqcData(object)
    Per_sequence_quality_scores(object)
})
