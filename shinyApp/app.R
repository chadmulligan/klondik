library(shiny)
library(shinyjs)
library(DT)
library(klondikBTC)
library(networkD3)
library(rdrop2)


source("global.R")


ui <- fluidPage(useShinyjs(),
                
  tags$style(appCSS),

  tags$head(tags$link(rel="shortcut icon", type = "image/png", href="favicon.png")),

  titlePanel(a(img(src = "mail.png"), href="http://klondik.io"),
             windowTitle = "bitcompliance - A Bitcoin Compliance Toolbox"), 

  extendShinyjs(script = "hideTabs.js"),
  
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

      withBusyIndicatorUI(actionButton(inputId = "getinfo",
                                       label = "New Search")),
      helpText("Prices in USD are based on daily closing price"),
      hr(),

      withBusyIndicatorUI(actionButton(inputId = "append",
                   label = "Add Search")),
      helpText("Append new address transactions to results"),
      hr(),
      
      actionButton(inputId = "summary",
                   label = "Transactions Summary"),
      helpText("Get the addresses history"),
      hr(),

      actionButton(inputId = "getcluster",
                   label = "Cluster"),
      helpText("Look for parent addresses from the results"),
      hr(),

      withBusyIndicatorUI(actionButton(inputId = "getscam",
                   label = "Scam Report")),
      helpText("Check whether the addresses were reported for scam"),
      hr(),

      actionButton(inputId = "getgraph",
                   label = "Graph Transactions"),

      uiOutput("DLGraph"),
      hr(),

      downloadButton(outputId = "downloadCSV",
                     label = "Download Transactions")

    ),


    mainPanel(

      width = 9,

      tabsetPanel(id = "nav",
                  type = "pills",
                  tabPanel("Transactions",
                           style = "overflow-y: auto; max-height: 800px",
                           DTOutput("transactions")),
                  
                  tabPanel("Summary", 
                           style = "overflow-y:auto; max-height: 800px",
                           br(tags$ul(tags$li(h4("First and last transactions for each address:")))),
                           div(style= 'width: 60%; margin-left: 100px', uiOutput("lastfirst")),
                           tags$br(), 
                           br(tags$ul(tags$li(h4("Number of transactions for each address:")))),
                           div(style= 'width: 60%; margin-left: 100px', uiOutput("totalTransacs")),
                           tags$br(), 
                           div(style= 'width: 40%; margin-left: 100px', uiOutput("inputoutput")),
                           tags$br(),
                           br(tags$ul(tags$li(h4("Largest Inputs/Outputs from the set of addresses:")))),
                           div(style= 'width: 80%; margin-left: 100px', uiOutput("transacs1000")),
                           tags$br(),
                           br(tags$ul(tags$li(h4("Largest transactions involving the set of addresses:")))),
                           div(style= 'width: 80%; margin-left: 100px', uiOutput("biggestTransacs")),
                           tags$br(),
                           tags$br()
                           ),
                  
                  tabPanel("Cluster",
                           style = "overflow-y:auto; max-height: 800px",
                           verbatimTextOutput("cluster"),
                           uiOutput("getclusterinfo")),
                  
                  tabPanel("Scam Report",
                           style = "overflow-y:auto; max-height: 800px",
                           value = "scamnull",
                           verbatimTextOutput(outputId = "scamtext")),
                  
                  tabPanel("Scam Report",
                           style = "overflow-y:auto; max-height: 800px",
                           value = "scamDT",
                           uiOutput("scam")),
                  
                  tabPanel("All Addresses",
                           style = "overflow-y: auto; max-height: 800px",
                           verbatimTextOutput("allAddresses")),
                  
                  tabPanel("Graph", forceNetworkOutput("d3", height = "800px")),
                  
                  tabPanel("About",
                           style = "overflow-y:auto; max-height: 800px",
                           includeMarkdown("www/About.md")
                           )
                  )
      )
  )
)


