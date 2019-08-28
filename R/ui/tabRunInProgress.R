tabRunInProgress <- tabItem(
	"runInProgress",
	tableOutput("runIPTable"),
	makeGraphBox("Yield","globalRunIPYield",width=12,height="700px"),
	width=12
)