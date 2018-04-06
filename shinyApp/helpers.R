# All the code in this file needs to be copied to your Shiny app, and you need
# to call `withBusyIndicatorUI()` and `withBusyIndicatorServer()` in your app.
# You can also include the `appCSS` in your UI, as the example app shows.

# =============================================

# Set up a button to have an animated loading indicator 
# for better user experience
# Need to use with the corresponding `withBusyIndicator` server function

withBusyIndicatorUI <- function(button, src_loader= "loader-white.gif") {
  id <- button[['attribs']][['id']]
  div(
    `data-for-btn` = id,
    button,
    span(
      class = "btn-loading-container",
      hidden(
        img(src = src_loader, class = "btn-loading-indicator")
      )
    )
  )
}

# Call this function from the server with the button id that is clicked and the
# expression to run when the button is clicked
withBusyIndicatorServer <- function(buttonId, expr) {
  # UX stuff: show the "busy" message, disable the button
  loadingEl <- sprintf("[data-for-btn=%s] .btn-loading-indicator", buttonId)
  shinyjs::disable(buttonId)
  shinyjs::show(selector = loadingEl)
  on.exit({
    shinyjs::enable(buttonId)
    shinyjs::hide(selector = loadingEl)
  })

  expr

}



appCSS <- "
.btn-loading-container {
margin-left: 10px;
font-size: 1.2em;
}
.shiny-text-output{
width: 30%;
margin-top:10px;
border-radius: 0px;
font-size: 14px; 
}
#cluster{
width: 23%; 
margin-left: 10px; 
text-align: center;
}
#allAddresses{
width: 23%;
margin-left: 10px;
text-align: center;
}
.well{
border-radius: 0px;
background-color: rgba(24, 72, 114, .8);
color: #ffffff;
}
#clusterinfobutton{
margin-left: 29px; 
border-color: rgba(24, 72, 114, .8);
border: 3px solid ;
}
.help-block{
color: #f5f5f5
}
.btn-default{
color: #184872;
font-weight: bold;
}
#transactions{
margin-top: 10px; 
}
.hr{
border: 1px solid #ffffff;
}
#wrapper {
overflow: hidden; 
}
#first {
float:left; 
}
#second {
float: left;
}
"