server <- function(input, output, session) {

  #session$onSessionEnded(stopApp)
  session$allowReconnect(TRUE)

  # tryCatch(
  #   {updatePrices()},
  #   error = function(e){
  #     showNotification(
  #       ui = paste0(e),
  #       type = "error")
  #   })

  # hideTab(inputId = "nav",
  #         target = "Cluster")
  # 
  # hideTab(inputId = "nav",
  #         target = "scamnull")
  # 
  # hideTab(inputId = "nav",
  #         target = "scamDT")
  # 
  # hideTab(inputId = "nav",
  #         target = "All Addresses")
  # 
  # hideTab(inputId = "nav",
  #         target = "Transactions")
  # 
  # hideTab(inputId = "nav",
  #         target = "Graph")

  values <- reactiveValues()

  values$countfiles <- 0


###OUTPUTS###
  observeEvent(input$getinfo, {

      tryCatch({

      if(isTruthy(input$address)) {

        withBusyIndicatorServer("getinfo", {
          values$transactions <- getBTC(input$address)
          values$allAddresses <- input$address
          values$searched <- input$address
          reset("address")
        })

        } else{

        if(!isTruthy(input$file1)){

          warning()

          } else {

            withBusyIndicatorServer("getinfo", {
              values$f <- c(unlist(read.csv(input$file1[values$countfiles+1, "datapath"],
                                            header = FALSE,
                                            stringsAsFactors = FALSE),
                            use.names = FALSE))

              values$transactions <- getBTC(values$f)
              values$allAddresses <- values$f
              values$searched <- values$f
  
              values$countfile <- values$countfile +1
              reset("file1")
            })

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



      # showTab(inputId = "nav",
      #         target = "Transactions",
      #         select = TRUE)
      #show(selector = '#nav li a[data-value="Transactions"]')
      js$showTabSelect("Transactions")

      output$allAddresses <- renderText({paste(values$allAddresses,
                                               collapse = "\n")})

      js$showTab("All Addresses")
      
      # showTab(inputId = "nav",
      #         target = "All Addresses",
      #         select = FALSE)

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
          #ui = "Please enter a valid BTC address.",
          ui = paste0(e),
          type = "error")}
      )
    
    
  })


  observeEvent(input$append, {

    tryCatch({

      withBusyIndicatorServer("append", {
        
        if (is.null(values$searched)) message() else{
        if (input$address %in% values$searched) warning() else{
          values$transactions <- distinct(rbind(getBTC(input$address), values$transactions))
          
          values$allAddresses <- unique(c(input$address, values$allAddresses))
          output$allAddresses <- renderText({paste(values$allAddresses,
                                                   collapse = "\n")})

          updateTabsetPanel(session,
                            inputId = "nav",
                            selected = "Transactions")

          # showTab(inputId = "nav",
          #         target = "All Addresses",
          #         select = FALSE)

          values$searched <- c(values$searched, input$address)
          }
          }
      })
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

  
  
  observeEvent(input$summary, {
    
    values$summary <- summaryTransacs(values$transactions, values$searched)
    
    
    ###Last and first transactions
    output$lastfirstDT <- renderDT(formatDate(DT::datatable(values$summary$lastfirstTransacs,
                                                            colnames = c("Address", "First Transaction", "Last Transaction"),
                                                            rownames = FALSE,
                                                            options = list(dom = 't')),
                                              columns = c("First", "Last"),
                                              method = "toUTCString")
                                   )
    
    output$lastfirst <- renderUI({DTOutput("lastfirstDT")})
    
    
    ###Total Transactions
    output$totalTransacsDT <- renderDT(formatCurrency(DT::datatable(values$summary$totalTransacs,
                                                                    colnames = c("Address", "Input/Output", "Nb of Transactions",
                                                                                 "Total BTC", "Total USD"),
                                                                    options = list(dom = 't',
                                                                                   columnDefs = list(list(className = 'dt-center', targets = 1:2))),
                                                                    rownames = FALSE),
                                                      columns = "totalUSD")
                                       )
    
    output$totalTransacs <- renderUI({DTOutput("totalTransacsDT")})
    
    
    ###Summary input/output
    output$inputoutputDT <- renderDT(DT::datatable(values$summary$summaryInputOutput,
                                                   colnames = c("Nb of Transactions", "Total BTC", "Total USD"),
                                                   options = list(dom = 't',
                                                                  columnDefs = list(list(className = 'dt-center', targets = 1)))) %>% 
                                       formatCurrency(columns = "TotalUSD")
                                     )

    output$inputoutput <- renderUI({DTOutput("inputoutputDT")})
    
    
    ###Individual transactions > $1000
    output$transacs1000DT <- renderDT(DT::datatable(values$summary$transacs1000,
                                                    colnames = c("Address", "Transaction Hash",
                                                                 "Input/Output", "Time UTC",
                                                                 "Total BTC", "Total USD"),
                                                    options = list(dom = 'rtpl',
                                                                   columnDefs = list(list(targets = 1,
                                                                                          render = JS("function(data, type, row, meta) {","return type === 'display' && data.length > 30 ?","'<span title=\"' + data + '\">' + data.substr(0, 20) + '...</span>' : data;","}")),
                                                                                     list(className = 'dt-center', targets = 2))),
                                                    rownames = FALSE) %>%
                                        formatCurrency("totalUSD") %>%
                                        formatDate(columns = "TimeUTC", method = "toUTCString"))
    
    output$transacs1000 <- renderUI({DTOutput("transacs1000DT")})
    
    
    ###Biggest transactions
    output$biggestTransacsDT <- renderDT(DT::datatable(values$summary$biggestTransacs,
                                                       colnames = c("Transaction Hash",
                                                                    "Time UTC", "Total BTC", "Total USD"),
                                                       options = list(dom = 'rtpl'),
                                                       rownames = FALSE) %>%
                                           formatCurrency("totalUSD") %>%
                                           formatDate(columns = "TimeUTC", method = "toUTCString"))
    
    output$biggestTransacs <- renderUI({DTOutput("biggestTransacsDT")})
    
    
    ###Show tab
    # showTab("nav", "Summary", select = TRUE)
    
    js$showTabSelect("Summary")
    
  })


  
  observeEvent(input$getcluster, {

    tryCatch({
      values$cluster <- cluster(values$transactions, values$allAddresses)

      values$allAddresses <- unique(c(values$allAddresses, values$cluster))

      output$cluster <- renderText({paste(values$cluster,
                                         collapse = "\n")})

      output$allAddresses <- renderText({paste(values$allAddresses,
                                              collapse = "\n")})

      # showTab(inputId = "nav",
      #         target = "Cluster",
      #         select = TRUE)
      
      js$showTabSelect("Cluster")

      # showTab(inputId = "nav",
      #         target = "All Addresses",
      #         select = FALSE)

      output$getclusterinfo <- renderUI({
        withBusyIndicatorUI(
          actionButton(inputId = "clusterinfobutton",
                          label = "Get new transactions"),
          src_loader= "loader-blue.gif"
        )
        })

    },
    error = function(err){
      showNotification(
        ui = paste("No parent address found"),
        type = "message")
    })

  })



  observeEvent(input$clusterinfobutton, {

    withBusyIndicatorServer("clusterinfobutton", 
                            
                            {values$transactions <- distinct(rbind(getBTC(values$cluster), values$transactions))
                            values$searched <- c(values$searched, values$cluster)
                            values$cluster <- c()
                            })

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

            withBusyIndicatorServer("getscam", {
              values$scamResults <- rbind(get.scam(values$searched[!index]), values$scamResults)
              values$scamAddresses <- c(values$searched[!index], values$scamAddresses)
  
  
              if(is.null(values$scamResults)) {
  
                # hideTab(inputId = "nav",
                #         target = "scamDT")
                js$hideTab("scamDT")
  
                output$scamtext <- renderText("None of the addresses have been reported for scam.")
  
                # showTab(inputId = "nav",
                #         target = "scamnull",
                #         select = TRUE)
                js$showTabSelect("scamnull")
  
                } else {
  
                  # hideTab(inputId = "nav",
                  #         target = "scamnull")
                  
                  js$hideTab("scamnull")
  
                  output$scamresultDT <- renderDT(DT::datatable(values$scamResults))
  
                  output$scam <- renderUI(DTOutput("scamresultDT"))
  
                  # showTab(inputId = "nav",
                  #         target = "scamDT",
                  #         select = TRUE)
                  
                  js$showTabSelect("scamDT")

                }
            })
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

    tryCatch({
      values$graph <- graphD3(df = values$transactions,
                              addresses = values$allAddresses)

      output$d3 <- renderForceNetwork(values$graph)

      # showTab(inputId = "nav",
      #         target = "Graph",
      #         select = TRUE)
      
      js$showTabSelect("Graph")


      output$DLGraph <- renderUI({
        tags$br(
          downloadButton(outputId = "downloadgraph",
                       label = "Download Graph")
          )
        })
      },
      warning = function(w) {
        showNotification(
          ui = paste("Please start a New Search first."),
          type = "warning")
      }
    )
  })



  output$downloadgraph <-  downloadHandler(
    filename = function() {
      paste(paste(values$searched[[1]]), ".html", sep = "")
    },
    content = function(file) {
      saveNetwork(values$graph,
                  file = file,
                  selfcontained = TRUE)}
    )



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
