
library(shiny)
# library(data.table)

PATH <- "/srv/shiny-server/"
LOGPATH = paste0(PATH, "DATA")

LOGFILE = "CPU.txt"

conn = "ESTABLISHED"
# conn = "VERBUNDEN"

servername = ""
