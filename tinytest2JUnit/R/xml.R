


#' XML tag
#' 
#' Create a list object that roughly mimics the behaviour of a simplistic XML tag element. 
#' Supported are XML tag-name, tag-attributes and tag-content.
#' 
#' @param name `character(1)` specifying the name of the tag.
#' @param attributes `named-list` being the XML attributes. 
#'    Names = attribute names, Values = attribute value.
#' @param content `unnamed-list` being the content XML-tag. Either child `XMLtag` or only  
#'  a single character vector being the xml text content. Currently no mixed-content is allowed.
#'  See details.
#'
#' 
#' @details
#' If a character vector is in the content it is converted to a single-length character vector. 
#' See [charVecToSingleLength()]
#'
#' Mixed content eg. a text string and a child xml tag next to each other is syntaxtically allows.
#' In practices it does not occur for XML that is schema formatted with XSD (like JUnit). 
#' So for simplicity it is not supported here.
#'
#' @return a `XMLtag`-object. 
tag <- function(name, attributes = list(), content = list()) {
  stopifnot(is.list(attributes), is.list(content), is.null(names(content)))
  if (length(attributes) > 0) {
    stopifnot(!is.null(names(attributes)), all(nchar(names(attributes)) > 0))
  }
  if (length(content) > 0) {
    contentIsString <- length(content) == 1 && is.character(content[[1]])
    contentIsChildTags <- all(vapply(content, inherits, "XMLtag", FUN.VALUE = logical(1)))
    if (!(contentIsString || contentIsChildTags)) {
      stop("Content should only be child-tags or only a single character vector")
    }
    if (contentIsString) content[[1]] <- charVecToSingleLength(content[[1]])
  }
  structure(list(name = name, attributes = attributes, content = content), class = "XMLtag")
}

#' Format method for XMLtag class
#' 
#' Format S3 method for the `XMLtag`-class
#' 
#' @param x an `XMLtag`-object
#' @param level print depth level. For each level 2 spaces are added to the left. The content of a 
#'   tag is automatically indented with 1 level. Except for text-content (see details).
#' 
#' @details
#' Note, text content does not get indented or put on a new line, since whites space characters 
#' are of relevance.
#' 
#' @param ... to ignore
#' @return `character(1)` vector of the formatted XML tag. 
#' @export
format.XMLtag <- function(x, level = 0, ...) {
  nSpacesTag <- strrep(" ", 2 * level)

  attributesStr <- vapply(
    X = names(x$attributes), 
    FUN = function(attrName) paste0(attrName, "='", x$attributes[[attrName]], "'"),
    FUN.VALUE = character(1L)
  )
  attributesStr <- paste0(attributesStr, collapse = " ")
  openingTag <- paste0("<", x$name, if (nchar(attributesStr) > 0) paste0(" ", attributesStr), ">")
  closingTag <- paste0("</", x$name, ">")
  
  if (length(x$content) == 0) {
    fTag <- paste0(nSpacesTag, openingTag, closingTag)
  } else if (length(x$content) == 1 && isSingleLengthCharNonNA(x$content[[1]])) {
    fTag <- paste0(nSpacesTag, openingTag, x$content[[1]], closingTag)   
  } else {
    fChildTags <- vapply(x$content, format, FUN.VALUE = character(1L), level = level + 1)
    fContent <- paste0(fChildTags, collapse = '\n')
    fTag <- paste0(nSpacesTag, openingTag, "\n", fContent, "\n", nSpacesTag, closingTag)
  }
  return(fTag)
}

#' Escape xml text 
#' 
#' Escape the characters '<' and `&` in a character vector meant to be xml-text content.
#' 
#' @param x a `character` vector meant to be xml-text content.
#' @return The same `character` vector x but xml text escaped.
escapeXmlText <- function(x) {
  stopifnot(is.character(x))
  x <- gsub("&", "&amp", x)
  x <- gsub("<", "&lt", x)
  return(x)
}


#' Escape xml
#' 
#' Escape the characters `&`,`"`,`'`,`<`,`>`
#' 
#' @seealso https://stackoverflow.com/a/1091953/10415129
#' @param x a `character` vector meant to be xml
#' @return The same `character` vector x but xml escaped.
escapeXml <- function(x) {
  stopifnot(is.character(x))
  x <- gsub("&", "&amp", x)
  x <- gsub("<", "&lt", x)
  x <- gsub(">", "&gt", x)
  x <- gsub("'", "&apos", x)
  x <- gsub('"', "&quot", x)
  return(x)
}

#' Print method for XMLtag class.
#' 
#' Print method for XMLtag class.
#' 
#' @param x a `XMLtag`-object
#' @param ... to be ignored
#' @return `invisibly` the string that was printed to stdout.
#' @export
print.XMLtag <- function(x, ...) {
  str <- format(x)
  cat(str)
  invisible(str)
}
