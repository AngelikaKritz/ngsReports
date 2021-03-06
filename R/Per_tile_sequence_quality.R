#' @title Get the Per Tile Sequence Quality information
#'
#' @description Retrieve the Per Tile Sequence Quality module from one or more
#' FastQC reports
#'
#' @param object Can be a \code{FastqcFile}, \code{FastqcFileList},
#' \code{FastqcData}, \code{fastqcDataList}, or simply a \code{character}
#' vector of paths to fastqc files
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
#' # Print the Per_tile_sequence_quality
#' Per_tile_sequence_quality(fdl)
#'
#' @docType methods
#'
#'
#' @export
#' @rdname Per_tile_sequence_quality
#' @aliases Per_tile_sequence_quality
setMethod("Per_tile_sequence_quality", "FastqcData", function(object){
    df <- object@Per_tile_sequence_quality
    if (length(df)) {# Check there is data in the module
        ## Add a Filename column if there is any data
        df$Filename <- fileName(object)
        dplyr::select(df, "Filename", tidyselect::everything())
    }

    df

})

#' @export
#' @rdname Per_tile_sequence_quality
#' @aliases Per_tile_sequence_quality
setMethod("Per_tile_sequence_quality", "FastqcDataList", function(object){
    df <- lapply(object@.Data, Per_tile_sequence_quality)
    nulls <- vapply(df, function(x){length(x) == 0}, logical(1))
    if (sum(nulls) > 0) message(
        sprintf(
            "Per_tile_sequence_quality module missing from %s\n",
            paste(path(object)[nulls], sep = "\n")
        )
    )
    dplyr::bind_rows(df)
})

#' @export
#' @rdname Per_tile_sequence_quality
#' @aliases Per_tile_sequence_quality
setMethod("Per_tile_sequence_quality", "FastqcFile", function(object){
    object <- getFastqcData(object)
    Per_tile_sequence_quality(object)
})

#' @export
#' @rdname Per_tile_sequence_quality
#' @aliases Per_tile_sequence_quality
setMethod("Per_tile_sequence_quality", "FastqcFileList", function(object){
    object <- getFastqcData(object)
    Per_tile_sequence_quality(object)
})

#' @export
#' @rdname Per_tile_sequence_quality
#' @aliases Per_tile_sequence_quality
setMethod("Per_tile_sequence_quality", "character", function(object){
    object <- getFastqcData(object)
    Per_tile_sequence_quality(object)
})
