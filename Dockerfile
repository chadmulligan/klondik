FROM rocker/shiny

EXPOSE 3838

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["chmod", "+x", "/usr/bin/shiny-server.sh"]
