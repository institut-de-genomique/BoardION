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

# if user didn't give ip adress, try get it from system
if(length(args) == 2) {
	ip = system("hostname -i", intern=TRUE)
	port = as.integer(args[1])
	reportingFolder = args[2]
} else if(length(args) == 3) {
	ip = args[1]
	port = as.integer(args[2])
	reportingFolder = args[3]
} else {
	stop("[boardion] need 3 arguments: ip adress, port and input directory.\n It can also take only port and input directory, and it will try to get ip with 'hostname -i'.")
}

# ______________________________________________________________________________________
# VARIABLES

# Unregular color gradient
myColorGrandient = c("#CC3D3D","#FFDD32","#B3D84B","#50B7C4")
myColorStep      = c(0,        0.3,      0.7,      1        )

# refresh time of file reader in miliseconds
fileRefresh = 1000

# files name
runInfo_name    = "run_infostat.txt"
cumulative_name = "_globalstat.txt"
current_name    = "_currentstat.txt"
length_name     = "_readsLength.txt"
qot_name        = "_quality_stat.txt"
channel_name    = "_channel_stat.txt"

# ______________________________________________________________________________________
# FUNCTIONS

# format number
formatNumber <- function(x, d=2) {
	return( format( x, nsmall = d, digits = d, scientific = FALSE, big.mark= ' ', drop0trailing = TRUE ))
}

# Delete elemtents from vector
vectRemove <- function( v, toRemove) {
	return(v[ !v %in% toRemove ])
}

# Delete columns from a data.table
removeDTCol <- function( dt, columns) {
	dt[, (columns):=NULL]
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

isPromethionRun <- function( runID ) {
	if( startsWith( runID, "P" )) {
		return(TRUE)
	}
	return(FALSE)
}

getRunInfoStatFilePath <- function() {
	return( paste(reportingFolder,"/",runInfo_name, sep=""))
}

# get the files name of run with run ID
getRunCumulativeFilePath <- function(runId) {
	return( paste(reportingFolder,"/",runId,cumulative_name, sep=""))
}
getRunCurrentFilePath <- function(runId) {
	return( paste(reportingFolder,"/",runId,current_name, sep=""))
}
getRunLengthFilePath <- function(runId) {
	return( paste(reportingFolder,"/",runId,length_name, sep=""))
}
getRunQotFilePath <- function(runId) {
	return( paste(reportingFolder,"/",runId,qot_name, sep=""))
}
getRunChannelFilePath <- function(runId) {
	return( paste(reportingFolder,"/",runId,channel_name, sep=""))
}

# generete a reactive file reader from a file path
makeReactiveFileReader <- function(filePath, fun=readCsvSpace) {
	return(
		reactiveFileReader(
			intervalMillis = fileRefresh,
			session        = NULL,
			filePath       = filePath,
			readFunc       = fun 
		)
	)
}


# ______________________________________________________________________________________
# FRONTEND
source("ui/ui.R")

# ______________________________________________________________________________________
# BACKEND
source("server/server.R", local=TRUE)

# ______________________________________________________________________________________
# LAUNCH APP
shinyApp(ui, server,options=list(port=port,host=ip))
