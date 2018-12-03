#
# Shiny in production course
#

library(shiny)
library(dplyr)
library(tidyr)
library(shinythemes)
library(glue)
library(lime)
library(ggplot2)
library(parsnip)
library(recipes)
library(pool)
library(odbc)
library(DBI)
library(stringr)
library(gt)
library(xgboost)
library(config)

source('use_models.R', local = FALSE)

# create a pool of connections to our student database
db <- get('database')
    pool <- dbPool(
          odbc::odbc(),
          Driver   =  db$Driver,
          Server   =  db$Server,
          Database =  db$Database,
          UID      =  db$UID,
          PWD      =  db$PWD,
          Port     =  db$Port
)
onStop(function(){
    poolClose(pool)
})

ui <- fluidPage(
    theme = shinytheme("simplex"),
    titlePanel("RStudio Conf 2019 - Shiny in Production Workshop"),

    sidebarLayout(
        sidebarPanel(
            uiOutput('student_select'),
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
                tabPanel("LIME Feature Plot", plotOutput("limeStudent")),
                tabPanel("Data Drill Down", 
                         splitLayout(
                             gt_output("gtStudentNum"), 
                             gt_output("gtStudentBin")
                             )
                         )
            )
        )
        
   )
)

server <- function(input, output) {
    student_data <- reactive({
        pool %>% 
            tbl("students") %>% 
            filter(student_id == input$student) %>% 
            collect()
    })
    
    
    output$student_select <- renderUI({
        choices <- pool %>% 
            tbl("students") %>% 
            pull(student_id)
        selectizeInput('student', label = "Student ID", choices = choices)
    })
    
    
    output$risk <- renderText({
        risk_pred <- predict_risk(student_data())
        risk <- ifelse(risk_pred == 'No', 'Low Risk', 'Elevated Risk')
        HTML(glue('<h4 style="text-align:center; font-weight:bold; color:#7b8a8b;">Assessment: {risk}</h4>'))
    })
    
    output$major <- renderText({
        HTML(glue('<h4 style="font-weight:bold;">Major: </h4><p>{student_data()$major}</p>'))
    })
    
    output$minor <- renderText({
        HTML(glue('<h4 style="font-weight:bold;">Minor: </h4><p>{student_data()$minor}</p>'))
    })
    
    output$limeStudent <- renderPlot({
        explain_risk(student_data()) %>% 
            select(feature, feature_weight) %>% 
            mutate(feature = str_to_title(str_replace_all(feature, "_", " ")),
                   color = ifelse(feature_weight >0, 'Increasing Risk','Decreasing Risk')) %>% 
            ggplot(aes(reorder(feature, feature_weight), feature_weight, fill = color)) +
            geom_bar(stat = "identity") + 
            coord_flip() + 
            theme_minimal() + 
            scale_fill_manual(values = c("#417fe2", '#7f1c2e')) + 
            labs(
                title = 'Contributions to Risk Rating',
                x = NULL,
                y = NULL,
                fill = NULL
            )
    })
    
    output$gtStudentNum <- render_gt({
        avg_data <- pool %>% 
            tbl("students") %>% 
            select(-!!booleans(), -major, -minor, -student_id) %>% 
            mutate_all(as.numeric) %>% 
            summarise_all(mean) %>% 
            collect() %>% 
            gather("Attribute", "Average")
        
        student_data() %>% 
            select(-student_id, -major,-minor, -!!booleans()) %>% 
            gather("Attribute", "Student") %>%
            left_join(avg_data) %>% 
            mutate_if(is.character, ~str_to_title(str_replace_all(.,"_", " "))) %>% 
            gt() %>% 
            fmt_number(c("Student", "Average"))
    })
    
    output$gtStudentBin <- render_gt({
        student_data() %>%
            select(booleans()) %>% 
            gather("Attribute", "Student") %>% 
            mutate_if(is.character, ~str_to_title(str_replace_all(.,"_", " "))) %>% 
            gt() %>% 
            fmt("Student",fns = function(x){ifelse(x, "Yes", "No")})
    })

}


# Run the application 
shinyApp(ui = ui, server = server)
