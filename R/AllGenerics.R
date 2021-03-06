## Set the main Generics
setGeneric(
    "getSummary",
    function(object){standardGeneric("getSummary")}
)

setGeneric(
    "Basic_Statistics",
    function(object){standardGeneric("Basic_Statistics")}
)

setGeneric(
    "Per_base_sequence_quality",
    function(object){standardGeneric("Per_base_sequence_quality")}
)

setGeneric(
    "Per_tile_sequence_quality",
    function(object){standardGeneric("Per_tile_sequence_quality")}
)

setGeneric(
    "Per_sequence_quality_scores",
    function(object){standardGeneric("Per_sequence_quality_scores")}
)

setGeneric(
    "Per_base_sequence_content",
    function(object){standardGeneric("Per_base_sequence_content")}
)

setGeneric(
    "Per_sequence_GC_content",
    function(object){standardGeneric("Per_sequence_GC_content")}
)

setGeneric(
    "Per_base_N_content",
    function(object){standardGeneric("Per_base_N_content")}
)

setGeneric(
    "Sequence_Length_Distribution",
    function(object){standardGeneric("Sequence_Length_Distribution")}
)

setGeneric(
    "Sequence_Duplication_Levels",
    function(object){standardGeneric("Sequence_Duplication_Levels")}
)

setGeneric(
    "Overrepresented_sequences",
    function(object){standardGeneric("Overrepresented_sequences")}
)

setGeneric(
    "Adapter_Content",
    function(object){standardGeneric("Adapter_Content")}
)

setGeneric(
    "Kmer_Content",
    function(object){standardGeneric("Kmer_Content")}
)

setGeneric(
    "Total_Deduplicated_Percentage",
    function(object){standardGeneric("Total_Deduplicated_Percentage")}
)
setGeneric("Version", function(object){standardGeneric("Version")})

setGeneric("getColours", function(object){standardGeneric("getColours")})

setGeneric(
    "setColours",
    function(object, PASS, WARN, FAIL, MAX){
        standardGeneric("setColours")
    }
)

setGeneric("setAlpha", function(object, alpha){standardGeneric("setAlpha")})
