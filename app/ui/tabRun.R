makeRunCustomablePlot <- function(name,w=12) {
	box(
		title = "Customisable plot",
		status = "primary",
		solidHeader = TRUE,
		collapsible = TRUE,
		collapsed = TRUE,
		width=w,
		fluidRow(
			column(width=3, uiOutput(paste(name,"_yAxeChoice",sep="")) ),
			column(width=3, uiOutput(paste(name,"_colorChoice",sep=""))),
			column(width=2, makeRefreshButton(paste(name,"_refreshPlotChoice",sep="")))
		),
		plotlyOutput(paste(name,"_plotAxeChoice",sep=""), height = "350px") %>% withSpinner(type=6)
	)

}

makeRunChannelPlot <- function(name, w=12) {
	box(
		title = "Channels view",
		status = "primary",
		solidHeader = TRUE,
		collapsible = TRUE,
		collapsed = TRUE,
		width=w,
		fluidRow(
			column(width=3, uiOutput(paste(name,"_colorMetricChoice",sep=""))),
			column(width=2, makeRefreshButton(paste(name,"_refresh",sep="")))
		),
		plotlyOutput(paste(name,"_plot",sep=""), height = "350px") %>% withSpinner(type=6)
	)
}

makeRunQotPlot <- function(name, w=12) {
	box(
		title = "Quality over time",
		status = "primary",
		solidHeader = TRUE,
		collapsible = TRUE,
		collapsed = TRUE,
		width=w,
		fluidRow(
			column(width=3, uiOutput( paste(name, "_colorMetricChoice", sep="" ))),
			column(width=1, checkboxInput( paste( name, "_logCheckBox", sep=""), "Log10", value = FALSE ), style="margin-top: 25px;"),
			column(width=1, makeRefreshButton(paste(name,"_refresh",sep="")))
		),
		plotlyOutput(paste(name,"_plot",sep=""), height = "500px") %>% withSpinner(type=6)
	)
}
tabRunGlobal <- tabPanel(

	"Since run start",
	fluidRow(
		makeGraphBox("Yield","globalRunNbBase", width=6),
		makeGraphBox("Read length", "globalReadLength"),
		makeRunChannelPlot("channelCumul"),
		makeRunCustomablePlot("tabRunGlobal")
	)
)

tabRunCurrent <- tabPanel(
	"Every 10 min",
	fluidRow(
		makeGraphBox("Yield","currentRunNbBase", width=12),
		makeRunQotPlot("qot"),
		makeRunCustomablePlot("tabRunCurrent")
	)
)

# liste deroulante avec la liste des run provenant du fichier run_infostat.txt
runListSelect <- selectInput(
	"runList",
	"Select a run",
	c()
)

runTitle <- textOutput("runTitle")

tabRun <- tabItem("run",
	fluidPage(
		fluidRow(
	  		column( width=12,
				h1(runTitle),
				fluidRow(
					column( width=3, runListSelect),
					makeRefreshButton("refreshTabRun")
				),
				DT::dataTableOutput("runTable"),
				tabBox( 
					width=12,
					tabRunGlobal,
					tabRunCurrent
				)
			)
		)
	)
)
