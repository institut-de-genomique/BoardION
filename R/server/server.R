# ______________________________________________________________________________________
# CONFIGURATIONS

reportingFolder = "/test_data"
#reportingFolder = "/home/abruno/dashboard_stats"
#reportingFolder = "/env/ig/atelier/nanopore/cns/PCT0004/promethion_dashboard/report_stats/"
#reportingFolder = "/env/cns/home/abruno/promethion/PCT0004/reporting/"

# ______________________________________________________________________________________
# FUNCTIONS

# Read space delimited file
# readCsvSpace <- function(file) {
	# data = data.table()
	# if(file.exists(file)) {
		# data = fread(file,header=T,sep=" ",integer64="double",check.names=T)
	# }
	# return(data)
# }

readCsvSpace2 <- function(file) {
	data = data.table()
	if(file.exists(file)) {
		data = fread(file,header=T,sep=" ",integer64="double",check.names=F)
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
# MAIN SERVER

server <- function(input, output, session) {
	source("server/sideBar.R",local=TRUE)   # local=TRUE allow source file to use 
	source("server/tabGlobal.R",local=TRUE) # input, output and session arguments
	source("server/tabRun.R",local=TRUE)
	source("server/tabComparison.R",local=TRUE)
	source("server/plotChannel.R",local=TRUE)
	source("server/tabRunInProgress.R",local=TRUE)
}
