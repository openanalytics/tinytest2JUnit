# Project: tinytest2JUnit
# 
# Author: ltuijnder
###############################################################################




#' XML tag
#' 
#' Create a list object that roughly mimics the behaviour of a simplistic xml tag element. 
#' Supported is xml tag-name, tag-attributes and tag-content.
#' 
#' @details 
#' xml namespaces are not supported in this strucuture. Nor can this be used to from xml comments.
#' 
#' The `xml-tag` object is a under-the-hood a list object with 2 attributes. "tag-name" and "class". The
#' latter of couse being "xml-tag" while the "name" attribute contains the tag name. 
#' 
#' @param name `character(1)` specifying the name of the tag.
#' @param ... named elements represent xml attributes. 
#'    While unnamed arguments represents tag content.
#' 
#' @return a list with a single element representing the xml tag. The name of element is the tag-name.
#'   The value of the element represents the tag content. The attributes of the tag are attached to 
#'   the tag_content (to not conflict with the names attribute of the tag)
#'  
#' @author Daan, ltuijnder
tagDaan <- function(name, ...) {  
  args <- list(...)
  has_attributes <- !is.null(names(args))
  if (!has_attributes){
    tag_content <- args
  }else{
    tag_content <- args[names(args) == ""]
    tag_attributes <- args[names(args) != ""] 
    attributes(tag_content) <- tag_attributes
  }
  setNames(list(tag_content), nm = name)
}
