#
# Shiny in production course
#

library(shiny)
library(dplyr)
library(shinythemes)
library(glue)
library(lime)
library(billboarder)

source("data/appData.R")

ui <- fluidPage(
    theme = shinytheme("simplex"),
    titlePanel("RStudio Conf 2019 - Shiny in Production Workshop"),

    sidebarLayout(
        sidebarPanel(
            selectInput("student", "Student Lookup:", choices = application_data$ID),
            htmlOutput("risk"),
            hr(),
            htmlOutput("major"),
            htmlOutput("minor"),
            hr(),
            HTML('<center><img src="rstudio.png"></center>'),
            HTML('<center><p>Shiny in Production Workshop 2019</p></center>')
        ),

        mainPanel(
            tabsetPanel(
                tabPanel("LIME Feature Plot", billboarderOutput("limeStudent")),
                tabPanel("Cachable Plot", HTML('<center><p>TBD</p></center>')),
                tabPanel("Data Drill Down", HTML('<center><p>TBD</p></center>'))
            )
        )
    )
)

server <- function(input, output) {
    
    obs_row <- reactive({
        obs_num <- application_data %>% filter(ID == !!input$student)
        obs_num$ID
    })
    
    output$risk <- renderText({
        risk_pred <- application_data %>% filter(ID == !!input$student)
        if (risk_pred$predict == 'No'){
            amt <- 'Low Risk'
        } else { amt <- 'Elevated Risk'}
        glue('<h4 style="text-align:center; font-weight:bold; color:#7b8a8b;">Assessment: {amt}</h4>') %>% HTML
    })
    
    output$major <- renderText({
        glue('<h4 style="font-weight:bold;">Major: </h4><p>{application_data[input$student,]$major}</p>') %>% HTML
    })
    
    output$minor <- renderText({
        glue('<h4 style="font-weight:bold;">Minor: </h4><p>{application_data[input$student,]$minor}</p>') %>% HTML
    })
    
    output$limeStudent <- renderBillboarder({
        prediction_data <- pred[[obs_row()]] %>% 
            select(feature_desc, feature_weight, risk_predictor) %>%
            mutate(pretty_features = gsub("_", " ", feature_desc))
        billboarder() %>%
            bb_barchart(
                data = prediction_data,
                mapping = bbaes(x = pretty_features, y = feature_weight, group = risk_predictor),
                rotated = TRUE,
                stacked = TRUE
            ) %>%
            bb_colors_manual('Low Risk' = "#417fe2", 'High Risk' = '#7f1c2e') %>%
            bb_title(text = glue('Feature Contributions to Student Performance Risk'))
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
