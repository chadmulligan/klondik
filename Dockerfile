FROM rocker/shiny

RUN apt-get update && apt-get install -y \
    sudo \
    libxml2-dev\
    libssl-dev

RUN R -e "install.packages(c('devtools'), repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('chadmulligan/klondikbtc-pkg', auth_token = '69a85971ae5680d6e9d8c022d70f2402a8a1669e', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('shiny', 'rmarkdown', 'DT', 'shinyjs', 'rdrop2'), repos='http://cran.rstudio.com/')"

ADD shiny /srv/shiny-server/

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
