library(shiny)
library(shinyjs)
library(DT)
library(klondikBTC)
library(networkD3)
library(rdrop2)


source("global.R")

ui <- fluidPage(useShinyjs(), 
  
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
      
      fileInput(inputId = "file1", 
                label = "Or upload a list of addresses (*.csv )",
                width = "90%", 
                accept = c('text/csv',
                           'text/comma-separated-values',
                           '.csv')
      ),
      
        
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
      
      actionButton(inputId = "getscam",
                   label = "Scam Report"),
      helpText("Check whether the addresses were reported for scam"),
      hr(),
      
      actionButton(inputId = "getgraph", 
                   label = "Graph Transactions"),
      hr(),
      
      downloadButton(outputId = "downloadCSV",
                     label = "Download Transactions")
      
    ),
    
  
    mainPanel(
      
      width = 9, 
      
      tabsetPanel(id = "nav",
                  type = "pills", 
                  tabPanel("Transactions",
                           style = "overflow-y:scroll; max-height: 750px",
                           DTOutput("transactions")),
                  tabPanel("Cluster", 
                           style = "overflow-y:scroll; max-height: 750px",
                           verbatimTextOutput("cluster"),
                           uiOutput("getclusterinfo")),
                  tabPanel("Scam Report", 
                           style = "overflow-y:scroll; max-height: 750px",
                           value = "scamnull", 
                           verbatimTextOutput(outputId = "scamtext")),
                  tabPanel("Scam Report", 
                           style = "overflow-y:scroll; max-height: 750px",
                           value = "scamDT", 
                           
                           uiOutput("scam")),
                  tabPanel("All Addresses", 
                           style = "overflow-y:scroll; max-height: 750px",
                           verbatimTextOutput("allAddresses")),
                  tabPanel("Graph", forceNetworkOutput("d3", height = "750px")), 
                  tabPanel("About", 
                           style = "overflow-y:scroll; max-height: 750px",
                           includeMarkdown("www/About.md"))
                  )
    )
  )
)


server <- function(input, output, session) {
  
  #session$onSessionEnded(stopApp)
  
  updatePrices()
  
  hideTab(inputId = "nav", 
          target = "Cluster")
  
  hideTab(inputId = "nav", 
          target = "scamnull")
  
  hideTab(inputId = "nav", 
          target = "scamDT")
  
  hideTab(inputId = "nav", 
          target = "All Addresses")
  
  hideTab(inputId = "nav", 
          target = "Transactions")
  
  hideTab(inputId = "nav", 
          target = "Graph")
  
  values <- reactiveValues()
  
  values$countfiles <- 0 
  

###OUTPUTS###
  observeEvent(input$getinfo, {
      
    tryCatch({
      
      if(isTruthy(input$address)) {
        
        values$transactions <- getBTC(input$address)
        values$allAddresses <- input$address
        values$searched <- input$address 
        reset("address")
        
        } else{
        
        if(!isTruthy(input$file1)){
          
          warning()
          
          } else {
            
            values$f <- c(unlist(read.csv(input$file1[values$countfiles+1, "datapath"],
                                          header = FALSE,
                                          stringsAsFactors = FALSE),
                          use.names = FALSE))

            values$transactions <- getBTC(values$f)
            values$allAddresses <- values$f
            values$searched <- values$f
            
            values$countfile <- values$countfile +1 
            reset("file1")
                
           }
        }

      
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
      
      
      output$allAddresses <- renderText({paste(values$allAddresses, 
                                               collapse = "\n")})
      
      showTab(inputId = "nav",
              target = "All Addresses", 
              select = FALSE)

      removeUI(selector = "#clusterinfobutton")
      values$cluster <- NULL
      values$scamAddresses <- NULL
      values$scamResults <- NULL

      },
      warning = function(w) {
        showNotification(
          ui = "Please enter a BTC address or upload a file.",
          type = "warning")
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
          values$transactions <- distinct(rbind(getBTC(input$address), values$transactions))
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

    values$transactions <- distinct(rbind(getBTC(values$cluster), values$transactions))
    
    values$searched <- c(values$searched, values$cluster)
    
    values$cluster <- c()
    
    updateTabsetPanel(session,
                      inputId = "nav", 
                      selected = "Transactions")
    
    reset("address")
    
    removeUI(selector = "#clusterinfobutton")
    
    })
  
  
  
  observeEvent(input$getscam, {
    
    tryCatch({
      
      if(is.null(values$allAddresses)) {
        
        message()
        
      } else { 
      
        index <- values$searched %in% values$scamAddresses 
        
        if(all(index)) {
          
          warning()
          
          } else { 
            
            values$scamResults <- rbind(get.scam(values$searched[!index]), values$scamResults) 
            values$scamAddresses <- c(values$searched[!index], values$scamAddresses)
            

            if(is.null(values$scamResults)) {
              
              hideTab(inputId = "nav",
                      target = "scamDT")
              
              output$scamtext <- renderText("None of the addresses have been reported for scam.")      
           
              showTab(inputId = "nav",
                      target = "scamnull",
                      select = TRUE)
              
              } else {
              
                hideTab(inputId = "nav",
                        target = "scamnull")
                  
                output$scamresultDT <- renderDT(DT::datatable(values$scamResults))
                
                output$scam <- renderUI(DTOutput("scamresultDT"))
                
                showTab(inputId = "nav",
                        target = "scamDT",
                        select = TRUE)
                  
              }    
          }
        }
      },
      warning = function(w) {
        showNotification(
        ui = paste("You have already requested the scam reports for these addresses"),
        type = "warning")
      },
      message = function(e) {
        showNotification(
          ui = paste("Please start a New Search first"),
          type = "message")
      })
    
    })
  
  
  
  observeEvent(input$getgraph, {
    
    values$graph <- graphD3(df = values$transactions, 
                            addresses = values$allAddresses)
    
    output$d3 <- renderForceNetwork(values$graph)
    
    showTab(inputId = "nav",
            target = "Graph",
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
