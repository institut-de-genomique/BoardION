tabRunInProgress <- tabItem(
	"runInProgress",
	DT::dataTableOutput("runIPTable"),

	switchInput(
		inputId = "rip_cumulative_toggle",
		label = "Cumulative", 
		labelWidth = "80px",
		value = TRUE
	),

	tags$div(id="placeholder")
)
