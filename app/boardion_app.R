#!/usr/bin/env Rscript
#.libPaths(c( .libPaths(), "/data/R/x86_64-redhat-linux-gnu-library/3.6"))

require(bit64)
library(data.table)

library(ggplot2)
library(plotly)

library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(DT)

options(shiny.reactlog = TRUE)


# ______________________________________________________________________________________
# Command line arguments
args = commandArgs(trailingOnly=TRUE)

if(length(args) != 3) {
        stop("[boardion] need 3 arguments: ip adress, port and input directory.")
}

ip = args[1]
port = as.integer(args[2])
reportingFolder = args[3]



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

shinyApp(ui, server,options=list(port=port,host=ip))
