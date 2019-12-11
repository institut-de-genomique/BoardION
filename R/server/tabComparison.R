compCumul <- reactive ({
	files <- paste(reportingFolder,"/", input$compRunList, "_globalstat.txt", sep="")
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

compCurrent <- reactive ({
	files <- paste(reportingFolder,"/", input$compRunList, "_currentstat.txt", sep="")
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

# ______________________________________________________________________________________
# PLOTS

plotCompTime <- function(x) {
	
	ggplot( x(),
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
	geom_line(size=1) +
	xlab("DURATION(mn)") +
	ylab(input$tc_yc) +
	theme_bw()
}

# ______________________________________________________________________________________
# RENDER PLOT

output$plot_runCompTimeCumul <- renderPlotly({
	if(nrow(compCumul())) {
		ggplotly( plotCompTime(compCumul), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
	}
})

output$plot_runCompTimeCurrent <- renderPlotly({
	if(nrow(compCurrent())) {
		ggplotly( plotCompTime(compCurrent), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
	}
})

# ______________________________________________________________________________________
# RENDER OTHERS

observe({ # update drop-down list of run

	updateSelectizeInput( 
		session,
		"compRunList",
		choice = runList(),
		selected = isolate(input$compRunList),
		server=TRUE
	)
})


output$tabComp_yAxeChoice <- renderUI({
        req(nrow(compCumul()) > 0)

	columnNames = vectRemove( colnames(compCumul()), c("FLOWCELL","DURATION(mn)") )

        selectInput(
		"tc_yc",
		"Y axe",
		columnNames,
		selected="YIELD(b)"
        )
})

