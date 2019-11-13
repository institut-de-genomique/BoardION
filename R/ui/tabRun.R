tabRunGlobal_boxAxeChoice <-box(
	title = "",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width=12,
	fluidRow(
		column(width=2, uiOutput("tabRunGlobal_xAxeChoice") ),
		column(width=2, uiOutput("tabRunGlobal_yAxeChoice") ),
		column(width=2, uiOutput("tabRunGlobal_colorChoice") )
	),
	plotlyOutput("tabRunGlobal_plotAxeChoice", height = "350px")
)




tabRunGlobal <- tabPanel(

	"Cumlative stat",
	fluidRow(
		tabBox(
			width=12,
			tabPanel(
				"Global",
				fluidRow (
					makeGraphBox("Nombre de bases","globalRunNbBase", width=6),
					makeGraphBox("Read length", "globalReadLength"),
					tabRunGlobal_boxAxeChoice	
				)
			),
		
			tabPanel(
				"Channel",
				fluidRow(
					column(width=3, uiOutput("channelStatCumul_colorMetricChoice")),
					makeGraphBox("Stat per channel","channelStatCumul",width=12,height="500")
				)
			)
		)
	)
)

tabRunCurrent <- tabPanel(
	"Real time stat",
	fluidRow(
		tabBox(
			width=12,
			tabPanel(
				"Global",
				fluidRow(
					makeGraphBox("Nombre de bases","currentRunNbBase"),
					makeGraphBox("Nombre de read", "currentRunNbRead"),
					makeGraphBox("Speed", "currentRunSpeed")
				)
			),
			tabPanel(
				"Channel",
				fluidRow(
					makeGraphBox("Stat per channel","channelStatCurrent",12),
					column(width=3, uiOutput("channelStatCurrent_colorMetricChoice"))
				)
			),
			tabPanel(
				"QualityOverTime",
				fluidRow(
					column(width=2,uiOutput("qualityOverTime_colorMetricChoice")),
					column(width=2,checkboxInput("qualityOverTime_logCheckBox", "Log10_color", value = FALSE))
				),
				fluidRow(
					makeGraphBox("Quality over time","qualityOverTime",width=12,height="700px"),
					width=12
				)
			)
		)
	)
)

# liste deroulante avec la liste des run provenant du fichier run_infostat.txt
runListSelect <- selectInput(
	"runList",
	"List of run",
	c(),
	width="20%"
)

runTitle <- textOutput("runTitle")

tabRun <- tabItem("run",
	fluidPage(
		h1(runTitle),
		fluidRow(column(
			runListSelect,
			DT::dataTableOutput("runTable"),
			tabBox( 
				width=12,
				tabRunGlobal,
				tabRunCurrent
			),
			width=12
		))
	)
)
