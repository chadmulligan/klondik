

###UPDATING THE PRICES DF###
updatePrices <- function()  {
  
  lastmodif <- format(file.info("./www/data/prices.RData")$mtime,
                      format = "%Y-%m-%d")
  if(lastmodif != Sys.Date()) {
  token = readRDS("./www/data/token.RDS")
  drop_download(path = "btc-prices/prices.Rdata",
                local_path = "./www/data/",
                overwrite = TRUE,
                dtoken = token)
  }
}


###LOAD###
load("./www/data/prices.RData") 