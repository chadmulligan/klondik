

###UPDATING THE PRICES DF###
updatePrices <- function()  {
  
  lastmodif <- format(file.info("www/data/prices.RData")$mtime,
                      format = "%Y-%m-%d")
  if(lastmodif != Sys.Date()) {
  token = readRDS("www/data/token.rds")
  drop_download(path = "btc-prices/prices.Rdata",
                local_path = "www/data",
                overwrite = TRUE,
                dtoken = token)
  }
}


###LOAD###
load("www/data/prices.RData") 
#load("/srv/shiny-server/www/data/prices.RData") 

apikey <- "c6b6a8d1-ec54-442f-9816-85b7dd1db06d"