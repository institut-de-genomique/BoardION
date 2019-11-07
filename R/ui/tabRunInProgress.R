tabRunInProgress <- tabItem(
	"runInProgress",
	DT::dataTableOutput("runIPTable"),
	
	tabBox(
		width=14,
		tabPanel(
			"Cumulative",
			tags$div(id="placeholder")
		),
		tabPanel(
			"Non-cumulative",
			uiOutput("runIPNonCumulative")
		)
	)
)
