tabRunGlobal <- tabPanel(

	"Cumlative stat",
	fluidRow(
		tabBox(
			width=12,
			tabPanel(
				"Global",
				fluidRow (
					makeGraphBox("Nombre de bases","globalRunNbBase"),
					makeGraphBox("Nombre de read", "globalRunNbRead"),
					makeGraphBox("Speed", "globalRunSpeed")
				)
			),
		
			tabPanel(
				"Channel",
				fluidRow(
					makeGraphBox("Stat per channel","channelStatCumul",12),
					column(width=3, uiOutput("channelStatCumul_colorMetricChoice"))
				)
			),
			tabPanel(
				"QualityOverTime",
				fluidRow(
					makeGraphBox("Quality over time","qualityOverTime",width=12,height="700px"),
					column(width=3, uiOutput("qualityOverTime_colorMetricChoice"))
				)
			)
		)
	)
)

tabRunCurrent <- tabPanel(
	"Current stat",
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
			)
		)
	)
)

# liste deroulante avec la liste des run provenant du fichier run_infostat.txt
runListSelect <- selectInput(
	"runList",
	"List of run",
	c()
)

runTitle <- textOutput("runTitle")

tabRun <- tabItem("run",
	fluidPage(
		h1(runTitle),
		runListSelect,
		box(tableOutput("runTable"),width=12),
		tabBox( 
			width=12,
			tabRunGlobal,
			tabRunCurrent
		)
	)
)
