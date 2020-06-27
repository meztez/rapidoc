# source("scripts/download_rapidoc_ui.R")

library(magrittr)

local({
  inst <- "./inst/dist"

  # download latest rapidoc
  latest_js <- "https://unpkg.com/rapidoc@latest/dist/rapidoc-min.js"

  desc <- read.dcf("DESCRIPTION")
  desc_version <- desc[1,"Version"] %>% unname()
  latest_version <- latest_js %>%
    readLines(2) %>%
    extract(2) %>%
    sub(" \\* RapiDoc ([^-]+) .*$", "\\1", .)
  r_version <- latest_version %>%
    gsub("[a-zA-Z-]", "", .)

  if (r_version == desc_version) {
    message("RapiDoc versions match")
    return()
  }

  if (!interactive()) {
    # throw when not interactive
    stop("Different RapiDoc version found. Current: '", desc_version, "'. New: '", r_version, "'. JS: '", latest_version, "'")
  }

  # saving R version at end of script

  flist <- dir(inst, full.names = TRUE)
  flist <- flist[which(! basename(flist) %in% c("index.html", "rapidoc-min.js"))]
  unlink(flist, recursive = TRUE)

  # download base file
  latest_index <- "https://unpkg.com/rapidoc@latest/dist/index.html"
  download.file(latest_index, file.path(inst, basename(latest_index)), quiet = TRUE, mode = "wb")
  download.file(latest_js, file.path(inst, basename(latest_js)), quiet = TRUE, mode = "wb")
  
  # download ressources linked in index.html
  index_lines <- file.path(inst, basename(latest_index)) %>%
    readLines(warn = FALSE)
  linked_ressources <-  index_lines %>%
    paste0(collapse = "\n") %>%
    gregexpr("(?:href|src)=\"([^\"]+)\"", .) %>%
    regmatches(index_lines, .) %>%
    unlist %>%
    sub("^(href|src)=\"", "", .) %>%
    sub("\"$", "", .) %>%
    unique %>%
    extract(!. %in% basename(latest_js))
  linked_local_name <- function(f) {
    basename(f) %>%
    sub("(\\?.*)?$", "", .) %>%
    sub("^css$", "fonts.css", .)
  }
  for (f in linked_ressources) {
    download.file(sub("^//", "http://", f), file.path(inst, linked_local_name(f)), quiet = TRUE, mode = "wb")
    index_lines <- gsub(f, paste0("./", linked_local_name(f)), index_lines, fixed = TRUE)
  }
  writeLines(index_lines, file.path(inst, "index.html"))
  
  # download each font file to be able to be served locally
  css_lines <- readLines(file.path(inst, "fonts.css"), warn = FALSE)
  font_urls <- css_lines %>%
    regexpr("url\\(([^\\)]+)\\)", .) %>%
    regmatches(css_lines, .) %>%
    sub("^url\\(\\s*", "", .) %>%
    sub("\\s*\\)$", "", .)
  for (ft in font_urls) {
    subpath <- gsub("https://fonts.gstatic.com/", "", ft)
    ftpath <- file.path(inst, subpath)
    if (!dir.exists(dirname(ftpath))) {
      dir.create(dirname(ftpath), recursive = TRUE)
    }
    download.file(ft, ftpath, quiet = TRUE, mode = "wb")
  }

  # update font file to be served locally
  readLines(file.path(inst, "fonts.css"), warn = FALSE) %>%
    gsub("https://fonts.gstatic.com/([^\\)]+)", "'./\\1'", .) %>%
    writeLines(., file.path(inst, "fonts.css"))

  message("Updated ./inst/dist to version: ", latest_version)


  # Save version
  desc_lines <- readLines("DESCRIPTION")
  desc_lines[grepl("^Version: ", desc_lines, )] <- paste0("Version: ", r_version)
  writeLines(desc_lines, "DESCRIPTION")
  message("Updated ./DESCRIPTION to version: ", r_version)

  readLines("NEWS.md") %>%
    paste0(collapse = "\n") %>%
    paste0(
      "# rapidoc ", r_version, "\n",
      "\n",
      "- Adds support for RapiDoc ", latest_version, "\n",
      "\n",
      "\n",
      .
    ) %>%
    writeLines("NEWS.md")
  message("Updated ./NEWS.md")


})
