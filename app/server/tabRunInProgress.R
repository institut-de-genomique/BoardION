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
		readFunc        = readCsvSpace
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
	geom_col( position="dodge", width = 10) +

	theme_bw() +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}


# ______________________________________________________________________________________
# RENDER

rip_lengthFileReader = reactiveValues() # list reactiveFileReader length file of each run displayed in the tab
rip_yieldFileReader  = reactiveValues() # list reactiveFileReader yield file of each run displayed in the tab
rip_runDisplayed     = reactiveValues() # trace for which run an ui output exist

# table listing all in progress runs
output$runIPTable = DT::renderDataTable({

	data = runInfoStatReader()[ENDED=="NO"]
	removeDTCol( data, c("N50(b)", "SPEED(b/mn)", "QUALITY"))
	runs <- data$FLOWCELL

	if( nrow( data ) > 0 ) {
		
		for( run in data$FLOWCELL ) {
			data[FLOWCELL == run, Sup30kb  := sum(rip_lengthFileReader[[run]]()[LENGTH>=30000,  COUNT]) ]
			data[FLOWCELL == run, Sup50kb  := sum(rip_lengthFileReader[[run]]()[LENGTH>=50000,  COUNT]) ]
			data[FLOWCELL == run, Sup100kb := sum(rip_lengthFileReader[[run]]()[LENGTH>=100000, COUNT]) ]
		}
	}
	return(data)
})


observeEvent( input$rip_cumulative_toggle, {

	ext = ""
	if(input$rip_cumulative_toggle) {
		for(flowcell in names(rip_runDisplayed)) {
			ext = "_globalstat.txt"
		}
	} else {
		for(flowcell in names(rip_runDisplayed)) {
			ext = "_currentstat.txt"
		}
	}
	for(flowcell in names(rip_runDisplayed)) {
		rip_yieldFileReader[[ flowcell ]] <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste(reportingFolder, "/", flowcell, ext, sep=""), readFunc = readCsvSpace)
	}
})

# Dynamically create box for each run in progress (RIP). If the number of RIP change, the ui update accordingly
observeEvent( ripList(), {

	for(flowcell in ripList()) {

		if( !flowcell %in% names(rip_runDisplayed) ) { # if the run insn't displayed yet
	
			local({
				fc <- flowcell

				rip_runDisplayed[[fc]] = TRUE
	
				# id of the ui element
				plotYieldID   <- paste("rip_yield_", fc, sep="")
				plotLengthID  <- paste("rip_length_", fc, sep="")
				valBoxN50     <- paste("rip_length_sup30_",fc,sep="")
				valBoxSpeed   <- paste("rip_length_sup50_",fc,sep="")
				valBoxQuality <- paste("rip_length_sup100_",fc,sep="")
				buttonGotoRun <- paste("rip_button_",fc,sep="") 
				containerID   <- paste("rip_container_",fc,sep="")

				# create dynamic reader and save it in reactiveValues
				if(input$rip_cumulative_toggle) {
					rip_yieldFileReader[[ fc ]]  <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", fc, "_globalstat.txt", sep=""), readFunc = readCsvSpace)
				} else {
					rip_yieldFileReader[[ fc ]]  <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", fc, "_currentstat.txt", sep=""), readFunc = readCsvSpace)
				}

				rip_lengthFileReader[[ fc ]] <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", fc, "_readsLength.txt", sep=""), readFunc = readCsvSpace)

				# create a box per run
				title_b = p( paste(fc,"   "),  actionButton(buttonGotoRun , "Go to Run", class = "btn-xs" ) )
				insertUI(
					selector = '#placeholder',
					where = "afterEnd",
					ui = tags$div( id = containerID,
						box( title = title_b, width = NULL, status = "primary", solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE,
							fluidRow(
								column(5, plotlyOutput(plotYieldID, height = 300) %>% withSpinner(type=6) ),
								column(5, plotlyOutput(plotLengthID, height = 300) %>% withSpinner(type=6) ),
								column(2, valueBoxOutput(valBoxN50, width=NULL), valueBoxOutput(valBoxSpeed, width=NULL), valueBoxOutput(valBoxQuality, width=NULL))
							)
						)
					)
				)

				# bar plot of the yield
				output[[plotYieldID]] <- renderPlotly({
					p <- ggplotly( plotRunIPYield(rip_yieldFileReader[[ fc ]]), dynamicTicks = TRUE, tooltip = "text")
					p %>% style(marker.colorbar.len = 1, traces = length(p$x$data))  %>% # make the height of the colorbar (legend on the side of the plot) equal to the height of the plot
					plotlyConfig()
				})

				# histogram of read length
				output[[plotLengthID]] <- renderPlotly({
					rip_lengthFileReader[[ fc ]] %>%
					plotReadLength() %>%
					ggplotly(dynamicTicks = TRUE) %>% # can't use dynamicTicks and make an initial zoom with layout
					#layout(xaxis = list(range = c(-1000, 105000))) %>%
					plotlyConfig()
				})

				# boxs with number some run stats
				output[[valBoxN50]] <- renderValueBox({
					valueBox( runInfoStatReader()[FLOWCELL==fc, "N50(b)"], "N50")
				})

				output[[valBoxSpeed]] <- renderValueBox({
					valueBox( runInfoStatReader()[FLOWCELL==fc, "SPEED(b/mn)"], "Speed (b/mn)")
				})

				output[[valBoxQuality]] <- renderValueBox({
					valueBox( runInfoStatReader()[FLOWCELL==fc, "QUALITY"], "Quality")
				})

				# Make the button in the box header display the corresponding run in tabRun
				observeEvent(input[[buttonGotoRun]], {
					updateSelectInput( session, "runList", selected = fc )
					updateTabsetPanel( session, "menu", selected = "run" )
					
				})
			})
		}
	}

	for(flowcell in names(rip_runDisplayed)) {

		# if a displayed run insn't a run in progress anymore (it's ended) remove it
		if(!flowcell %in% ripList()) {

			containerID <- paste("rip_container_",flowcell,sep="")
			selector = paste0("#", containerID)
			removeUI(selector)

			# remove a value from a reactiveValue ( reactiveVal$foo <- NULL don't work ) see https://github.com/rstudio/shiny/issues/2439
			.subset2(rip_runDisplayed,     "impl")$.values$remove(flowcell)
			.subset2(rip_yieldFileReader,  "impl")$.values$remove(flowcell)
			.subset2(rip_lengthFileReader, "impl")$.values$remove(flowcell)
		}
	}
})


