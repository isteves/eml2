#' get_attributes
#'
#' get_attributes
#' @param x an "attributeList" element from an emld object
#' @param eml The full eml document, needed only if <references> outside of attributes must be resolved.
#' @return a data frame whose rows are the attributes (names of each column in the data file)
#' and whose columns describe metadata about those attributes.  By default separate tables
#' are given for each type
#' @details EML metadata can use "references" elements which allow one attribute to use metadata
#' declared elsewhere in the document.  This function will automatically resolve these references
#' and thus infer the correct metadata.
#' @export
#' @importFrom dplyr bind_rows
#' @examples
#' eml <- read_eml(system.file("xsd/test/eml-datasetWithAttributelevelMethods.xml", package = "EML"))
#' get_attributes(eml$dataset$dataTable$attributeList)
get_attributes <- function(x, eml = NULL) {
  attributeList <- x

  ## if the attributeList is referenced, get reference
  if (!is.null(attributeList$references)) {

    if (is.null(eml)) {
      warning("The attributeList entered is referenced somewhere else in the eml.",
              "No eml was entered to find the attributes.",
              "Please enter the eml to get better results.")
      eml = x
    }

    all_attributeLists <- eml_get(eml, "attributeList")

    for (attList in all_attributeLists) {

      if (attList$id == attributeList$references) {
        attributeList <- attList
        break
      }
    }
  }

  ## get attributes
  attributes <- lapply(attributeList$attribute, function(x) {

    ## get full attribute list
    atts <- unlist(x, recursive = TRUE, use.names = TRUE)
    measurementScale <- names(x$measurementScale)
    domain <- names(x$measurementScale[[measurementScale]])

    if(length(domain) == 1) {
      ## domain == "nonNumericDomain"
      domain <- names(x$measurementScale[[measurementScale]][[domain]])
    }
    domain <- domain[grepl("Domain", domain)]
    atts <- c(atts, measurementScale = measurementScale, domain = domain)

    ## separate factors
    atts <- atts[!grepl("enumeratedDomain", names(atts))]

    ## separate methods
    atts <- atts[!grepl("methods", names(atts))]

    ## Alter names to be consistent with other tools
    names(atts) <- gsub("missingValueCode.code", "missingValueCode", names(atts), fixed = TRUE)
    names(atts) <- gsub("standardUnit|customUnit", "unit", names(atts))
    names(atts) <- gsub(".+\\.+", "", names(atts))
    atts <- as.data.frame(t(atts), stringsAsFactors = FALSE)
  })
  attributes <- dplyr::bind_rows(attributes)

  ## remove non_fields in attributes
  non_fields <- c("enforced", "exclusive", "id", "order", "references", "scope", "system", "typeSystem")
  attributes <- attributes[ ,!(names(attributes) %in% non_fields)]

  ## get factors
  factors <- lapply(attributeList$attribute, function(x) {

    ## get factors
    factors <- eml_get(x, "enumeratedDomain")

    ## linearize factors
    factors <- lapply(factors$codeDefinition, function(x) {
      as.data.frame(x, stringsAsFactors = FALSE)
    })
    factors <- do.call(rbind, factors)

    if (!is.null(factors)) {
      factors$attributeName <- x$attributeName
    }

    return(factors)
  })
  factors <- dplyr::bind_rows(factors)

  if (nrow(factors) > 0) {
  factors <- factors[!is.na(factors$code), ]

  } else {
    factors <- NULL
  }

  # FIXME: add support for methods

  out <- list(attributes = attributes,
              factors = factors)
  return(out)
}
