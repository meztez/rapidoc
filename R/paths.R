#' Path to RapiDoc Resources
#'
#' Retrieves the path to rapidoc resources.
#'
#' @examples
#'
#' if (interactive()) {
#'   browseURL(rapidoc_path())
#' } else {
#'   print(paste("You can explore rapidoc resources under: ", rapidoc_path()))
#' }
#'
#' @export
#' @rdname rapidoc_path
rapidoc_path <- function() {
  system.file(
    "dist",
    package = "rapidoc"
  )
}

#' Path to Rapidoc Index
#'
#' Retrieves the path to the rapidoc index file.
#'
#' @examples
#'
#' if (interactive()) {
#'   browseURL(rapidoc_index())
#' } else {
#'   print(paste("You can use rapidoc under: ", rapidoc_index()))
#' }
#'
#' @export
#' @rdname rapidoc_index
rapidoc_index <- function() {
  file.path(rapidoc_path(), "index.html")
}

#' RapiDoc Index File with OpenAPI Path
#'
#' Produces the content for a \code{index.html} file that will attempt to access a
#' provided OpenAPI Specification URL.
#'
#' @param spec_url Url to an openAPI specification
#' @return large string containing the contents of \code{\link{rapidoc_index}()} with
#' the appropriate speicification path changed to the \code{spec_url} value.
#' @examples
#' if (interactive()) {
#'   rapidoc_spec("https://petstore.swagger.io/v2/swagger.json")
#' }
#' @export
#' @rdname redoc_spec
rapidoc_spec <- function(spec_url = "https://petstore.swagger.io/v2/swagger.json") {
  index_file <- rapidoc_index()
  index_txt <- paste0(readLines(index_file), collapse = "\n")
  index_txt <- sub("./specs/nested-example.yaml", spec_url, index_txt, fixed = TRUE)
  index_txt
}

plumber_add_ui <- function() {
  if (requireNamespace("plumber", quietly = TRUE)) {
    plumber::add_ui(
      list(
        package = "rapidoc",
        name = "rapidoc",
        index = function(...) {
          rapidoc::rapidoc_spec(
            spec_url = "\' + window.location.origin + window.location.pathname.replace(/\\(__rapidoc__\\\\/|__rapidoc__\\\\/index.html\\)$/, '') + 'openapi.json' + \'"
          )
        },
        static = function(...) {
          rapidoc::rapidoc_path()
        }
      )
    )
  }
}

.onLoad <- function(...) {
  plumber_add_ui()
}
