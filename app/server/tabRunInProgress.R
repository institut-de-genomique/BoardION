# ______________________________________________________________________________________
# Functions

getCumulativeName <- function(runId) {
	return(paste(runId,"_globalstat.txt",sep=""))
}

getCurrentName <- function(runId) {
	return(paste(runId,"_currentstat.txt",sep=""))
}


# ______________________________________________________________________________________
# Reactive 

rip_lengthFileReader  = reactiveValues() # list reactiveFileReader length file of each run displayed in the tab
rip_yieldFileReader   = reactiveValues() # list reactiveFileReader yield file of each run displayed in the tab
rip_runDisplayed      = reactiveValues() # trace for which run an ui output exist

# table listing all in progress runs
output$runIPTable = DT::renderDataTable({

	if( nrow( runInfoStatReader() ) > 0 ) {
		data = runInfoStatReader()[Ended=="NO"]
		removeDTCol( data, c("Date"))
		runs <- data$RunID

		for( run in data$RunID ) {
			if( !is.null( rip_lengthFileReader[[run]] )) {
				data[RunID == run, `>30kb`  := sum(rip_lengthFileReader[[run]]()[Length>=30000,  Count]) ]
				data[RunID == run, `>50kb`  := sum(rip_lengthFileReader[[run]]()[Length>=50000,  Count]) ]
				data[RunID == run, `>100kb` := sum(rip_lengthFileReader[[run]]()[Length>=100000, Count]) ]
			}
		}
	}
	return(data)
})

# ______________________________________________________________________________________
# RENDER


# Dynamically create box for each run in progress (RIP). If the number of RIP change, the ui update accordingly
observeEvent( ripList(), {
	for(flowcell in ripList()) {

		if( !flowcell %in% names(rip_runDisplayed) ) { # if the run insn't displayed yet
	
			local({
				fc <- flowcell
				rip_runDisplayed[[fc]] = TRUE

				yieldReaderName = getCurrentName(fc)
				if( input$rip_cumulative_toggle) {
					yieldReaderName = getCumulativeName(fc)
				}
	
				# id of the ui element
				plotYieldID   <- paste("rip_yield_",       fc, sep="")
				plotLengthID  <- paste("rip_length_",      fc, sep="")
				valBoxN50     <- paste("rip_box_n50_",     fc, sep="")
				valBoxSpeed   <- paste("rip_box_speed_",   fc, sep="")
				valBoxQuality <- paste("rip_box_quality_", fc, sep="")
				valBoxNbReads <- paste("rip_box_nbReads_", fc, sep="")
				valBoxYield   <- paste("rip_box_yield_",   fc, sep="")
				buttonGotoRun <- paste("rip_button_",      fc, sep="")
				containerID   <- paste("rip_container_",   fc, sep="")

				# create dynamic reader and save it in reactiveValues
				rip_yieldFileReader[[ getCumulativeName(fc) ]] <- reactiveFileReader(intervalMillis=fileRefresh, session=NULL, filePath=paste( reportingFolder,"/", getCumulativeName(fc), sep=""), readFunc=readCsvSpace)
				rip_yieldFileReader[[ getCurrentName(fc) ]]    <- reactiveFileReader(intervalMillis=fileRefresh, session=NULL, filePath=paste( reportingFolder,"/", getCurrentName(fc),    sep=""), readFunc=readCsvSpace)
				rip_lengthFileReader[[ fc ]] <- reactiveFileReader(intervalMillis = fileRefresh, session = NULL, filePath = paste( reportingFolder, "/", fc, "_readsLength.txt", sep=""), readFunc = readCsvSpace)

				# create a box per run
				title_b = p( actionButton(buttonGotoRun , fc) )
				insertUI(
					selector = '#placeholder',
					where = "afterEnd",
					ui = tags$div( id = containerID,
						box( title = title_b, width = NULL, status = "primary", solidHeader = TRUE, collapsible = TRUE, collapsed = FALSE,
							fluidRow(
								column(5, plotlyOutput(plotYieldID, height = 320) %>% withSpinner(type=6) ),
								column(5, plotlyOutput(plotLengthID, height = 320) %>% withSpinner(type=6) ),
								column(2, 
									tags$div(id="rip_box", # div to apply style to the following content (see ui.R)
									 	valueBoxOutput(valBoxYield,   width=NULL),
										valueBoxOutput(valBoxN50,     width=NULL),
										valueBoxOutput(valBoxSpeed,   width=NULL),
										valueBoxOutput(valBoxQuality, width=NULL),
										valueBoxOutput(valBoxNbReads, width=NULL)
									)
								)
							)
						)
					)
				)

				# bar plot of the yield
				output[[plotYieldID]] <- renderPlotly({
					p <- ggplotly( plotRunNbBase(rip_yieldFileReader[[ yieldReaderName ]]()), dynamicTicks = TRUE, tooltip = "text")
					p %>% style(marker.colorbar.len = 1, traces = length(p$x$data))  %>% # make the height of the colorbar (legend on the side of the plot) equal to the height of the plot
					plotlyConfig()
				})

				# histogram of read length
				output[[plotLengthID]] <- renderPlotly({
					rip_lengthFileReader[[ fc ]]() %>%
					plotReadLength() %>%
					ggplotly(dynamicTicks = TRUE) %>% # can't use dynamicTicks and make an initial zoom with layout
					#layout(xaxis = list(range = c(-1000, 105000))) %>%
					plotlyConfig()
				})

				# boxs with number some run stats
				output[[valBoxN50]] <- renderValueBox({
					valueBox( formatNumber( runInfoStatReader()[RunID==fc, "N50(b)"]) , "N50")
				})

				# for speed we display the value of the last non cumulative step
				output[[valBoxSpeed]] <- renderValueBox({ 
					valueBox( formatNumber( tail( rip_yieldFileReader[[ getCurrentName(fc) ]](), 1)$`Speed(b/mn)` ) , "Speed (b/mn)")
				})

				output[[valBoxQuality]] <- renderValueBox({
					valueBox( formatNumber( runInfoStatReader()[RunID==fc, "Quality"]) , "Quality")
				})

				output[[valBoxYield]] <- renderValueBox({
					valueBox( formatNumber( runInfoStatReader()[RunID==fc, "Yield(b)"] / 1e9) , "Yield(Gb)")
				})

				output[[valBoxNbReads]] <- renderValueBox({
					valueBox( formatNumber( runInfoStatReader()[RunID==fc, "#Reads"]) , "Reads")
				})

				# Make the button in the box header display the corresponding run in tabRun
				observeEvent(input[[buttonGotoRun]], {
					if(input[[buttonGotoRun]] > 0) {
						updateSelectInput( session, "runList", selected = fc )
						updateTabsetPanel( session, "menu", selected = "run" )
					}
					
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


