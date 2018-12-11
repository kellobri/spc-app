library(lime)
library(xgboost)
library(plumber)
library(jsonlite)
library(parsnip)
library(recipes)
library(dplyr)

# helper functions 
parse_request <- function(req){
  fromJSON(req$postBody)
}

# load saved model
data_preprocessor <- readRDS('data_preprocessor.RDS')
model <- readRDS('model.RDS')
model_explainer <- readRDS('model_explainer.RDS')

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

preprocess_student <- function(student) {
  student %>% 
    mutate_at(booleans(), as.logical) %>% 
    mutate_if(is.character, as.factor) %>% 
    bake(data_preprocessor, .)
}


#* @apiTitle Student Risk Model
#* @apiDescription Given student data, return the risk and explanations of that risk using a trained classification model.

#* @post /explain_risk
function(req) {
  parse_request(req) %>% 
    preprocess_student() %>% 
    lime::explain(
      x = .,
      model_explainer,
      n_features = 4,
      labels = "Yes",
      n_permutations = 100
    ) 
}

#* @post /predict_risk
function(req) {
  parse_request(req) %>% 
    preprocess_student() %>% 
    predict_class(model, .)
}

