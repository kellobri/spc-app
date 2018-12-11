library(httr)
library(tibble)
library(purrr)

#API_BASE <- Sys.getenv("API_BASE")
API_BASE <- "https://colorado.rstudio.com/rsc/content/1796/"

explain_risk <- function(student) {
  resp <- POST(
    paste0(API_BASE, "explain_risk"),
    body = student,
    encode = "json"
  )
  content(resp) %>% 
  map_df(~tibble(
    feature = .x$feature, 
    feature_weight = .x$feature_weight)
  )
}

predict_risk <- function(student) {
  resp <- POST(
    paste0(API_BASE, "predict_risk"),
    body = student,
    encode = "json"
  ) 
  as.character(content(resp)[[1]])
}