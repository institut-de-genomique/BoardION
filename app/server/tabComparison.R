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
		data[,RunID:=f]
	
		data[,NbBase:=Count*Length]
		data[,PercentRead:=Count/sum(Count)*100]
		data[,PercentBase:=NbBase/sum(NbBase)*100]

		datas = rbind( datas, data)
	}
	return(datas)
})

# ______________________________________________________________________________________
# PLOTS

plotCompTime <- function(x) {
	
	ggplot( x(),
		aes(	x = get("Duration(mn)"),
			y = get(input$tc_yc),
			col = RunID,
			group=1,
			text = paste(	RunID,
					'<br>Duration (mn): ',formatNumber(get("Duration(mn)")),
					'<br>',input$tc_yc,': ',formatNumber(get(input$tc_yc)),
					sep=""
			)
		)
	) +
	geom_line(size=0.5) +
	xlab("Duration(mn)") +
	ylab(input$tc_yc) +
	theme_bw()
}

plotCompReadLength <- function(x) {

	if(input$tabComp_length_dropdown == "Number of base") {
		if(input$tabComp_length_checkBox) {
			mapping = aes(x = Length, weight = PercentBase, col = RunID)
			#y_var = PercentBase
			y_name = "Percent of base number"
		} else {
			mapping = aes(x = Length, weight = NbBase, col = RunID)
			#y_var = NbBase
			y_name = "Number of base"
		}
	} else {
		if(input$tabComp_length_checkBox) {
			mapping = aes(x = Length, weight = PercentRead, col = RunID)
			#y_var = PercentRead
			y_name = "Percent of read number"
		} else {
			mapping = aes(x = Length, weight = Count, col = RunID)
			#y_var = Count
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
	req(nrow(compCumul())>0)
	req( !is.null(input$tc_yc))
	ggplotly( plotCompTime(compCumul), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
})

output$tabComp_current_plot <- renderPlotly({
	req(nrow(compCurrent())>0)
	req( !is.null(input$tc_yc))
	ggplotly( plotCompTime(compCurrent), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
})

output$tabComp_length_plot <- renderPlotly({
	req(nrow(compReadLength())>0)
	ggplotly( plotCompReadLength(compReadLength), dynamicTicks=T )  %>% plotlyConfig()
})

# ______________________________________________________________________________________
# RENDER OTHERS

output$ib_ow_nbRunInProgress <- renderInfoBox({
	req(nrow(runInfoStatReader())>0)
	nb_runInProgress = length(ripList())
	valueBox(
		nb_runInProgress,
		"Run in progress",
		icon = icon("cogs")
	)
})

output$ib_ow_nbRuns <- renderInfoBox({
	req(nrow(runInfoStatReader())>0)
	nb_runs = length(runList())
	valueBox(
		nb_runs,
		"Runs sequenced",
		icon = icon("check-circle")
	)
})

output$ib_ow_nbBases <- renderInfoBox({
	req(nrow(runInfoStatReader())>0)
	nb_bases = as.integer( sum(runInfoStatReader()[,get("Yield(b)")]) / 1e+09 )
	valueBox(
 		nb_bases,
		"GB sequenced",
		icon = icon("chart-line")
	)
})


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
	columnNames = vectRemove( colnames(compCumul()), c("RunID","Duration(mn)") )
  
	selectInput(
		"tc_yc",
		"Y axe",
		columnNames,
		selected="Yield(b)"
	)
})
