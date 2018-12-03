# This file can be used to seed the library for this project in RStudio 
# or to seed the RStudio Connect packrat cache.
# 
# To simply setup a project with all the correct packages, source this file and then run `make_seed()`.
# Then run source("seed.R")
# 
# To seed the RStudio Connect cache, run the function `make_transplant()`. This function creates a seed.Rmd
# and corresponding manifest.json that can be programmatically deployed to RSC to pre-warm the cache.


set_repo <- function(){
  glue::glue("
  options(repos =c(
    internal = 'http://demo.rstudiopm.com/internal/521',
    CRAN = 'http://demo.rstudiopm.com/cran/521',
    RSPM = 'http://demo.rstudiopm.com/cran/521'
  ))
  "
  )
}


#pkgs required by the app
app_deps <- function() {
  c(
    'shiny',
    'dplyr',
    'tidyr',
    'shinythemes',
    'glue',
    'lime',
    'ggplot2',
    'parsnip',
    'recipes',
    'pool',
    'odbc',
    'DBI',
    'stringr',
    'gt',
    'xgboost',
    'config'
  )
}

# pkgs used for the class 
class_deps <- function() {
  c(
    'shinyloadtest',
    'shinytest',
    'profvis',
    'shinyreactlog',
    'rstudioapi'
  )  
}

# generate R file with install functions
make_seed <- function(){
  pkgs <- c(app_deps(), class_deps())
  libs <- paste('install.packages("', pkgs, '")', collapse = '\n')
  file.remove('seed.R')
  capture.output(set_repo(), file = 'seed.R')
  capture.output(cat(libs), file = 'seed.R', append = TRUE)
}

# generate dummy RMD with a list of pkgs
# and corresponding manifest
make_transplant <- function() {
  pkgs <- c(app_deps())
  libs <- paste('library(', pkgs, ')', collapse = '\n')
  tmplate <- 
    "
    --- 
    title: Seed RStudio Connect Packages
    ---
    You can safely ignore this report. It was used 
    to warm up the RStudio Connect package cache
    so that deployment during the class was fast.

    ```{{r setup}}
    {libs}
    ```
    "
  file.remove('seed.Rmd')
  capture.output(glue::glue(tmplate), file = 'seed.Rmd')
  rsconnect::writeManifest(
    appDir = ".", 
    appFiles = c("seed.Rmd")
  )
}