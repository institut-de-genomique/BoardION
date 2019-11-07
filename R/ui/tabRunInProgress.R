tabRunInProgress <- tabItem(
	"runInProgress",
	DT::dataTableOutput("runIPTable"),

	tags$head(tags$style(HTML(".small-box {height: 85px}"))), # make value box smaller

	switchInput(
		inputId = "rip_cumulative_toggle",
		label = "Cumulative", 
		labelWidth = "80px",
		value = TRUE
	),

	tags$div(id="placeholder")
)
