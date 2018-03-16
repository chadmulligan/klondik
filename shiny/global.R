

###UPDATING THE PRICES DF###
updatePrices <- function()  {
  
  lastmodif <- format(file.info("data/prices.RData")$mtime,
                      format = "%Y-%m-%d")
  if(lastmodif != Sys.Date()) {
  token = readRDS("data/token.RDS")
  drop_download(path = "btc-prices/prices.Rdata",
                local_path = "data/",
                overwrite = TRUE,
                dtoken = token)
  }
}


###LOAD###
load("data/prices.RData")

test <- function(){3*4}

