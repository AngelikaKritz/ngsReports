#' @title Plot a summary of Over-represented Sequences
#'
#' @description Plot a summary of Over-represented Sequences for a set of
#' FASTQC reports
#'
#' @details Percentages are obtained by simply summing those within a report.
#' Any possible double counting by FastQC is ignored for the purposes of a
#' simple approximation.
#'
#' @param x Can be a \code{FastqcFile}, \code{FastqcFileList},
#' \code{FastqcData}, \code{FastqcDataList} or file path
#' @param usePlotly \code{logical} Default \code{FALSE} will render using
#' ggplot. If \code{TRUE} plot will be rendered with plotly
#' @param labels An optional named factor of labels for the file names.
#' All filenames must be present in the names.
#' File extensions are dropped by default.
#' @param n The number of sequences to plot from an individual file
#' @param pwfCols Object of class \code{\link{PwfCols}} containing the colours
#' for PASS/WARN/FAIL
#' @param cluster \code{logical} default \code{FALSE}. If set to \code{TRUE},
#' fastqc data will be clustered using hierarchical clustering
#' @param dendrogram \code{logical} redundant if \code{cluster} is \code{FALSE}
#' if both \code{cluster} and \code{dendrogram} are specified as \code{TRUE}
#' then the dendrogram will be displayed.
#' @param ... Used to pass additional attributes to theme() and between methods
#' @param expand.x,expand.y Vectors of length 2. Passed to
#' \code{scale_*_continuous()}
#' @param paletteName Name of the palette for colouring the possible sources
#' of the overrepresented sequences. Must be a palette name from
#' \code{RColorBrewer}
#'
#' @return A standard ggplot2 object
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
#' # Another example which isn't ideal
#' plotOverrepresentedSummary(fdl)
#'
#' @importFrom tidyr spread
#' @importFrom plotly layout
#' @importFrom grDevices rgb
#' @import ggplot2
#'
#'
#' @name plotOverrepresentedSummary
#' @rdname plotOverrepresentedSummary-methods
#' @export
setGeneric("plotOverrepresentedSummary", function(
    x, usePlotly = FALSE, labels, pwfCols, ...){
    standardGeneric("plotOverrepresentedSummary")
}
)
#' @aliases plotOverrepresentedSummary,character
#' @rdname plotOverrepresentedSummary-methods
#' @export
setMethod("plotOverrepresentedSummary", signature = "character", function(
    x, usePlotly = FALSE, labels, pwfCols, ...){
    x <- getFastqcData(x)
    plotOverrepresentedSummary(x, usePlotly, labels, pwfCols, ...)
}
)
#' @aliases plotOverrepresentedSummary,FastqcFile
#' @rdname plotOverrepresentedSummary-methods
#' @export
setMethod("plotOverrepresentedSummary", signature = "FastqcFile", function(
    x, usePlotly = FALSE, labels, pwfCols, ...){
    x <- getFastqcData(x)
    plotOverrepresentedSummary(x, usePlotly, labels, pwfCols, ...)
}
)
#' @aliases plotOverrepresentedSummary,FastqcFileList
#' @rdname plotOverrepresentedSummary-methods
#' @export
setMethod("plotOverrepresentedSummary", signature = "FastqcFileList", function(
    x, usePlotly = FALSE, labels, pwfCols, ...){
    x <- getFastqcData(x)
    plotOverrepresentedSummary(x, usePlotly, labels, pwfCols, ...)
}
)
#' @aliases plotOverrepresentedSummary,FastqcData
#' @rdname plotOverrepresentedSummary-methods
#' @export
setMethod("plotOverrepresentedSummary", signature = "FastqcData", function(
    x, usePlotly = FALSE, labels, pwfCols,  n = 10, ...){

    df <- Overrepresented_sequences(x)

    if (!length(df)) {
        overPlot <- .emptyPlot("No Overrepresented Sequences")
        if (usePlotly) overPlot <- ggplotly(overPlot, tooltip = "")
        return(overPlot)
    }

    ## Drop the suffix, or check the alternate labels
    labels <- .makeLabels(df, labels, ...)
    df$Filename <- labels[df$Filename]

    ## Get any arguments for dotArgs that have been set manually
    dotArgs <- list(...)
    allowed <- names(formals(ggplot2::theme))
    keepArgs <- which(names(dotArgs) %in% allowed)
    userTheme <- c()
    if (length(keepArgs) > 0) userTheme <- do.call(theme, dotArgs[keepArgs])

    df <- dplyr::top_n(df, n, Percentage)
    df$Status <- cut(
        df$Percentage,
        breaks = c(0, 0.1, 1, 100),
        labels = c("PASS", "WARN", "FAIL")
    )
    df$Possible_Source <-
        gsub(" \\([0-9]*\\% over [0-9]*bp\\)",  "", df$Possible_Source)
    df$Sequence <- factor(df$Sequence, levels = rev(df$Sequence))
    df$Percentage <- round(df$Percentage, 2)
    df <- droplevels(df)

    ## Set plotting parameters
    ymax <- 1.05*max(df$Percentage)
    xLab <- "Percent of Total Reads (%)"
    yLab <- "Overrepresented Sequence"

    ## Sort out the colours & pass/warn/fail breaks
    if (missing(pwfCols)) pwfCols <- getColours(ngsReports::pwf)
    pwfCols <- pwfCols[names(pwfCols) %in% levels(df$Status)]

    overPlot <- ggplot(
        df,
        aes_string(
            "Sequence", "Percentage",
            fill = "Status", label = "Possible_Source"
        )
    ) +
        geom_bar(stat = "identity") +
        labs(y = xLab, x = yLab) +
        scale_y_continuous(
            limits = c(0, ymax), expand = c(0,0), labels = .addPercent
        ) +
        theme_bw() +
        coord_flip() +
        scale_fill_manual(values = pwfCols)

    ## Only facet is using ggplot. They look bad under plotly
    if (!usePlotly) overPlot <- overPlot +
        facet_grid(Possible_Source~., scales = "free_y", space = "free")

    ## Add the basic customisations
    if (!is.null(userTheme)) overPlot <- overPlot + userTheme

    if (usePlotly) {

        ## Add the customisations for plotly
        overPlot <- overPlot +
            ggtitle(df$Filename[1]) +
            theme(
                axis.ticks.y = element_blank(),
                axis.text.y = element_blank(),
                plot.title = element_text(hjust = 0.5),
                legend.position = "none"
            )

        ## Add the empty plot to align in the shiny app
        overPlot <- suppressMessages(
            suppressWarnings(
                plotly::subplot(
                    plotly::plotly_empty(),
                    overPlot,
                    widths = c(0.14,0.86)
                )
            )
        )
    }

    overPlot

}
)
#' @aliases plotOverrepresentedSummary,FastqcDataList
#' @rdname plotOverrepresentedSummary-methods
#' @export
setMethod("plotOverrepresentedSummary", signature = "FastqcDataList", function(
    x, usePlotly = FALSE, labels, pwfCols, cluster = TRUE, dendrogram = TRUE,
    ..., paletteName = "Set1", expand.x = c(0, 0), expand.y = c(0, 0)){

    df <- Overrepresented_sequences(x)

    if (!length(df)) {
        overPlot <- .emptyPlot("No Overrepresented Sequences")
        if (usePlotly) overPlot <- ggplotly(overPlot, tooltip = "")
        return(overPlot)
    }

    if (missing(pwfCols)) pwfCols <- ngsReports::pwf

    ## Drop the suffix, or check the alternate labels
    labels <- .makeLabels(df, labels, ...)

    ## Get any arguments for dotArgs that have been set manually
    dotArgs <- list(...)
    allowed <- names(formals(ggplot2::theme))
    keepArgs <- which(names(dotArgs) %in% allowed)
    userTheme <- c()
    if (length(keepArgs) > 0) userTheme <- do.call(theme, dotArgs[keepArgs])

    Possible_Source <- c() # Here to avoid a NOTE in R CMD check...
    df$Possible_Source <-
        gsub(" \\([0-9]*\\% over [0-9]*bp\\)", "", df$Possible_Source)
    df <- dplyr::group_by(df, Filename, Possible_Source)
    df <- dplyr::summarise(df, Percentage = sum(Percentage))
    df <- dplyr::ungroup(df)
    df$Percentage <- round(df$Percentage, 2)
    lev <- unique(dplyr::arrange(df, Percentage)$Possible_Source)
    df$Possible_Source <- factor(df$Possible_Source, levels = lev)

    if (dendrogram && !cluster) {
        message("cluster will be set to TRUE when dendrogram = TRUE")
        cluster <- TRUE
    }

    ## Now define the order for a dendrogram if required
    key <- names(labels)
    if (cluster) {
        cols <- c("Filename", "Possible_Source", "Percentage")
        clusterDend <-  .makeDendrogram(
            df[cols], "Filename", "Possible_Source", "Percentage")
        key <- labels(clusterDend)
    }
    ## Now set everything as factors
    df$Filename <- factor(labels[df$Filename], levels = labels[key])
    maxChar <- max(nchar(levels(df$Filename)))

    ## Check the axis expansion
    stopifnot(is.numeric(expand.x), is.numeric(expand.y))
    stopifnot(length(expand.x) == 2, length(expand.y) == 2)
    ## Set the axis limits. Just scale the upper limit by 1.05
    ymax <- 1.05*max(
        dplyr::summarise(
            dplyr::group_by(df, Filename),
            Total = sum(Percentage)
        )$Total
    )

    ## Define the palette
    paletteName <-
        match.arg(paletteName, rownames(RColorBrewer::brewer.pal.info))
    nMax <- RColorBrewer::brewer.pal.info[paletteName, "maxcolors"]
    nSource <- length(levels(df$Possible_Source))
    pal <- RColorBrewer::brewer.pal(nMax, paletteName)
    if (nSource > nMax) {
        pal <- colorRampPalette(pal)(nSource)
    }
    else {
        pal <- pal[seq_len(nSource)]
    }
    names(pal) <- levels(df$Possible_Source)

    ## Set the axis label
    xLab <- "Overrepresented Sequences (% of Total)"

    overPlot <- ggplot(
        df,
        aes_string("Filename", "Percentage", fill = "Possible_Source")
    ) +
        geom_bar(stat = "identity") +
        labs(y = xLab, fill = "Possible Source") +
        scale_y_continuous(
            limits = c(0, ymax),
            expand = expand.x,
            labels = .addPercent
        ) +
        scale_x_discrete(expand = expand.y) +
        scale_fill_manual(values = pal) +
        theme_bw() +
        coord_flip()

    ## Add the basic customisations
    if (!is.null(userTheme)) overPlot <- overPlot + userTheme

    if (usePlotly) {

        # Remove annotations before sending to plotly
        overPlot <- overPlot +
            theme(
                legend.position = "none",
                axis.text.y = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks.y = element_blank()
            )
        # Prepare the sidebar
        status <- getSummary(x)
        status <- subset(status, Category == "Overrepresented sequences")
        status$Filename <- labels[status$Filename]
        status$Filename <-
            factor(status$Filename, levels = levels(df$Filename))
        status <- dplyr::right_join(
            status,
            dplyr::distinct(df, Filename),
            by = "Filename"
        )
        sideBar <- .makeSidebar(status, key, pwfCols)

        # Prepare the dendrogram
        dendro <- plotly::plotly_empty()
        if (dendrogram) {
            dx <- ggdendro::dendro_data(clusterDend)
            dendro <- .renderDendro(dx$segments)
        }

        # The final interactive plot
        overPlot <- suppressWarnings(
            suppressMessages(
                plotly::subplot(
                    dendro,
                    sideBar,
                    overPlot,
                    margin = 0.001,
                    widths = c(0.08,0.08,0.84)
                )
            )
        )
    }
    overPlot
}
)
