

# Categorical Variables

majors <- c('shiny','rmarkdown','plumber','sparklyr','tidyverse')
minors <- c('leaflet', 'tidyr', 'rgl', 'htmlwidgets', 'Rcpp', 'keras', 'tibbletime', 
            'devtools', 'dplyr', 'lubridate', 'stringr', 'reticulate', 'ggplot2', 'carat',
            'recipes', 'DT', 'httr', 'jsonlite', 'testthat', 'roxygen2', 'readxl', 'packrat',
            'forcats', 'broom', 'purrr')

#high_lookup <- high_lookup[1:32,]
#low_lookup <- low_lookup[1:32,]

create_low_risk <- function(x){
  eval(parse(text=low_lookup[x,2]))
}

low_vals <- lapply(1:nrow(low_lookup), create_low_risk)

list_low <- replicate(1200, lapply(1:nrow(low_lookup), create_low_risk), simplify=FALSE)
lf <- lapply(list_low, unlist)
low_frame <- as.data.frame(lf, stringsAsFactors = F)
low_frame <- as.data.frame(t(low_frame))
low_frame$risk <- "No"
names(low_frame) <- t(low_lookup[,1])

create_high_risk <- function(x){
  eval(parse(text=high_lookup[x,2]))
}

high_vals <- lapply(1:nrow(high_lookup), create_high_risk)

list_high <- replicate(300, lapply(1:nrow(high_lookup), create_high_risk), simplify=FALSE)
hf <- lapply(list_high, unlist)
high_frame <- as.data.frame(hf, stringsAsFactors = F)
high_frame <- as.data.frame(t(high_frame))
high_frame$risk <- "Yes"
names(high_frame) <- t(high_lookup[,1])


rstudio_students <- rbind(low_frame, high_frame) 
rownames(rstudio_students) <- NULL
rstudio_students$student_id <- c(1:1500)

write.csv(rstudio_students, "~/Downloads/rstudio-student-data.csv")
#colnames(rstudio_student_data)[colnames(rstudio_student_data)=="X34"] <- "risk"


skim(rstudio_students)
