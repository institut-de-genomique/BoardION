compCumul <- reactive ({
	files <- getRunCumulativeFilePath(input$tabComp_runList)
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

compCurrent <- reactive ({
	files <- getRunCurrentFilePath(input$tabComp_runList)
	data<-data.frame()

	for(f in files) {
		data = rbind(data,readCsvSpace(f))
	}
	return(data)
})

compReadLength <- reactive ({
	datas <- data.frame()

	for(f in input$tabComp_runList) {

		file <- getRunLengthFilePath(f)
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

plotCompTime <- function(x, y_axe) {
	
	ggplot( x(),
		aes(	x = get("Duration(mn)"),
			y = get(y_axe),
			col = RunID,
			group=1,
			text = paste(	RunID,
					'<br>Duration (mn): ',formatNumber(get("Duration(mn)")),
					'<br>',y_axe,': ',formatNumber(get(y_axe)),
					sep=""
			)
		)
	) +
	geom_line(size=0.5) +
	xlab("Duration (mn)") +
	ylab(y_axe) +
	theme_bw()
}

plotCompReadLength <- function(x, mode, doPercent) {

	if(mode == "Number of base") {
		if(doPercent) {
			mapping = aes(x = Length, weight = PercentBase, col = RunID)
			y_name = "Percent of base number"
		} else {
			mapping = aes(x = Length, weight = NbBase, col = RunID)
			y_name = "Number of base"
		}
	} else {
		if(doPercent) {
			mapping = aes(x = Length, weight = PercentRead, col = RunID)
			y_name = "Percent of read number"
		} else {
			mapping = aes(x = Length, weight = Count, col = RunID)
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
	input$ab_owr_refreshComp
	input$ab_owr_refreshCompTime
	isolate({
		req(nrow(compCumul())>0)
		if( input$ab_owr_refreshComp == 0 && input$ab_owr_refreshCompTime == 0 ){
			yAxe = "Yield(b)"
		} else {
			req( !is.null(input$tc_yc))
			yAxe = input$tc_yc
		}
		g <- ggplotly( plotCompTime(compCumul, yAxe), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
	})
	return(g)
})

output$tabComp_current_plot <- renderPlotly({
	input$ab_owr_refreshComp
	input$ab_owr_refreshCompTime
	isolate({
		req(nrow(compCurrent())>0)
		if( input$ab_owr_refreshComp == 0 && input$ab_owr_refreshCompTime == 0 ){
			yAxe = "Yield(b)"
		} else {
			req( !is.null(input$tc_yc))
			yAxe = input$tc_yc
		}
		g <- ggplotly( plotCompTime(compCurrent, yAxe), dynamicTicks=T, tooltip = "text" )  %>% plotlyConfig()
	})
	return(g)
})

output$tabComp_length_plot <- renderPlotly({
	input$ab_owr_refreshComp
	input$ab_owr_refreshCompLength
	isolate({
		req(nrow(compReadLength())>0)
		req( !is.null(input$tabComp_length_dropdown))
		req( !is.null(input$tabComp_length_checkBox))
		g <- ggplotly( plotCompReadLength(compReadLength, input$tabComp_length_dropdown, input$tabComp_length_checkBox), dynamicTicks=T )  %>% plotlyConfig()
	})
	return(g)
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

# update drop-down list of run
observe({

	runSelected = isolate(input$tabComp_runList)
	runFinished = runList()[!runList() %in% ripList()]

	# if there isn't a run selected, select run in progress or the most recent one
	if (runSelected == "" || is.null(runSelected)) {
		if(length(ripList()) > 0) {
			runSelected = ripList()
		} else {
			runSelected = runInfoStatReader()[StartTime==max(na.omit(StartTime)),RunID]
		}
	}

	listRun <- list()
	
	if(length(runFinished) == 0 && length(ripList()) == 0) {
		listRun <- character(0)
		runSelected = NULL

	} else if(length(ripList()) == 0) {
		listRun = list( "Completed" = list(runList()) )

	} else if(length(runFinished) == 0) {
		listRun = list( "In progress" = list(ripList()) )

	} else {
		listRun = list(
			"In progress" = list(ripList()),
			"Completed" = list(runList()[!runList() %in% ripList()])
		)
	}

	updateSelectizeInput( 
		session,
		"tabComp_runList",
		choice = listRun,
		selected = runSelected,
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
