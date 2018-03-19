FROM rocker/shiny

COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

RUN sudo chmod +x /usr/bin/shiny-server.sh 
