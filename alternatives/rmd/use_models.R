# load prebuilt models 
data_preprocessor <- readRDS('data_preprocessor.RDS')
model <- readRDS('model.RDS')
model_explainer <- readRDS('model_explainer.RDS')

# classes needed for lime to work with our parsnip model
# predict_model._xgb.Booster <- function(x, newdata, type, ...) {
#   switch(type,
#          raw = predict_class(x, newdata),
#          prob = predict_classprob(x, newdata)
#   )
# }
# model_type._xgb.Booster <- function(x, ...) {
#   'classification'
# }

# helper functions for calling models
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

predict_risk <- function(student) {
  predict_class(model, preprocess_student(student))
}

explain_risk <- function(student) {
  #set.seed(33)
  lime::explain(
    x = preprocess_student(student),
    model_explainer,
    n_features = 4,
    labels = "Yes",
    n_permutations = 100
  )
}