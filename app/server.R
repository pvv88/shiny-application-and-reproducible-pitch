# set locale to english for date manipulation
Sys.setlocale("LC_ALL", "English")


# import the required libraries
library(shiny)
library(nutshell)
library(DT)

# load and preprocess the data
data(sanfrancisco.home.sales)
housing <- sanfrancisco.home.sales

removeCols <- c("line", "county", "city", "latitude", "longitude")
housing <- housing[,!(names(housing) %in% removeCols)]

housing$month <- as.Date(housing$month)
housing$month <- format(housing$month, "%B")
housing$month <- as.factor(housing$month)

neighborhoods <- unique(housing$neighborhood)
naValues <- is.na(neighborhoods)

neighborhoods <- neighborhoods[!naValues]
neighborhoodNames <- as.character(neighborhoods[!naValues])
neighborhoodNames <- sort(neighborhoodNames)

housing4Table <- housing[,!(names(housing) %in% c("month"))]
housing4Table$date <- format(housing4Table$date, "%B, %Y")

housing4Table$price <- paste("$", format(housing4Table$price, big.mark=","), sep="")

# build the model
model <- lm(price ~ bedrooms + squarefeet + lotsize + month + neighborhood + year, 
            data = housing)

# Server logic
shinyServer(function(input, output, session) {
  
  # update the neighborhood select box with data from the dataset
  updateSelectInput(session, "neighborhood", choices = neighborhoodNames, 
                    selected=neighborhoodNames[1])
  
  # update the prediction output
  output$prediction <- renderText({
    
    # check if the data is provided, otherwise display error message
    validate(
      need(input$bedrooms != '', 'Please enter number of bedrooms!'),
      need(input$year != '', 'Please enter a year.')
    )
    
    # if the button was not clicked before show space holder
    if (input$estimateButton == 0) { 
      "Please press the 'Estimate!' button to obtain your result."
    } else if (input$estimateButton >= 1) {
      
      # otherwise, wait for the user to press the estimate button
      input$estimateButton  
      isolate(paste(
        "The estimated value of the house with the given characteristics is: $ ", 
        format(round(predict(model, data.frame(bedrooms = input$bedrooms, 
                                               squarefeet = input$squarefeet, 
                                               lotsize = input$lotsize,
                                               month = input$month,
                                               neighborhood = input$neighborhood,
                                               year = input$year))), big.mark=","),
        ".", sep=""))}})
  
  # Generate an HTML table view of the complete dataset
  output$fullSalesTable <- DT::renderDataTable(
    DT::datatable(
      housing4Table, 
      colnames=c("Street", "ZIP Code", "Sold", "Price", "Bedrooms", "House Size (sqft)", 
                 "Lot Size (sqft)", "Built", "Neighborhood"),
      rownames = FALSE, selection = 'none',
      options = list(pageLength = 15, lengthMenu = c(5, 10, 15, 20, 25)))
  )
  
  # Generate an HTML table view of the data which matches the selected input
  output$salesTable <- DT::renderDataTable(
    DT::datatable({
      data <- housing4Table
      data <- data[(data$bedrooms == input$bedrooms & !is.na(data$bedrooms)) 
                   | (data$year == input$year & !is.na(data$year)) 
                   | (data$neighborhood == input$neighborhood & !is.na(data$neighborhood)),]
      data}, selection = 'none',
      colnames = c("Street", "ZIP Code", "Sold", "Price", "Bedrooms", 
                   "House Size (sqft)", "Lot Size (sqft)", "Built", "Neighborhood"),
      rownames = FALSE, options = list(searching = FALSE, pageLength = 10, 
                                       lengthMenu = c(5, 10, 15)))
  )
})
