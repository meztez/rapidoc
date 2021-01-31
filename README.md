Generates `RapiDoc` documentation from an OAS Compliant API
================

<!-- badges: start -->

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/rapidoc)](https://cran.r-project.org/package=rapidoc)
[![R build
status](https://github.com/meztez/rapidoc/workflows/R-CMD-check/badge.svg)](https://github.com/meztez/rapidoc/actions)
[![RStudio
community](https://img.shields.io/badge/community-shiny-blue?style=social&logo=rstudio&logoColor=75AADB)](https://community.rstudio.com/tag/rapidoc)
<!-- badges: end -->

RapiDoc is a collection of `HTML`, `JavaScript`, `CSS` and fonts assets
that generate `RapiDoc` documentation from an OpenAPI Specification.

The main purpose of this package is to enable package authors to create
APIs that are compatible with
[RapiDoc](https://mrin9.github.io/RapiDoc/) and
[openapis.org](https://www.openapis.org/).

Package authors providing web interfaces can serve the static files from
`rapidoc_path()` using [httpuv](https://github.com/rstudio/httpuv) or
[fiery](https://github.com/thomasp85/fiery). As a start, we can also
browse them by running

``` r
library(rapidoc)
browseURL(rapidoc_index())
```

<img src="tools/readme/browse_rapidoc.png" width=450 />

## Installation

``` r
remotes::install_github("https://github.com/meztez/rapidoc/")
```

## Use with `plumber` R package

### `plumber` annotation syntax

``` r
library(rapidoc)

#* @plumber
function(pr) {
  pr$setDocs("rapidoc", bg_color = "#00DE9C")
}

#* @get /hello
function() {
  "hello"
}
```

### `plumber` programmatic usage

``` r
library(plumber)
library(rapidoc)
pr() %>%
  pr_get("hello", function() {"hello"}) %>%
  pr_set_docs("rapidoc", bg_color = "#00DE9C") %>%
  pr_run()
```

### Using `RapiDoc` API attributes

Further customize `RapiDoc` using its API attributes. Use underscores
instead of hyphens. R boolean values are converted.

``` r
pr()$setDocs(bg_color = "#F5F", show_info = FALSE)

pr() %>% pr_set_docs("rapidoc", bg_color = "#F5F", show_info = FALSE)
```

The full set of `RapiDoc` API attributes is supported.

To learn more about `RapiDoc` visit:

-   [RapiDoc](https://mrin9.github.io/RapiDoc/)
-   [RapiDoc API attributes
    reference](https://mrin9.github.io/RapiDoc/api.html)
