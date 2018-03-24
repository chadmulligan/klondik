

###UPDATING THE PRICES DF###
updatePrices <- function()  {
  
  lastmodif <- format(file.info("~/srv/shiny-server/www/data/prices.RData")$mtime,
                      format = "%Y-%m-%d")
  if(lastmodif != Sys.Date()) {
  token = readRDS("~/srv/shiny-server/www/data/token.RDS")
  drop_download(path = "btc-prices/prices.Rdata",
                local_path = "~/srv/shiny-server/www/data/",
                overwrite = TRUE,
                dtoken = token)
  }
}


###LOAD###
load("~/srv/shiny-server/www/data/prices.RData") 