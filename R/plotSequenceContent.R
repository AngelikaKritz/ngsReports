#' @title Plot the per base content as a heatmap
#'
#' @description Plot the Per Base content for a set of FASTQC files.
#' Informative plot where per base sequence content (%A, %T, %G, %C),
#'
#' @param x Can be a \code{FastqcFile}, \code{FastqcFileList},
#' \code{FastqcData}, \code{FastqcDataList} or file path
#' @param labels An optional named vector of labels for the file names.
#' All filenames must be present in the names.
#' File extensions are dropped by default.
#' @param usePlotly \code{logical}. Generate an interactive plot using plotly
#' @param plotType \code{character}. Type of plot to generate. Must be "line" or
#' "heatmap"
#' @param pwfCols Object of class \code{\link{PwfCols}} to give colours for
#' pass, warning, and fail
#' values in plot
#' @param cluster \code{logical} default \code{FALSE}. If set to \code{TRUE},
#' fastqc data will be clustered using hierarchical clustering
#' @param dendrogram \code{logical} redundant if \code{cluster} is \code{FALSE}
#' if both \code{cluster} and \code{dendrogram} are specified as \code{TRUE}
#' then the dendrogram will be displayed.
#' @param ... Used to pass additional attributes to theme() and between methods
#' @param nc Specify the number of columns if plotting a FastqcDataList as line
#' plots
#'
#' @return A ggplot2 object
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
#' # The default plot
#' plotSequenceContent(fdl)
#'
#'
#' @importFrom grDevices rgb
#' @importFrom dplyr mutate_at vars funs
#' @importFrom tidyselect one_of
#' @import ggplot2
#'
#' @name plotSequenceContent
#' @rdname plotSequenceContent-methods
#' @export
setGeneric("plotSequenceContent", function(x, usePlotly = FALSE, labels, ...){
    standardGeneric("plotSequenceContent")
}
)
#' @aliases plotSequenceContent,character
#' @rdname plotSequenceContent-methods
#' @export
setMethod("plotSequenceContent", signature = "character", function(
    x, usePlotly = FALSE, labels, ...){
    x <- getFastqcData(x)
    plotSequenceContent(x, usePlotly, labels, ...)
}
)
#' @aliases plotSequenceContent,FastqcFile
#' @rdname plotSequenceContent-methods
#' @export
setMethod("plotSequenceContent", signature = "FastqcFile", function(
    x, usePlotly = FALSE, labels, ...){
    x <- getFastqcData(x)
    plotSequenceContent(x, usePlotly, labels, ...)
}
)
#' @aliases plotSequenceContent,FastqcFileList
#' @rdname plotSequenceContent-methods
#' @export
setMethod("plotSequenceContent", signature = "FastqcFileList", function(
    x, usePlotly = FALSE, labels, ...){
    x <- getFastqcData(x)
    plotSequenceContent(x, usePlotly, labels, ...)
}
)
#' @aliases plotSequenceContent,FastqcData
#' @rdname plotSequenceContent-methods
#' @export
setMethod("plotSequenceContent", signature = "FastqcData", function(
    x, usePlotly = FALSE, labels, ...){

    ## Get the SequenceContent
    df <- Per_base_sequence_content(x)
    names(df)[names(df) == "Base"] <- "Position"

    if (!length(df)) {
        scPlot <- .emptyPlot("No Sequence Content Module Detected")
        if (usePlotly) scPlot <- ggplotly(scPlot, tooltip = "")
        return(scPlot)
    }

    df$Position <- factor(df$Position, levels = unique(df$Position))

    ## Drop the suffix, or check the alternate labels
    labels <- .makeLabels(df, labels, ...)
    acgt <- c("T", "C", "A", "G")

    df$Filename <- labels[df$Filename]
    df <- tidyr::gather(df, "Base", "Percent", tidyselect::one_of(acgt))
    df$Base <- factor(df$Base, levels = acgt)
    df$Percent <- round(df$Percent, 2)
    df$x <- as.integer(df$Position)

    ##set colours
    baseCols <- c(`T` = "red", G = "black", A = "green", C = "blue")

    ## Get any arguments for dotArgs that have been set manually
    dotArgs <- list(...)
    allowed <- names(formals(ggplot2::theme))
    keepArgs <- which(names(dotArgs) %in% allowed)
    userTheme <- c()
    if (length(keepArgs) > 0) userTheme <- do.call(theme, dotArgs[keepArgs])

    xLab <- "Position in read (bp)"
    yLab <- "Percent"
    scPlot <- ggplot(
        df, aes_string("x", "Percent", label = "Position", colour = "Base")
    ) +
        geom_line() +
        facet_wrap(~Filename) +
        scale_y_continuous(
            limits = c(0, 100), expand = c(0, 0), labels = .addPercent
        ) +
        scale_x_continuous(
            expand = c(0, 0),
            breaks = seq_along(levels(df$Position)),
            labels = levels(df$Position)
        ) +
        scale_colour_manual(values = baseCols) +
        guides(fill = FALSE) +
        labs(x = xLab, y = yLab) +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

    if (usePlotly) {

        ttip <- c("y", "label", "colour")
        scPlot <- plotly::ggplotly(scPlot, tooltip = ttip)
        scPlot <- suppressMessages(
            suppressWarnings(
                plotly::subplot(
                    plotly::plotly_empty(),
                    scPlot,
                    widths = c(0.14,0.86))
            )
        )

        scPlot <- plotly::layout(
            scPlot, xaxis2 = list(title = xLab), yaxis2 = list(title = yLab)
        )
    }

    scPlot

}
)
#' @aliases plotSequenceContent,FastqcDataList
#' @rdname plotSequenceContent-methods
#' @export
setMethod("plotSequenceContent", signature = "FastqcDataList", function(
    x, usePlotly = FALSE, labels, pwfCols, plotType = c("heatmap", "line"),
    cluster = TRUE, dendrogram = TRUE, ..., nc = 2){

    ## Get the SequenceContent
    df <- Per_base_sequence_content(x)

    if (!length(df)) {
        scPlot <- .emptyPlot("No Sequence Content Module Detected")
        if (usePlotly) scPlot <- ggplotly(scPlot, tooltip = "")
        return(scPlot)
    }

    df$Start <- gsub("([0-9]*)-[0-9]*", "\\1", df$Base)
    df$End <- gsub("[0-9]*-([0-9]*)", "\\1", df$Base)
    df$Start <- as.integer(df$Start)
    df$End <- as.integer(df$End)

    plotType <- match.arg(plotType)
    if (missing(pwfCols)) pwfCols <- ngsReports::pwf

    ## Drop the suffix, or check the alternate labels
    labels <- .makeLabels(df, labels, ...)

    ## Get any arguments for dotArgs that have been set manually
    dotArgs <- list(...)
    allowed <- names(formals(ggplot2::theme))
    keepArgs <- which(names(dotArgs) %in% allowed)
    userTheme <- c()
    if (length(keepArgs) > 0) userTheme <- do.call(theme, dotArgs[keepArgs])

    ## Define the bases as a vector for ease later in the function
    acgt <- c("T", "C", "A", "G")
    ## Axis labels
    xLab <- "Position in read (bp)"
    yLab <- ifelse(plotType == "heatmap", "Filename", "Percent (%)")

    if (plotType == "heatmap") {

        ## Round to 2 digits to reduce the complexity of the colour
        ## palette
        df <- dplyr::mutate_at(
            df, vars(one_of(acgt)), funs(round), digits = 2
        )
        maxBase <- max(vapply(acgt, function(x){max(df[[x]])}, numeric(1)))
        ## Set the colours, using opacity for G
        df$opacity <- 1 - df$G / maxBase
        df$colour <- with(df, rgb(
            red = `T` * opacity / maxBase,
            green = A * opacity / maxBase,
            blue = C * opacity / maxBase)
        )

        basicStat <- Basic_Statistics(x)
        basicStat <- basicStat[c("Filename", "Longest_sequence")]
        df <- dplyr::right_join(df, basicStat, by = "Filename")
        cols <- c("Filename", "Start", "End", "colour", "Longest_sequence")
        df <- df[c(cols, acgt)]

        if (dendrogram && !cluster) {
            message( "cluster will be set to TRUE when dendrogram = TRUE")
            cluster <- TRUE
        }

        ## Now define the order for a dendrogram if required
        key <- names(labels)
        if (cluster) {
            df_gath <- tidyr::gather(
                df, "Base", "Percent", tidyselect::one_of(acgt)
            )
            df_gath$Start <- paste(df_gath$Start, df_gath$Base, sep = "_")
            df_gath <- df_gath[c("Filename", "Start", "Percent")]
            clusterDend <-
                .makeDendrogram(df_gath, "Filename", "Start", "Percent")
            key <- labels(clusterDend)
        }
        ## Now set everything as factors
        df$Filename <- factor(labels[df$Filename], levels = labels[key])
        ## Define the colours as named colours (name = colour)
        tileCols <- unique(df$colour)
        names(tileCols) <- unique(df$colour)
        ## Define the tile locations
        df$y <- as.integer(df$Filename)
        df$ymax <- as.integer(df$Filename) + 0.5
        df$ymin <- df$ymax - 1
        df$xmax <- df$End + 0.5
        df$xmin <- df$Start - 1
        df$Position <- ifelse(
            df$Start == df$End,
            paste0(df$Start, "bp"),
            paste0(df$Start, "-", df$End, "bp")
        )
        ## Add percentage signs to ACGT for prettier labels
        df <- dplyr::mutate_at(df, vars(acgt), funs(.addPercent))

        yBreaks <- seq_along(levels(df$Filename))
        scPlot <- ggplot(
            df,
            aes_string(
                fill = "colour",
                A = "A", C = "C", G = "G", `T` = "T",
                Filename = "Filename",
                Position = "Position")) +
            geom_rect(
                aes_string(
                    xmin = "xmin", xmax = "xmax",
                    ymin = "ymin", ymax = "ymax"
                ),
                linetype = 0) +
            scale_fill_manual(values = tileCols) +
            scale_x_continuous(expand = c(0, 0)) +
            scale_y_continuous(
                expand = c(0, 0),
                breaks = yBreaks,
                labels = levels(df$Filename)
            ) +
            theme_bw() +
            theme(legend.position = "none", panel.grid = element_blank()) +
            labs(x = xLab, y = yLab)

        if (!is.null(userTheme)) scPlot <- scPlot + userTheme

        if (usePlotly) {
            scPlot <- scPlot +
                theme(
                    axis.ticks.y = element_blank(),
                    axis.text.y = element_blank(),
                    axis.title.y = element_blank()
                )

            status <- getSummary(x)
            status <- subset(status, Category == "Per base sequence content")
            status$Filename <- labels[status$Filename]
            status$Filename <-
                factor(status$Filename, levels = levels(df$Filename))
            sideBar <- .makeSidebar(status, key, pwfCols)

            dendro <- plotly::plotly_empty()
            if (dendrogram) {
                dx <- ggdendro::dendro_data(clusterDend)
                dendro <- .renderDendro(dx$segments)
            }

            ## Render using ggplotly to enable easier tooltip
            ## specification
            scPlot <- plotly::ggplotly(
                scPlot, tooltip = c(acgt, "Filename", "Position")
            )
            ## Now make the complete layout
            scPlot <- suppressWarnings(
                suppressMessages(
                    plotly::subplot(
                        dendro, sideBar, scPlot,
                        widths = c(0.1,0.08,0.82),
                        margin = 0.001, shareY = TRUE)
                )
            )

        }
    }
    if (plotType == "line") {
        df$Filename <- labels[df$Filename]
        df <- df[!colnames(df) == "Base"]
        df <- tidyr::gather(df, "Base", "Percent", tidyselect::one_of(acgt))
        df$Base <- factor(df$Base, levels = acgt)
        df$Percent <- round(df$Percent, 2)
        df$Position <- ifelse(
            df$Start == df$End,
            as.character(df$Start),
            paste0(df$Start, "-", df$End)
        )
        posLevels <- stringr::str_sort(unique(df$Position), numeric = TRUE)
        df$Position <- factor(df$Position, levels = posLevels)
        df$x <- as.integer(df$Position)

        ##set colours
        baseCols <- c(`T` = "red", G = "black", A = "green", C = "blue")

        xBreaks <- seq_along(levels(df$Position))
        scPlot <- ggplot(
            df,
            aes_string("x", "Percent", colour = "Base", label = "Position")
        ) +
            geom_line() +
            facet_wrap(~Filename, ncol = nc) +
            scale_y_continuous(
                limits = c(0, 100), expand = c(0, 0), labels = .addPercent
            ) +
            scale_x_continuous(
                expand = c(0, 0),
                breaks = xBreaks,
                labels = levels(df$Position)
            ) +
            scale_colour_manual(values = baseCols) +
            labs(x = xLab, y = yLab) +
            theme_bw() +
            theme(
                axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
            )


        if (!is.null(userTheme)) scPlot <- scPlot + userTheme

        if (usePlotly) {
            ttip <- c("y", "colour", "label")
            scPlot <- suppressMessages(
                suppressWarnings(plotly::ggplotly(scPlot, tooltip = ttip))
            )
        }
    }

    scPlot
}
)
