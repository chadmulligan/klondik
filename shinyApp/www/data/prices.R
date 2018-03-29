library(RJSONIO)
library(rdrop2)
library(anytime)
library(dplyr)

load("/srv/shiny-server/www/data/prices.RData") 
token <- readRDS("/srv/shiny-server/www/data/token.rds") 

##get previous day data
last.date <- as.Date(df.prices$Date[1])

url <- paste0("https://api.coindesk.com/v1/bpi/historical/close.json?start=",
              last.date,
              "&end=",
              Sys.Date())

res <- fromJSON(url)

df.res <- data.frame(Date = names(res$bpi), 
                     Close.Price = res$bpi, 
                     stringsAsFactors = FALSE)
df.res %>% 
  arrange(desc(Date)) -> df.res

df.prices <- unique(rbind.data.frame(df.res, df.prices))

write.csv(df.prices, "/srv/shiny-server/www/data/prices.csv", row.names = FALSE) 
save(df.prices, file= "/srv/shiny-server/www/data/prices.RData")

##backup
drop_upload("prices.csv", path = "btc-prices", dtoken = token)
drop_upload("prices.RData", path = "btc-prices", dtoken = token)
