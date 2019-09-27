library(ggplot2)
library(plotly)
library(shiny)
library(shinydashboard)
library(data.table)
library(readr)
library(shinycssloaders)
library(DT)

require(bit64)

## FRONTEND
source("ui/ui.R")

## BACKEND
source("server/server.R")

shinyApp(ui, server,options=list(port=80,host="172.17.0.2"))
#shinyApp(ui, server,options=list(port=80,host="172.25.123.149"))
#shinyApp(ui, server,options=list(port=3140,host="195.83.222.110"))	# etna48
#shinyApp(ui, server,options=list(port=3140,host="195.83.222.111"))	# etna49
