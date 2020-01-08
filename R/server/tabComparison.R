compCumul <- reactive ({
	files <- paste(reportingFolder,"/", input$tabComp_runList, "_globalstat.txt", sep="")
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

compCurrent <- reactive ({
	files <- paste(reportingFolder,"/", input$tabComp_runList, "_currentstat.txt", sep="")
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

compReadLength <- reactive ({
	datas <- data.frame()

	for(f in input$tabComp_runList) {

		file <- paste(reportingFolder,"/", f, "_readsLength.txt", sep="")
		data = readCsvSpace(file)
		data[,FLOWCELL:=f]
		datas = rbind( datas, data)
	}
	return(datas)
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
	geom_line(size=0.5) +
	xlab("DURATION(mn)") +
	ylab(input$tc_yc) +
	theme_bw()
}

plotCompReadLength <- function(x) {
	
	ggplot( x(),
	       aes( x = LENGTH,
		    weight = LENGTH * COUNT,
		    col = FLOWCELL#,
#		    text = paste( FLOWCELL,
#				  '<br>Length: ', LENGTH,
#				  '<br>Number of reads: ', format(COUNT,big.mark=' '),
#				  '<br>Number of bases: ', format(LENGTH * COUNT,big.mark=' '),
#				  sep=""
#		    )
	       )
	) +
	geom_freqpoly(size=0.5, binwidth=200) +
	xlab("Length") +
	ylab("Number of bases") +
	theme_bw()
}

# ______________________________________________________________________________________
# RENDER PLOT

output$tabComp_cumul_plot <- renderPlotly({
	if(nrow(compCumul())) {
		ggplotly( plotCompTime(compCumul), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
	}
})

output$tabComp_current_plot <- renderPlotly({
	if(nrow(compCurrent())) {
		ggplotly( plotCompTime(compCurrent), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
	}
})

output$tabComp_length_plot <- renderPlotly({
	if(nrow(compReadLength())) {
		ggplotly( plotCompReadLength(compReadLength), dynamicTicks=T )  %>% plotlyConfig()
	}
})

# ______________________________________________________________________________________
# RENDER OTHERS

observe({ # update drop-down list of run

	#print(runList())

	updateSelectizeInput( 
		session,
		"tabComp_runList",
		choice = runList(),
		selected = isolate(input$compRunList),
		server=TRUE
	)
})


output$tabComp_cumul_yAxeChoice <- renderUI({
	req(nrow(compCumul()) > 0)
	columnNames = vectRemove( colnames(compCumul()), c("FLOWCELL","DURATION(mn)") )
  
	selectInput(
		"tc_yc",
		"Y axe",
		columnNames,
		selected="YIELD(b)"
	)
})
