# ______________________________________________________________________________________
# VAR
reactiveVal <- reactiveValues(nbRunIP=0)
plotPixelHeight = 110
# ______________________________________________________________________________________
# FILES READERS

coerceToFunc <- function(x) {
  force(x);
  if (is.function(x))
    return(x)
  else
    return(function() x)
}

reactiveMultiFileReader <- function(intervalMillis, session, filesPath, readFunc, ...) {
	filesPath <- coerceToFunc(filesPath)
	extraArgs <- list(...)

	reactivePoll(
		intervalMillis, session,
		function() {
			value = ""
			for(path in filesPath()) {
				info <- file.info(path)
				value = paste(value,path, info$mtime, info$size)
			}
			return(value)
		},
		function() {
			dt = data.table()
			for(path in filesPath()) {
				dt <- rbind(dt,do.call(readFunc, c(path, extraArgs)))
			}
			return(dt)
		}
	)
}

runIPGlobalStatReader <- reactive ({

	runsIP = runInfoStatReader()[ENDED=="NO",FLOWCELL]

	reactiveMultiFileReader(
		intervalMillis  = 60000,
		session	        = NULL,
		filesPath       = paste(reportingFolder,"/",runsIP,"_globalstat.txt",sep=""),
		readFunc        = readCsvSpace2
	)()
})

runIPNbReads <- reactive ({
	runsIP = runInfoStatReader()[ENDED=="NO",FLOWCELL]
	reactiveMultiFileReader(
		intervalMillis  = 60000,
		session         = NULL,
		filesPath       = paste(reportingFolder,"/",runsIP,"_readsLength.txt",sep=""),
		readFunc        = readCsvSpace2
	)()
})

# ______________________________________________________________________________________
# PLOT

plotRunIPYield <- function(x) {
	ggplot( x(),
		aes(x=get("DURATION(mn)"),
		    y=get("YIELD(b)"),
		    fill=QUALITY,
		    text=paste('DURATION (mn): ',get("DURATION(mn)"),
			       '<br>NB READS : ',format(get("YIELD(b)"), big.mark=' '),
			       '<br>QUALITY: ',QUALITY,
			       '<br>',FLOWCELL,
			       sep=""
			      )
		)
	) +
	geom_col(position="dodge", width = 10) +
	facet_grid(rows=vars(FLOWCELL)) +

	theme_bw() +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}


plotRunIPNbReads <- function(x) {
	ggplot( x(),
		aes(x=LENGTH,
		    weight=COUNT
		)
	) +
	geom_histogram(fill=bluePlotly,binwidth=1000) +
	facet_grid(rows=vars(FLOWCELL)) +

	theme_bw() +
	scale_x_continuous(expand=c(0,0),limits = c(0, 100000)) +
	scale_y_continuous(expand=c(0,0)) +
	xlab("Length(b)") +
	ylab("Read count")
}

# ______________________________________________________________________________________
# RENDER

output$runIPTable = DT::renderDataTable(
	runInfoStatReader()[ENDED=="NO"],
	options = list(searching = FALSE, paging=FALSE, server = FALSE)
)

output$plot_globalRunIPYield = renderPlotly({
	req(nrow(runIPGlobalStatReader()))
	req(reactiveVal$nbRunIP>0)
	ggplotly(plotRunIPYield(runIPGlobalStatReader), dynamicTicks = TRUE, tooltip = "text",height=reactiveVal$nbRunIP*plotPixelHeight) %>% plotlyConfig()
})

output$plot_globalRunIPNbReads = renderPlotly({
	req(nrow(runIPNbReads())>0)
	req(reactiveVal$nbRunIP>0)
	ggplotly(plotRunIPNbReads(runIPNbReads), dynamicTicks = TRUE, height=reactiveVal$nbRunIP*plotPixelHeight) %>% plotlyConfig()
})

observe({
	reactiveVal$nbRunIP = nrow(runInfoStatReader()[ENDED=="NO"])
})
