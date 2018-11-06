library(h2o)
library(tidyverse)
library(readxl)     
library(lime)       
library(recipes)    

# Import Data: rstudio_students.csv
View(rstudio_student_data)

students_tbl <- rstudio_student_data %>%
  mutate_if(is.character, as.factor) %>%
  select(student_id, risk, major, minor, everything())

recipe_cleanup <- students_tbl %>%
  recipe(formula = risk ~ .) %>%
  step_rm(student_id) %>%
  step_zv(all_predictors()) %>%
  step_center(all_numeric()) %>%
  step_scale(all_numeric()) %>%
  prep(data = students_tbl)


student_bake <- bake(recipe_cleanup, newdata = students_tbl) 

h2o.init()

rstudio_h2o <- as.h2o(student_bake)

h2o_split <- h2o.splitFrame(rstudio_h2o, ratios = c(0.7, 0.15), seed = 222)

train_h2o <- h2o.assign(h2o_split[[1]], "train" ) # 70%
valid_h2o <- h2o.assign(h2o_split[[2]], "valid" ) # 15%
test_h2o  <- h2o.assign(h2o_split[[3]], "test" )  # 15%

y <- "risk"
x <- setdiff(names(train_h2o), c('risk'))

automl_models_h2o <- h2o.automl(
  x = x, 
  y = y,
  training_frame    = train_h2o,
  leaderboard_frame  = valid_h2o,
  max_runtime_secs  = 60
)

automl_leader <- automl_models_h2o@leader

# Make Predictions on Test Data
risk_predictions <- h2o.predict(
  object = automl_leader,
  newdata = test_h2o)

risk_pred <- as.data.frame(risk_predictions)
risk_pred <- tibble::rowid_to_column(risk_pred, "ID")
test_data <- as.data.frame(test_h2o)
test_data <- tibble::rowid_to_column(test_data, "ID")

application_data <- left_join(risk_pred, test_data)

# LIME explainer

explainer <- lime::lime(
  application_data[,-c(1:5)],
  model          = automl_leader, 
  bin_continuous = FALSE
)

obs <- 1 # This is the observation (employee position in test data set) to explain 
set.seed(222)

explanation <- lime::explain(
  x              = application_data[obs,-c(1:5)], 
  explainer      = explainer, 
  n_labels       = 1, 
  n_features     = 6,
  n_permutations = 1000,
  kernel_width   = 1
)

plot_features(explanation)


# ------ #

create_pred_vis <- function(obs){
  gen_lime_exp <- function(obs){
    single_explanation <- as.data.frame(test_h2o) %>% 
      slice(obs) %>% 
      select(-risk) %>%
      lime::explain(
        explainer  = explainer,
        n_labels   = 1,
        n_features = 6,
        n_permutations = 1000,
        kernel_width   = 1
      ) %>%
      as.tibble()
    return(single_explanation)
  }
  
  explanation <- gen_lime_exp(obs)
  
  type_pal <- c('Supports', 'Contradicts')
  explanation$type <- factor(ifelse(sign(explanation$feature_weight) == 
                                      1, type_pal[1], type_pal[2]), levels = type_pal)
  description <- paste0(explanation$case, "_", explanation$label)
  desc_width <- max(nchar(description)) + 1
  description <- paste0(format(description, width = desc_width), 
                        explanation$feature_desc)
  explanation$description <- factor(description, levels = description[order(abs(explanation$feature_weight))])
  explanation$case <- factor(explanation$case, unique(explanation$case))
  
  explanation_plot_df <- explanation %>%
    mutate(risk_predictor = case_when(
      (label == 'Yes' & type == 'Supports') | (label == 'No' & type == 'Contradicts') ~ 'High Risk',
      (label == 'Yes' & type == 'Contradicts') | (label == 'No' & type == 'Supports') ~ 'Low Risk'
    )) %>%
    arrange(-abs(feature_weight)) %>% 
    head(20)
  
  return(explanation_plot_df)
}

#create_pred_vis(1)

# Runs for about 45 minutes
# Produces a Large list 
pred <- lapply(1:nrow(application_data), create_pred_vis)

saveRDS(pred, "lime_prediction_results.RDS")
saveRDS(application_data, "application_data.RDS")



#####
#####

billboarder() %>%
  bb_barchart(
    data = pred[[1]],
    mapping = bbaes(x = feature_desc, y = feature_weight, group = risk_predictor),
    rotated = TRUE,
    stacked = TRUE
  ) %>%
  bb_colors_manual('No' = "#95a5a6", 'Yes' = '#2C3E50') %>%
  bb_title(text = glue('Feature Contributions to Student Dropout Risk'))
