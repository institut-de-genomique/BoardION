testMultiSelect <- selectizeInput(
	"testRunList",
	"Choose runs",
	choices = c(),
	multiple = TRUE
)

b_testMultiSelect <-box(
      title = "Cumulative yield",
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,
      plotlyOutput("testMulti", height = "300px")
)

tabComparison <- tabItem("comparison",
	fixedRow(testMultiSelect,b_testMultiSelect)
)
