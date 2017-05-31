library(shiny)
rUrl <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv'
wUrl <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv'

rWine <- read.table(rUrl, sep = ";", header = TRUE) 
wWine <- read.table(wUrl, sep = ";", header = TRUE) 

rWine$color <- "red"
wWine$color <- "white"

wine <- rbind(rWine,wWine)
wine$color <- as.factor(wine$color)
wine$color <- as.factor(wine$color)
wine$quality <- as.numeric(wine$quality)
wine$taste[wine$quality <= 3] <- 'very poor'
wine$taste[wine$quality == 4] <- 'poor'
wine$taste[wine$quality == 5] <- 'average'
wine$taste[wine$quality == 6] <- 'average'
wine$taste[wine$quality == 7] <- 'above average'
wine$taste[wine$quality == 8] <- 'excellent'
wine$taste[wine$quality >= 9] <- 'very excellent'
wine$taste <- as.factor(wine$taste)

wine <- wine[, !(colnames(wine) %in% c("quality"))]

set.seed(123)
sample <- sample(nrow(wine), 0.7 * nrow(wine))
train <- wine[sample, ]
test <- wine[-sample, ]

library(caret)
library(e1071)
library(randomForest)
#model <- randomForest(taste ~ . - quality, data = train)
tControl <- trainControl(method = "repeatedcv", number = 5, repeats = 3)
model <- train(taste ~ ., data = train,
                method = "rf", ntree =5, trControl = tControl)

# Server logic
shinyServer(function(input, output, session) {
  
  result <- reactiveValues(ttype = "")
  
  # update the prediction output
  output$prediction <- renderText({
    
    # check if the data is provided, otherwise display error message
    validate(
      need(input$color != '', 'Please enter color'),
      need(input$fixed != '', 'Please enter fixed acidity value'),
      need(input$volatile != '', 'Please enter volatile acidity value'),
      need(input$citric != '', 'Please enter citric acidity value'),
      need(input$residual != '', 'Please enter residual sugar value'),
      need(input$chlorides != '', 'Please enter chlorides value'),
      need(input$free != '', 'Please enter free sulfur dioxide value'),
      need(input$total != '', 'Please enter total free sulfur dioxide value'),
      need(input$pH != '', 'Please enter pH value'),
      need(input$sulphates != '', 'Please enter sulphates value'),
      need(input$alcohol != '', 'Please enter alcohol value')
    )
    
    if (input$eButton == 0) { 
      "Press the 'Test Me Now!' button to view the Wine Taste result."
    } else if (input$eButton >= 1) {
      input$eButton 
      
      qTaste <- predict(model, data.frame(color = input$color,
                                           fixed.acidity = input$fixed,
                                           volatile.acidity = input$volatile,
                                           citric.acid = input$citric,
                                           residual.sugar = input$residual,
                                           chlorides = input$chlorides,
                                           free.sulfur.dioxide = input$free, 
                                           total.sulfur.dioxide = input$total,
                                           pH = input$pH,
                                           density = input$density,
                                           sulphates = input$sulphates,
                                           alcohol = input$alcohol))
      result$ttype <- qTaste
      isolate(paste(qTaste))
        }
    })
  # Generate an HTML table view of the data which matches the selected input
  output$WineTable <- DT::renderDataTable(
    DT::datatable({
      wdata <- wine
      wdata <- wdata[wdata$taste == result$ttype,]   
      wdata}, selection = 'none',
      rownames = FALSE, options = list(searching = FALSE, pageLength = 10, 
                                       lengthMenu = c(5, 10, 15)))
  )
  
})
