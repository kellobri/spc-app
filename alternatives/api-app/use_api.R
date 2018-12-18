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

# still need this helper for other parts of the app
booleans <- function() {
  c("has_repeated_courses",
    "user_group_member",
    "goal_setting",
    "exercise_routine",
    "sleep_7_hours",
    "has_morning_routine",
    "in_state",
    "scholarship",
    "full_time",
    "has_dependents",
    "has_opensource_contrib",
    "package_author",
    "conference_speaker",
    "eats_breakfast",
    "caffine_drinker",
    "meditation_routine",      
    "snooze_alarm",
    "self_care_rituals",
    "twitter_user")
}