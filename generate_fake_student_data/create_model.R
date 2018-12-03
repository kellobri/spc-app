library(recipes)
library(parsnip)
library(lime)
library(xgboost)
library(rsample)
library(yardstick)
library(DBI)

# data without true classification
#db <- dbConnect(RSQLite::SQLite(), "students")
#rstudio_student_data <- dbReadTable(db, "students")

# data with true classification
rstudio_student_data <- read.csv("generate_fake_student_data/rstudio-student-data.csv")
rstudio_student_data$X <- NULL

train_test_split <- initial_split(rstudio_student_data)

students_train <- training(train_test_split)
students_test <- testing(train_test_split)

recipe_cleanup <- students_train %>%
  recipe(formula = risk ~ .) %>%
  step_rm(student_id) %>%
  step_zv(all_predictors()) %>%
  step_center(all_numeric()) %>%
  step_scale(all_numeric()) %>%
  prep(data = students_train)


# model training
train <- bake(recipe_cleanup, newdata = students_train) 
model_def <- boost_tree("classification") %>%
  set_engine("xgboost")

model <- fit(model_def, risk ~ ., data = train)

# check model results
train_results <- train %>% 
  mutate(pred = predict_class(model, train),
         estimate = predict_classprob(model, train) %>% pull(Yes),
         truth = as.factor(risk))

train_results %>% roc_auc(truth, estimate)
train_results %>% accuracy(truth, risk)

test <- bake(recipe_cleanup, students_test)
test_results <- test %>% 
  mutate(pred = predict_class(model, test),
         estimate = predict_classprob(model, test) %>% pull(Yes),
         truth = as.factor(risk))

test_results %>% roc_auc(truth, estimate)
test_results %>% accuracy(truth, risk)


# update parsnip model for use with lime
predict_model.model_fit <- function(x, newdata, type, ...) {
  switch(type,
    raw = predict_class(x, newdata),
    prob = predict_classprob(x, newdata)
  )
}

model_type.model_fit <- function(x, ...) 'classification'



# lime model explanations
model_explainer <- lime(
  train,
  model = model
)

explained <- lime::explain(
    x = train[1,],
    model_explainer,
    n_features = 4,
    labels = "Yes",
    n_permutations = 100
)

saveRDS(model, "model.RDS")
saveRDS(recipe_cleanup, "data_preprocessor.RDS")
saveRDS(model_explainer, "model_explainer.RDS")


