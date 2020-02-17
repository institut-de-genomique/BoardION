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
	
		data[,NB_BASE:=COUNT*LENGTH]
		data[,PERCENT_READ:=COUNT/sum(COUNT)*100]
		data[,PERCENT_BASE:=NB_BASE/sum(NB_BASE)*100]

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

	if(input$tabComp_length_dropdown == "Number of base") {
		if(input$tabComp_length_checkBox) {
			mapping = aes(x = LENGTH, weight = PERCENT_BASE, col = FLOWCELL)
			#y_var = PERCENT_BASE
			y_name = "Percent of base number"
		} else {
			mapping = aes(x = LENGTH, weight = NB_BASE, col = FLOWCELL)
			#y_var = NB_BASE
			y_name = "Number of base"
		}
	} else {
		if(input$tabComp_length_checkBox) {
			mapping = aes(x = LENGTH, weight = PERCENT_READ, col = FLOWCELL)
			#y_var = PERCENT_READ
			y_name = "Percent of read number"
		} else {
			mapping = aes(x = LENGTH, weight = COUNT, col = FLOWCELL)
			#y_var = COUNT
			y_name = "Number of read"
		}
	}

	ggplot( x(),
		mapping
	) +
	ylab(y_name) +
	geom_freqpoly(size=0.5, binwidth=200) +
	xlab("Length") +
	theme_bw()
}

# ______________________________________________________________________________________
# RENDER PLOT

output$tabComp_cumul_plot <- renderPlotly({
	req(nrow(compCumul()>0))
	ggplotly( plotCompTime(compCumul), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
})

output$tabComp_current_plot <- renderPlotly({
	req(nrow(compCurrent()>0))
	ggplotly( plotCompTime(compCurrent), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
})

output$tabComp_length_plot <- renderPlotly({
	req(nrow(compReadLength()>0))
	ggplotly( plotCompReadLength(compReadLength), dynamicTicks=T )  %>% plotlyConfig()
})

# ______________________________________________________________________________________
# RENDER OTHERS

observe({ # update drop-down list of run

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
