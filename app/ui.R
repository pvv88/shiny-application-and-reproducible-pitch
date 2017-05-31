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
  headerPanel("HOUSE PRICE ESTIMATOR"),
  
  ## sidebar containing input components
  sidebarPanel(
    
    helpText("Please provide the following information about your house:"),
    hr(),
    numericInput("year", "When was the house built?", 
                 value=as.numeric(format(Sys.Date(), "%Y")), step=1),
    numericInput('bedrooms', 'Number of bedrooms:', 1, min = 1, max = 20, step = 1),
    sliderInput("squarefeet", "House size (sqft):", value = 500, min = 0, max = 15000),
    sliderInput("lotsize", "Lot size (sqft):", value = 500, min = 0, max = 15000),
    hr(),
    selectInput("neighborhood", "In which San Francisco neighborhood is the house located?", c(), 
                selected = NULL, multiple = FALSE, selectize = TRUE, width = NULL, size = NULL),
    hr(),
    selectInput("month", "When do you plan to sell/buy?", c("January", "February", 
                                                            "March", "April", "May", 
                                                            "June", "July", "August", 
                                                            "September", "October", 
                                                            "November", "December"), 
                selected = format(Sys.Date(), "%B"), multiple = FALSE, selectize = TRUE, 
                width = NULL, size = NULL),
    br(),
    actionButton("estimateButton", "Estimate!")
  ),
  
  # A tabset that includes the prediction part, complete dataset represented as table and 
  # the help file
  mainPanel(
    tabsetPanel(
      # prediction tab
      tabPanel("House Price Estimation", mainPanel(
        br(),
        h4("Price Estimation for Your House"),
        hr(),
        textOutput("prediction"),
        br(),
        br(),
        h4('Previously Sold Houses with Similar Characteristics'),
        hr(),
        helpText("The table below shows houses similar on one or more of the following 
                 criteria: number of bedrooms, the year when the house was built, and the 
                 neighborhood. For a complete listing of houses sold in San Francisco, 
                 in the period between February, 2008 and July, 2009, please refer to the 
                 'Previous House Sales' tab."),  
        br(),
        DT::dataTableOutput("salesTable"), style = 'width:100%;'
        )), 
      
      # complete dataset tab
      tabPanel("Previous House Sales", mainPanel(
        br(),
        h4("Houses Sold in San Francico in the Period Between February, 2008 and July, 2009"),
        hr(),
        br(),
        DT::dataTableOutput("fullSalesTable"), style = 'width:100%;'))
      
      # help file tab
      #tabPanel("About This App", includeMarkdown("summary.md"))
      )
    )
      ))