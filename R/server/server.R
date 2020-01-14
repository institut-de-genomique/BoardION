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
  
  # ______________________________________________________________________________________
  # run info stat reader
  
  readRunInfoStat <- function(file) {
    data = readCsvSpace(file)
    data[, c("LASTREADPOSITION","LASTSTEPSTARTPOSITION"):=NULL]
    data[,DATE:=as.Date(STARTTIME)]
  }
  
  runInfoStatReader<-reactiveFileReader(
    intervalMillis = 6000,
    session        = NULL,
    filePath       = paste(reportingFolder,"/run_infostat.txt",sep=""),
    readFunc       = readRunInfoStat
  )
  
  # ______________________________________________________________________________________
  # RUN LISTS
  
  # flags to update the lists
  rv <- reactiveValues(
    updateRunList = FALSE,
    updateRipList = FALSE
  )
  
  # run in progress
  ripList <- reactive({
    rv$updateRipList
    isolate(runInfoStatReader()[ENDED=="NO",FLOWCELL])
  })
  
  runList <- reactive({
    rv$updateRunList
    isolate(runInfoStatReader()[,FLOWCELL])
  })
  
  # update list of run and list of run in progress only if the corresponding list in the input file (runInfoStatReader) change
  # and not if any value of this file change (like the numbre of read)
  observe ({
    if(length(runInfoStatReader()[,FLOWCELL]) != length(isolate(runList())) || all(runInfoStatReader()[,FLOWCELL] != isolate(runList()))) {
      isolate({
        rv$updateRunList <- TRUE
        rv$updateRunList <- FALSE
      })
    }
    
    if(length(runInfoStatReader()[ENDED=="NO",FLOWCELL]) != length(isolate(ripList())) || all(runInfoStatReader()[ENDED=="NO",FLOWCELL] != isolate(ripList()))) {
      isolate({
        rv$updateRipList <- TRUE
        rv$updateRipList <- FALSE
      })
    }
  })

  
  # ______________________________________________________________________________________
  # SOURCE
  
  # source("server/tabGlobal.R",local=TRUE)
	source("server/tabRun.R",local=TRUE)
	source("server/tabComparison.R",local=TRUE)
	source("server/plotChannel.R",local=TRUE)
	source("server/plotRuns.R",local=TRUE)
	source("server/tabRunInProgress.R",local=TRUE)
}
