#' Path to RapiDoc Resources
#'
#' Retrieves the path to rapidoc resources.
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   browseURL(rapidoc_path())
#' } else {
#'   print(paste("You can explore rapidoc resources under: ", rapidoc_path()))
#' }
#' }
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
#' \dontrun{
#' if (interactive()) {
#'   browseURL(rapidoc_index())
#' } else {
#'   print(paste("You can use rapidoc under: ", rapidoc_index()))
#' }
#' }
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
#' @param spec_url Url to an OpenAPI specification
#' @param fonts_css Path to the fonts css file if you want to use fonts other than the default one.
#' @param slots HTML content to include between `<rapi-doc>` and `</rapi-doc>`
#' @param ... Other options recognized by RapiDoc inside the `rapi-doc` tag. You can replace `-` by underscore in names.
#' See https://mrin9.github.io/RapiDoc/api.html for a list of available options.
#' @return large string containing the contents of \code{\link{rapidoc_index}()} with
#' the appropriate specification path changed to the \code{spec_url} value.
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   slot1 <- '
#'   <img slot="logo"
#'   src="https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg"
#'   width=36px/>'
#'   rapidoc_spec("https://petstore.swagger.io/v2/swagger.json",
#'                fonts_css = "./fonts.css",
#'                slots = c(slot1),
#'                heading_text = "Google",
#'                allow_server_selection = FALSE)
#' }
#' }
#' @export
#' @rdname rapidoc_spec
rapidoc_spec <- function(spec_url = "https://petstore.swagger.io/v2/swagger.json",
                         fonts_css = "./fonts.css",
                         slots = character(),
                         ...) {
  rapidoc_options <- list(...)
  names(rapidoc_options) <- gsub("_", "-", names(rapidoc_options))
  rapidoc_options[["spec-url"]] <- NULL
  rapidoc_options <- lapply(rapidoc_options, function(x) {
    if (is.logical(x)) {
      tolower(as.character(x))
    } else {
      x
    }
  })
  index_file <- rapidoc_index()
  index_txt <- paste0(readLines(index_file), collapse = "\n")
  index_txt <- sub(
    "<rapi-doc spec-url(.+?)</rapi-doc>",
    paste0("<rapi-doc id=\"thedoc\" ",
           paste0(names(rapidoc_options), "=\"", rapidoc_options, "\"", collapse = " "),
           ">",
           slots,
           "</rapi-doc>",
           "<script>",
           "document.addEventListener('DOMContentLoaded', (event) => {",
           "let docEl = document.getElementById(\"thedoc\");",
           "docEl.loadSpec(\"", spec_url, "\");",
           "docEl.specUrl = \"", spec_url, "\";",
           "})</script>"),
    index_txt)
  index_txt <- sub("./fonts.css", fonts_css, index_txt, fixed = TRUE)
  index_txt
}


plumber_docs <- function() {
  logo <- '<img slot="logo" src="./plumber.svg" width=36px style=\"margin-left:7px\"/>'
  list(
    name = "rapidoc",
    index = function(fonts_css = "./fonts.css",
                      slots = logo,
                      heading_text = paste("Plumber", utils::packageVersion("plumber")),
                      allow_server_selection = FALSE,
                      primary_color = "#ea526f",
                      allow_authentication = FALSE,
                      layout = "column",
                      ...) {
      rapidoc::rapidoc_spec(
        spec_url = "\" + window.location.origin + window.location.pathname.replace(/\\(__docs__\\\\/|__docs__\\\\/index.html\\)$/, '') + 'openapi.json' + \"",
        fonts_css = fonts_css,
        slots = slots,
        heading_text = heading_text,
        allow_server_selection = allow_server_selection,
        primary_color = primary_color,
        allow_authentication = allow_authentication,
        layout = layout,
        ...
      )
    },
    static = function(...) {
      rapidoc::rapidoc_path()
    }
  )
}

plumber_register_docs <- function() {
  tryCatch({
    do.call(plumber::register_docs, plumber_docs())
  }, error = function(e) {
    message("Error registering rapidoc docs. Error: ", e)
    NULL
  })
}

.onLoad <- function(...) {
  setHook(packageEvent("plumber", "onLoad"), function(...) {
    plumber_register_docs()
  })
  if ("plumber" %in% loadedNamespaces()) {
    plumber_register_docs()
  }
}
