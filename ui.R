library(shiny)
library(markdown)
library(nutshell)
library(DT)

shinyUI(fluidPage(
  
  # style for validation messages
  tags$head(
    tags$style(HTML("
                    .shiny-output-error-validation {
                    color: red;
                    }
                    "))
    ),
  
  # Application title
  headerPanel("WINE TESTER"),
  
  ## sidebar containing input components
  sidebarPanel(
    
    helpText("Fill the ingredients below before you click this button:"),
    actionButton("eButton", "TEST NOW!"),
    hr(),
    selectInput("color", "Wine Color:", c("white", "red"),multiple = FALSE, selectize = TRUE, 
                width = NULL, size = NULL),
    sliderInput("fixed", "Fixed Acidity:", 1, min = 1, max = 20),
    sliderInput("volatile", "Volatile Acidity:", 0.1, min = 0.1, max = 2),
    sliderInput("citric", "Citric Acid:", 0.00, min = 0.00, max = 1.00),
    sliderInput("residual", "Residual Sugar:", 0.1, min = 0.1, max = 20),
    sliderInput("chlorides", "Chlorides:", 0.01, min = 0.01, max = .1),
    sliderInput("free", "Free Sulfur Dioxide:", 1, min = 1, max = 72),
    sliderInput("total", "Total Sulfur Dioxide:", 6, min = 6, max = 289),
    sliderInput("density", "Density:", 0.99007, min = 0, max = 1.00000),
    sliderInput("pH", "pH:", 0.1, min = 0.1, max = 2.0),
    sliderInput("sulphates", "Sulphates:", 0.33, min = 0.33, max = 2.0),
    sliderInput("alcohol", "Alcohol:", 8.4, min = 8.4, max =14.9)
  ),
  
  # Includes the prediction andcomplete dataset represented as table and help file
  mainPanel(
    tabsetPanel(
      # prediction tab
      tabPanel("Wine Quality Evaluation", mainPanel(
        br(),
        h4("The quality of your newly created wine is:"),
        hr(),
        textOutput("prediction"),
        br(),
        br(),
        h4('Previously evaluated Wine Mixes with Similar Characteristics'),
        hr(),
        helpText("The table below shows wines that have similar criteria as your wine"),  
        br(),
        DT::dataTableOutput("WineTable"), style = 'width:100%;'
        ))
      ))
))