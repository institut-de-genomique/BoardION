dataSet <- reactive ({
	files <- paste(reportingFolder,"/",input$testRunList,"_globalstat.txt",sep="")
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

output$testMulti <- renderPlotly({
	if(nrow(dataSet())) {
		ggplotly(
			ggplot( dataSet(),
				aes( 	x = get("DURATION(mn)"),
					y = get("YIELD(b)"),
					col = FLOWCELL,
					group=1,
					text = paste(	FLOWCELL,
							'<br>DURATION (mn): ',get("DURATION(mn)"),
							'<br>YIELD: ',format(get("YIELD(b)"),big.mark=' '),
							sep=""
					)
				)
			) +
			geom_line() +
			xlab("DURATION(mn)") +
			ylab("YIELD(b)") +
			theme_bw(),
			
			dynamicTicks=T,
			tooltip = "text"
		)  %>% plotlyConfig()
	}
})

# update drop-down list of run
observe({
	listRun = runInfoStatReader()$FLOWCELL
	if(is.null(listRun)) {
		listRun <- character(0)
	}
	
	updateSelectizeInput( 
		session,
		"testRunList",
		choice = listRun,
		server=TRUE
	)
})
