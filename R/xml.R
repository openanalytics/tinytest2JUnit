
tag <- function(name, ...) {
  args <- list(...)
  setNames(
      list(if (is.null(names(args))) {
                structure(list(...))
              } else {
                named <- names(args) != ""
                do.call(structure, c(list(do.call(list, args[!named])), args[named]))
              }),
      name)
}

format_as_xml <- function(tree) {
  attrs <- ""
  content <- paste(collapse = "", vapply(tree, format_as_xml, character(1)))
  sprintf("<%s %s>%s</%s>", names(tree), attrs, content, names(tree))
}
