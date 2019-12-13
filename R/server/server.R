# ______________________________________________________________________________________
# CONFIGURATIONS

#reportingFolder = "/data/boardION_stats/"
reportingFolder = "/test_data"
#reportingFolder = "/home/abruno/dashboard_stats"
#reportingFolder = "/env/ig/atelier/nanopore/cns/PCT0004/promethion_dashboard/report_stats/"
#reportingFolder = "/env/cns/home/abruno/promethion/PCT0004/reporting/"

# ______________________________________________________________________________________
# MAIN SERVER

server <- function(input, output, session) {
	source("server/tabGlobal.R",local=TRUE)
	source("server/tabRun.R",local=TRUE)
	source("server/tabComparison.R",local=TRUE)
	source("server/plotChannel.R",local=TRUE)
	source("server/tabRunInProgress.R",local=TRUE)
}
