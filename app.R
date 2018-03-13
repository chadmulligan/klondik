library(shiny)
library(DT)
library(klondikBTC)
library(networkD3)
library(rdrop2)

ui <- fluidPage(
  
  tags$head(tags$link(rel="shortcut icon", type = "image/png", href="favicon.png")),
  
  tags$head(
    tags$style(HTML("hr {border-top: 1px solid;}"))
  ),

  titlePanel(img(src = "mail.png",
                 height = 113, width = 241),
             windowTitle = "klondikBTC"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      width = 3, 

      textInput(inputId = "address", 
                label = "Enter a BTC address",
                value = "",
                width = "90%",
                placeholder = "13aK3ydezpfdwQDB34M7dcRugg8XfhQaEE"),
        
      actionButton(inputId = "getinfo", 
                     label = "New Search"),
      helpText("Prices in USD are based on daily closing price"),
      hr(),
      
      actionButton(inputId = "append", 
                   label = "Add Search"),
      helpText("Append new address transactions to results"),
      hr(),
      
      actionButton(inputId = "getcluster",
                   label = "Cluster"),
      helpText("Look for parent addresses from the results"),
      hr(),
      
      actionButton(inputId = "getgraph", 
                   label = "Graph Transactions"),
      hr(),
      
      downloadButton(outputId = "downloadCSV",
                     label = "Download .csv")
      
    ),
    
  
    mainPanel(
      
      width = 9, 
      
      tabsetPanel(id = "nav",
                  tabPanel("Transactions",
                           DTOutput("transactions")),
                  tabPanel("Cluster", 
                           verbatimTextOutput("cluster"),
                           uiOutput("getclusterinfo")),
                  tabPanel("All Addresses", verbatimTextOutput("allAddresses")),
                  tabPanel("graph", forceNetworkOutput("d3", height = "850px"))
                  )
    )
  )
)


server <- function(input, output, session) {
  
  session$onSessionEnded(stopApp)
  
  hideTab(inputId = "nav", 
          target = "Cluster")
  
  hideTab(inputId = "nav", 
          target = "All Addresses")
  
  hideTab(inputId = "nav", 
          target = "Transactions")
  
  hideTab(inputId = "nav", 
          target = "graph")
  
  values <- reactiveValues()
  
  
###UPDATING THE PRICES DF###
  lastmodif <- format(file.info("E:/klondik/btc/shiny/data/prices.RData")$mtime, 
                      format = "%Y-%m-%d")
  if(lastmodif != Sys.Date()) {
    token = readRDS("E:/klondik/btc/shiny/data/token.RDS")
    drop_download(path = "btc-prices/prices.RData", 
                  local_path = "E:/klondik/btc/shiny/data/",
                  overwrite = TRUE, 
                  dtoken = token)
    load("E:/klondik/btc/shiny/data/prices.RData")
  }
  

###OUTPUTS###
  observeEvent(input$getinfo, {
      
    tryCatch({
      values$transactions <- get(input$address)
      
      output$transactions <- renderDT({
        formatCurrency(DT::datatable(values$transactions, 
                                     options = list(
                                       lengthMenu = list(c(100, -1), c("100", 'All')), 
                                       columnDefs = list(list(targets = 1, 
                                                              render = JS("function(data, type, row, meta) {","return type === 'display' && data.length > 30 ?","'<span title=\"' + data + '\">' + data.substr(0, 20) + '...</span>' : data;","}")))
                                     )),
                       columns = "USD")
        })
      
      showTab(inputId = "nav",
              target = "Transactions", 
              select = TRUE)
      
      removeUI(selector = "#clusterinfobutton")
      
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
     
      if (is.null(values$searched)) message() else{   
        if (input$address %in% values$searched) warning() else{
          values$transactions <- distinct(rbind(get(input$address), values$transactions))
          values$allAddresses <- unique(c(input$address, values$allAddresses))
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
      },
    message = function(m) {
      showNotification(
        ui = "Please start a New Search first.",
        type = "message")
      }
    )
  })
  
  
  
  observeEvent(input$getcluster, {
    
    tryCatch({
      #if is.null(values$cluster) message("already clustered)
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

    values$transactions <- distinct(rbind(get(values$cluster), values$transactions))
    
    values$searched <- c(values$searched, values$cluster)
    
    values$cluster <- c()
    
    updateTabsetPanel(session,
                      inputId = "nav", 
                      selected = "Transactions")
    
    removeUI(selector = "#clusterinfobutton")
    
    })
  
  
  
  observeEvent(input$getgraph, {
    
    output$d3 <- renderForceNetwork(graphD3(values$transactions, values$allAdresses))
    
    showTab(inputId = "nav",
            target = "graph",
            select = TRUE)
    
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
