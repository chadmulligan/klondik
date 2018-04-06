###UPDATING THE PRICES DF### DEPRECATED ####
# updatePrices <- function()  {
#
#   lastmodif <- format(file.info("/srv/shiny-server/www/data/prices.RData")$mtime,
#                       format = "%Y-%m-%d")
#   if(lastmodif != Sys.Date()) {
#   token = readRDS("/srv/shiny-server/www/data/token.rds")
#   drop_download(path = "btc-prices/prices.RData",
#                 local_path = "/srv/shiny-server/www/data",
#                 overwrite = TRUE,
#                 dtoken = token)
#   }
# }


###withBusyIndicators script
source("helpers.R")

###LOAD###
#load("/srv/shiny-server/www/data/prices.RData")
load("www/data/prices.RData")

##overpass tibble printing only first 10 elements
options(tibble.print_max = Inf)
options(tibble.width = Inf)
options(dplyr.print_min = Inf)

apikey <- "c6b6a8d1-ec54-442f-9816-85b7dd1db06d"
