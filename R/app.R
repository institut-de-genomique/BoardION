library(ggplot2)
library(plotly)

library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)

library(data.table)
library(readr)
library(DT)

require(bit64)

options(shiny.reactlog = TRUE)

# ______________________________________________________________________________________
# Unregular color gradient
myColorGrandient = c("#CC3D3D","#FFDD32","#B3D84B","#50B7C4")
myColorStep      = c(0,        0.3,      0.7,      1        )


# ______________________________________________________________________________________
# FUNCTIONS

# Delete elemtents from vector
vectRemove <- function( v, toRemove) {
	return(v[ !v %in% toRemove ])
}

# Read space delimited file
readCsvSpace <- function(file) {
	data = data.table()
	if(file.exists(file)) {
		data = fread(file, header=T, sep=" ", integer64="double", check.names=F)
	}
	return(data)
}


# Config of plotly added to each graph
plotlyConfig <- function(p) {
	config(p,
		# increase the resolution of saved images
		toImageButtonOptions = list(
			format = "png",
			width = 1600,
			height = 900
		)
	)
}

# ______________________________________________________________________________________
# FRONTEND
source("ui/ui.R")

# ______________________________________________________________________________________
# BACKEND
source("server/server.R")

shinyApp(ui, server,options=list(port=80,host="172.17.0.2"))
#shinyApp(ui, server,options=list(port=80,host="172.25.123.59"))
#shinyApp(ui, server,options=list(port=80,host="172.25.123.149"))
#shinyApp(ui, server,options=list(port=3140,host="195.83.222.110"))	# etna48
#shinyApp(ui, server,options=list(port=3140,host="195.83.222.111"))	# etna49
