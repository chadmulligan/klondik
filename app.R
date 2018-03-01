library(shiny)
library(DT)
library(klondikBTC)


ui <- fluidPage(

  titlePanel(img(src = "mail.png",
                 height = 113, width = 241),
             windowTitle = "klondikBTC"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      width = 3, 

      textInput(inputId = "address", 
                label = "Enter a BTC address",
                value = "",
                width = "100%",
                placeholder = "13aK3ydezpfdwQDB34M7dcRugg8XfhQaEE"),
        
      actionButton(inputId = "getinfo", 
                     label = "New Search"),
      hr(),
      
      actionButton(inputId = "append", 
                   label = "Add Search"),
      helpText("Append new address transactions to results"),
      hr(),

      actionButton(inputId = "getcluster",
                     label = "Cluster"),
      helpText("Look for parent addresses from the results"),
      hr()
      
      
    ),
    
  
    mainPanel(
      tabsetPanel(id = "nav",
                  tabPanel("Transactions", DTOutput("transactions")),
                  tabPanel("New Cluster", 
                           verbatimTextOutput("cluster"),
                           actionButton(inputId = "getclusterinfo",
                                        label = "Get new transactions")),
                  tabPanel("All Addresses", verbatimTextOutput("allAddresses"))
                   )
    )
  )
)


server <- function(input, output, session) {
  
  hideTab(inputId = "nav", 
          target = "New Cluster")
  
  hideTab(inputId = "nav", 
          target = "All Addresses")
  
  hideTab(inputId = "nav", 
          target = "Transactions")
  
  
  values <- reactiveValues()
  
  
  observeEvent(input$getinfo, {
      
    values$allAddresses <- input$address
    
    tryCatch(
     {values$transactions <- get(input$address)
      showTab(inputId = "nav",
              target = "Transactions", 
              select = TRUE)},
      error = function(e) {
        showNotification(
          ui = "Please enter a valid BTC address",
          type = "error")}
      )
    
    output$transactions <- renderDT(DT::datatable(values$transactions, 
                                                  options = list(lengthMenu = list(c(100, -1),
                                                                                   c("100", 'All')))))
  })
  
  
  observeEvent(input$append, {
    
    tryCatch({
      values$transactions <- rbind(get(input$address), values$transactions)
      values$allAddresses <- c(input$address, values$allAddresses)
      },
      error = function(e) {
        showNotification(
          ui = "Please enter a valid BTC address",
          type = "error")}
    )
    
    output$transactions <- renderDT(DT::datatable(values$transactions, 
                                                  options = list(lengthMenu = list(c(100, -1),
                                                                                   c("100", 'All')))))
  })
  


  observeEvent(input$getcluster, {
    
    values$cluster <- c()
    
    tryCatch({
      values$cluster <- cluster(values$transactions, values$allAddresses)
    
      values$allAddresses <- unique(c(values$allAddresses, values$cluster))
      
      output$cluster <- renderText({paste(values$cluster, 
                                          collapse = "\n")})
      
      output$allAddresses <- renderText({paste(values$allAddresses, 
                                               collapse = "\n")})
      
      showTab(inputId = "nav",
              target = "New Cluster", 
              select = TRUE)
      
      showTab(inputId = "nav",
              target = "All Addresses", 
              select = FALSE)
    }, 
    error = function(err){
      showNotification(
        ui = paste("No parent address found"),
        type = "message")
    })
    
  })

  
  observeEvent(input$getclusterinfo, {

    values$transactions <- rbind(get(values$cluster), values$transactions)
    
    updateTabsetPanel(session,
                      inputId = "nav", 
                      selected = "Transactions")
    })
  
  
}


shinyApp(ui = ui, server = server)
