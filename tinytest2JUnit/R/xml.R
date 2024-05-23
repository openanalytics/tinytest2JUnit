
#' XML tag
#' 
#' Create a list object that roughly mimics the behaviour of a simplistic XML tag element. 
#' Supported are XML tag-name, tag-attributes and tag-content.
#' 
#' @param name `character(1)` specifying the name of the tag.
#' @param attributes `named-list` being the XML attributes. 
#'    Names = attribute names, Values = attribute value.
#' @param content `unnamed-list` being the content XML-tag. Each element is placed 
#'  next to each other in the tag.
#' 
#' @return a `XMLtag`-object. 
tag <- function(name, attributes = list(), content = list()) {
  stopifnot(is.list(attributes), is.list(content), is.null(names(content)))
  if (length(attributes) > 0) {
    stopifnot(!is.null(names(attributes)), all(nchar(names(attributes)) > 0))
  }
  structure(list(name = name, attributes = attributes, content = content), class = "XMLtag")
}

#' Format method for XMLtag class
#' 
#' Format S3 method for the `XMLtag`-class
#' 
#' @param x an `XMLtag`-object
#' @param level print depth level. For each level 2 spaces are added to the left. The content of a 
#'   tag is automatically indented with 1 level.
#' @param ... to ignore
#' @return `character(1)` vector of the formatted XML tag. 
#' @export
format.XMLtag <- function(x, level = 0, ...) {
  nSpacesTag <- strrep(" ", 2 * level)
  nSpacesContent <- strrep(" ", 2 * (level + 1))
  
  contentsStr <- vapply(x$content, format, FUN.VALUE = character(1L), level = level + 1)
  contentsStr <- paste0(contentsStr, collapse = "\n")
  
  attributesStr <- vapply(
    X = names(x$attributes), 
    FUN = function(attrName) paste0(attrName, "='", x$attributes[[attrName]], "'"),
    FUN.VALUE = character(1L)
  )
  attributesStr <- paste0(attributesStr, collapse = " ")
  paste0(
    nSpacesTag, "<", x$name, if (nchar(attributesStr) > 0) paste0(" ", attributesStr), ">\n",
    if (nchar(contentsStr) > 0) paste0(nSpacesContent, contentsStr, "\n"),
    nSpacesTag, "</", x$name, ">"
  )
}

#' Escape xml text 
#' 
#' Escape the characters '<' and `&` in a character vector meant to be xml-text. 
#' 
#' @param x a `character` vector meant to be xml-text.
#' @return The same `character` vector x but xml text escaped.
escapeXmlText <- function(x) {
  stopifnot(is.character(x))
  x <- gsub("&", "&amp", x)
  x <- gsub("<", "&lt", x)
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
