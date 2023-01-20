
#' XML tag
#' 
#' Create a list object that roughly mimics the behaviour of a simplistic xml tag element. 
#' Supported is xml tag-name, tag-attributes and tag-content.
#' 
#' The `xml-tag` object is a under-the-hood a list object with 2 attributes. "tag-name" and "class". The
#' latter of couse being "xml-tag" while the "name" attribute contains the tag name. 
#' 
#' @param name `character(1)` specifying the name of the tag.
#' @param ... named arguments represent xml attributes, while unnamed arguments represents tag content.
#' 
#' @return a `XMLtag`-object. The name of element is the tag-name.
#'   The value of the element represents the tag content. The attributes of the tag are attached to 
#'   the tag_content (to not conflict with the names attribute of the tag)
#'  
#' @author ltuijnder
tag <- function(name, ...){
  args <- list(...)
  if(is.null(names(args))){
    attributes = list()
    content = args
  }else{
    attributes = args[names(args)!=""]
    content = args[names(args)==""]
  }
  structure(list(name = name, attributes = attributes, content = content), class = "XMLtag")
}

#' Format method for XMLtag class
#' 
#' Format S3 method for the `XMLtag`-class
#' 
#' @param tag a `XMLtag`-object
#' @param level print depth level. For each level 2 spaces are added to the left. The content of a 
#'   tag is automatically indendted with 1 level.
#' @param ... to ignore
#' @return `character(1)` vector of the formatted XML tag. 
#' @author ltuijnder
#' @export
format.XMLtag <- function(tag, level = 0, ...){
  
  n_spaces_tag = strrep(" ", 2 * level)
  n_spaces_content = strrep(" ", 2 * (level + 1))
  
  contents_str <- vapply(tag$content, format, FUN.VALUE = character(1L), level = level + 1)
  contents_str <- paste0(contents_str, collapse = "\n")
  
  attributes_str <- vapply(
    X = names(tag$attributes), 
    FUN = function(attr_nm) paste0(attr_nm,"='",tag$attributes[[attr_nm]],"'"),
    FUN.VALUE = character(1L)
  )
  attributes_str <- paste0(attributes_str, collapse = " ")
  paste0(
    n_spaces_tag, "<", tag$name, if(nchar(attributes_str)>0) paste0(" ", attributes_str),">\n",
    if(nchar(contents_str) > 0) paste0(n_spaces_content, contents_str, "\n"),
    n_spaces_tag, "</", tag$name, ">"
  )
}
## Refactor the above:paste0


#' Print method for XMLtag class.
#' 
#' print method for XMLtag class.
#' 
#' @param tag a `XMLtag`-object
#' @param ... to be ignored
#' @return `invisibly` the string that was printed to stdout.
#' @author ltuijnder
#' @export
print.XMLtag <- function(tag, ...){
  str <- format(tag)
  cat(str)
  invisible(str)
}
