# ______________________________________________________________________________________
# FILES READERS


channelStatReader <- reactive ({
	dt = reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_channel_stat.txt",sep=""),
		readFunc       = readCsvSpace
	)()
	
	dt[,LENGTHCUMUL:=LENGTH*`#READS`]
	return(dt)
})

# ______________________________________________________________________________________
# PLOTS

plotChannelStat <- function(x) {
	ggplot(
		x,
		aes(x=xcoord,
		    y=ycoord,
		    fill=get(input$channelStatCumul_col),
		    text=paste("Channel: ",CHANNEL,
			       "<br>Reads count: ",get("#READS"),
			       "<br>Length: ",get("LENGTH"),
			       "<br>Quality: ",get("MEANQSCORE"),
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
	theme(	axis.line=element_blank(),
		axis.text=element_blank(),
		axis.title=element_blank(),
		axis.ticks=element_blank()
	) +

	labs(fill=input$channelStatCumul_col)
}

# ______________________________________________________________________________________
# RENDERS
output$plot_channelStatCumul <- renderPlotly({
	req(input$channelStatCumul_col != "")
	req(nrow(channelStatReader())>0)
	ggplotly(plotChannelStat(formatData(channelStatReader())), tooltip = "text") %>% plotlyConfig() # take only data of the selected run !!!!!!!!!!!!!!!!!!!change condition value to input$runList!!!!!!!!!!!!!!!!!!!
})


output$channelStatCumul_colorMetricChoice <- renderUI({
        req(nrow(channelStatReader())>0)
	cn <- colnames(channelStatReader())
        cn = cn[ !cn %in% c("channel") ]
	selectInput(
		"channelStatCumul_col",
		"Select metric",
		cn,
		selected="#READS"
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
		if(length(x[CHANNEL==i])) {
		} else {
			x = rbindlist(list(x,list(CHANNEL=i,count=1)), fill=T)
		}
	}
	
	x[is.na(x)] = -1
	
	# separate channel in 4 groups
	x$n = 1
	x[as.integer(as.character(CHANNEL))<1501 & as.integer(as.character(CHANNEL))>750,n:=2]
	x[as.integer(as.character(CHANNEL))<2251 & as.integer(as.character(CHANNEL))>1500,n:=3]
	x[as.integer(as.character(CHANNEL))<3001 & as.integer(as.character(CHANNEL))>2250,n:=4]
	
	# channel is a factor, convert it to integer to compute coordinate
	channel = as.integer(as.character(x$CHANNEL))

	bigCol = as.integer( (channel-1) /250)
	val = (channel-1)%%250+1

	xcoord = (val-1)%%10+1
	ycoord = as.integer((val-1)/10)+1

	x$xcoord = xcoord + bigCol * 10
	x$ycoord = ycoord

	return(x)
}
