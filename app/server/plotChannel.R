# ______________________________________________________________________________________
# FILES READERS


channelStatReader <- reactive ({
	dt = makeReactiveFileReader( getRunChannelFilePath(input$runList) )()
	
	dt[,CumulativeLength:=Length*`#Reads`]
	return(dt)
})

# ______________________________________________________________________________________
# PLOTS

plotChannelStat <- function(x, colVar ) {
	ggplot(
		x,
		aes(x=xcoord,
		    y=ycoord,
		    fill=get(colVar),
		    text=paste("Channel: ",formatNumber(Channel),
			       "<br>", colVar,": ",formatNumber(get(colVar)),
			       sep=""
			      )
		)
	) +
	geom_tile() +
	facet_grid(~n,scales="free_x") +
	
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,NA), na.value="#E1E1E1") +
	scale_x_continuous(expand=c(0,0)) +
	scale_y_continuous(expand=c(0,0)) +

	theme_bw() +	
	theme( # remove axis
		axis.line=element_blank(),
		axis.text=element_blank(),
		axis.title=element_blank(),
		axis.ticks=element_blank()
	) +

	labs(fill=colVar)
}

# ______________________________________________________________________________________
# RENDERS
output$channelCumul_plot <- renderPlotly({
	input$refreshTabRun
	input$channelCumul_refresh
	isolate({
		req(nrow(channelStatReader())>0)
		if(input$refreshTabRun == 0 && input$channelCumul_refresh == 0 ){
			colAxe = "#Reads"
		} else {
			req( !is.null(input$channelStatCumul_col) )
			colAxe = input$channelStatCumul_col
		}
		ggplotly(plotChannelStat(formatData(channelStatReader()), colAxe), tooltip = "text") %>% plotlyConfig()
	})
})


output$channelCumul_colorMetricChoice <- renderUI({
        req(nrow(channelStatReader())>0)
	cn <- colnames(channelStatReader())
        cn = cn[ !cn %in% c("channel") ]
	selectInput(
		"channelStatCumul_col",
		"Select metric",
		cn,
		selected="#Reads"
	)
})


# ______________________________________________________________________________________
# FUNCTIONS

# create missing channel
# separate channel in 4 groups, like the interface on promethion
# transform the channel number into coordinate for the plot
formatData <- function(x) {

	# create a new row in x for the missing channel with NA for all columns (except for channel)
	for (i in 1:3000) {
		if(nrow(x[Channel==i]) == 0) {
			x = rbindlist(list(x,list(Channel=i)), fill=T)
		}
	}
	
	x[is.na(x)] = -1
	
	# separate channel in 4 groups
	x$n = 1
	x[as.integer(as.character(Channel))<1501 & as.integer(as.character(Channel))>750,n:=2]
	x[as.integer(as.character(Channel))<2251 & as.integer(as.character(Channel))>1500,n:=3]
	x[as.integer(as.character(Channel))<3001 & as.integer(as.character(Channel))>2250,n:=4]
	
	# channel is a factor, convert it to integer to compute coordinate
	channel = as.integer(as.character(x$Channel))

	bigCol = as.integer( (channel-1) /250)
	val = (channel-1)%%250+1

	xcoord = (val-1)%%10+1
	ycoord = as.integer((val-1)/10)+1

	x$xcoord = xcoord + bigCol * 10
	x$ycoord = ycoord

	return(x)
}
