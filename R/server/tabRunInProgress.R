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
				paste(value,path, info$mtime, info$size)
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
	scale_fill_gradientn(colors=rainbow(5),values=c(0,.5,.6,.7,1) ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}


# ______________________________________________________________________________________
# RENDER

output$runIPTable = renderTable(
	{runInfoStatReader()[ENDED=="NO"]},
	bordered = TRUE
)

output$plot_globalRunIPYield = renderPlotly({
	if(nrow(runIPGlobalStatReader())) {
		ggplotly(plotRunIPYield(runIPGlobalStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	}
})