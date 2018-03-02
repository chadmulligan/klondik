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
      hr(),
      
      downloadButton(outputId = "downloadCSV",
                     label = "Download .csv")
      
    ),
    
  
    mainPanel(
      tabsetPanel(id = "nav",
                  tabPanel("Transactions", DTOutput("transactions")),
                  tabPanel("Cluster", 
                           verbatimTextOutput("cluster"),
                           uiOutput("getclusterinfo")),
                  tabPanel("All Addresses", verbatimTextOutput("allAddresses"))
                  )
    )
  )
)


server <- function(input, output, session) {
  
  hideTab(inputId = "nav", 
          target = "Cluster")
  
  hideTab(inputId = "nav", 
          target = "All Addresses")
  
  hideTab(inputId = "nav", 
          target = "Transactions")
  
  values <- reactiveValues()
  
  
  observeEvent(input$getinfo, {
      
    tryCatch({
      values$transactions <- get(input$address)
      output$transactions <- renderDT(DT::datatable(values$transactions, 
                                                   options = list(lengthMenu = list(c(100, -1),
                                                                                    c("100", 'All')))))
      showTab(inputId = "nav",
              target = "Transactions", 
              select = TRUE)
      
      values$allAddresses <- input$address
      
      values$searched <- input$address
      
      values$cluster <- c()

      },
      error = function(e) {
        showNotification(
          ui = "Please enter a valid BTC address.",
          type = "error")}
      )
  })
  
  
  observeEvent(input$append, {
    
    tryCatch({
      
    if (input$address %in% values$searched) warning() else{
      values$transactions <- rbind(get(input$address), values$transactions)
      values$allAddresses <- c(input$address, values$allAddresses)
      output$transactions <- renderDT(DT::datatable(values$transactions, 
                                                    options = list(lengthMenu = list(c(100, -1),
                                                                                     c("100", 'All')))))
      output$allAddresses <- renderText({paste(values$allAddresses, 
                                               collapse = "\n")})

      updateTabsetPanel(session,
                        inputId = "nav", 
                        selected = "Transactions")
      
      showTab(inputId = "nav",
              target = "All Addresses",
              select = FALSE)
      
      values$searched <- c(values$searched, input$address)
      
      }
    },
    warning = function(w) {
      showNotification(
        ui = "You already searched this address.",
        type = "warning")
    },
    error = function(e) {
      showNotification(
        ui = "Please enter a valid BTC address.",
        type = "error")
      }
    )
  })
  


  observeEvent(input$getcluster, {
    
    tryCatch({
      values$cluster <- cluster(values$transactions, values$allAddresses)
    
      values$allAddresses <- unique(c(values$allAddresses, values$cluster))
      
      output$cluster <- renderText({paste(values$cluster, 
                                          collapse = "\n")})
      
      output$allAddresses <- renderText({paste(values$allAddresses, 
                                               collapse = "\n")})
      
      showTab(inputId = "nav",
              target = "Cluster", 
              select = TRUE)
        
      showTab(inputId = "nav",
              target = "All Addresses", 
              select = FALSE)
      
      output$getclusterinfo <- renderUI({
        actionButton(inputId = "clusterinfobutton",
                          label = "Get new transactions")
        })
      
    }, 
    error = function(err){
      showNotification(
        ui = paste("No parent address found"),
        type = "message")
    })
    
  })

  
  observeEvent(input$clusterinfobutton, {

    values$transactions <- rbind(get(values$cluster), values$transactions) 
    
    values$searched <- c(values$searched, values$cluster)
    
    values$cluster <- c()
    
    updateTabsetPanel(session,
                      inputId = "nav", 
                      selected = "Transactions")
    
    removeUI(selector = "#clusterinfobutton")
    
    })
  
  
  output$downloadCSV <- downloadHandler(
    filename = function() {
      paste(paste(values$searched[[1]]), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(as.data.frame(c(values$transactions)), file)
    }
  )
  
}


shinyApp(ui = ui, server = server)
