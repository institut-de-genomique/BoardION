# ______________________________________________________________________________________
# MAIN SERVER

server <- function(input, output, session) {
  
  # ______________________________________________________________________________________
  # run info stat reader
  
  readRunInfoStat <- function(file) {
    data = readCsvSpace(file)

    if(nrow(data)>0) {
      data[, c("LastReadPosition","LastStepStartPosition"):=NULL]
      data[,Date:=as.Date(StartTime)]
    }
  }
  
  runInfoStatReader <- makeReactiveFileReader( getRunInfoStatFilePath(), readRunInfoStat)
  
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
    isolate(runInfoStatReader()[Ended=="NO",RunID])
  })
  
  runList <- reactive({
    rv$updateRunList
    isolate(runInfoStatReader()[,RunID])
  })
  
  # update list of run and list of run in progress only if the corresponding list in the input file (runInfoStatReader) change
  # and not if any value of this file change (like the numbre of read)
  observe ({
    if(length(runInfoStatReader()[,RunID]) != length(isolate(runList())) || all(runInfoStatReader()[,RunID] != isolate(runList()))) {
      isolate({
        rv$updateRunList <- TRUE
        rv$updateRunList <- FALSE
      })
    }
    
    if(length(runInfoStatReader()[Ended=="NO",RunID]) != length(isolate(ripList())) || all(runInfoStatReader()[Ended=="NO",RunID] != isolate(ripList()))) {
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
