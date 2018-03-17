FROM rocker/shiny

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["chmod", "+x", "/usr/bin/shiny-server.sh"]
