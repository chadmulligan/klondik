FROM rocker/shiny

RUN apt-get update && apt-get install -y \
    sudo \
    libxml2-dev\
    libssl-dev

RUN R -e "install.packages(c('devtools'), repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('chadmulligan/klondikBTC', auth_token = '09523424c6ce466ae5785d0e37abcb48e8a09b5c')"
RUN R -e "install.packages(c('shiny', 'rmarkdown', 'DT', 'shinyjs', 'rdrop2'), repos='http://cran.rstudio.com/')"

ADD shiny /srv/shiny-server/

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
