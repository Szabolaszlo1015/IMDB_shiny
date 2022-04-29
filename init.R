my_packages = c("shiny", "shinythemes", "tidyverse", "rvest", "knitr", "kableExtra", "highcharter","viridisLite", "XML", "xml2")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))