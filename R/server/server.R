# ______________________________________________________________________________________
# CONFIGURATIONS

reportingFolder = "/boardion_data"
#reportingFolder = "/home/abruno/dashboard_stats"
#reportingFolder = "/env/ig/atelier/nanopore/cns/PCT0004/promethion_dashboard/report_stats/"
#reportingFolder = "/env/cns/home/abruno/promethion/PCT0004/reporting/"

# unregular color gradient 
myColorGrandient = c("#CC3D3D","#FFDD32","#B3D84B","#50B7C4")
myColorStep      = c(0,        0.3,      0.7,      1        )

# ______________________________________________________________________________________
# FUNCTIONS

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

#renderPlotly <- function(p,dynamicTicks=TRUE, tooltip="text") {
#	ggplotly(p, dynamicTicks = dynamicTicks, tooltip = tooltip) %>% plotlyConfig()
#}

# ______________________________________________________________________________________
# MAIN SERVER

server <- function(input, output, session) {
	source("server/sideBar.R",local=TRUE)   # local=TRUE allow source file to use input, output and session arguments
	source("server/tabGlobal.R",local=TRUE)
	source("server/tabRun.R",local=TRUE)
	source("server/tabComparison.R",local=TRUE)
	source("server/plotChannel.R",local=TRUE)
	source("server/tabRunInProgress.R",local=TRUE)
}
