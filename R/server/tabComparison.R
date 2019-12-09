dataSet <- reactive ({
	files <- paste(reportingFolder,"/", input$compRunList, "_globalstat.txt", sep="")
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

# ______________________________________________________________________________________
# PLOTS

plotCompTime <- function() {
	
	ggplot( dataSet(),
		aes(	x = get("DURATION(mn)"),
			y = get(input$tc_yc),
			col = FLOWCELL,
			group=1,
			text = paste(	FLOWCELL,
					'<br>DURATION (mn): ',get("DURATION(mn)"),
					'<br>',input$tc_yc,': ',format(get(input$tc_yc),big.mark=' '),
					sep=""
			)
		)
	) +
	geom_line() +
	xlab("DURATION(mn)") +
	ylab(input$tc_yc) +
	theme_bw()
}

# ______________________________________________________________________________________
# RENDER PLOT

output$plot_runCompTime <- renderPlotly({
	if(nrow(dataSet())) {
		ggplotly( plotCompTime(), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
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
		"compRunList",
		choice = listRun,
		server=TRUE
	)
})


output$tabComp_yAxeChoice <- renderUI({
        req(nrow(dataSet()) > 0)
        selectInput(
                "tc_yc",
                "Y axe",
                colnames(isolate(dataSet())),
                selected="YIELD(b)"
        )
})

