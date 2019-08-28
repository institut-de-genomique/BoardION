# ______________________________________________________________________________________
# FUNCTIONS

makeGraphBox <- function(name,id,width=6,height="350px") {
	box(
		title = name,
		status = "primary",
		solidHeader = TRUE,
                collapsible = TRUE,
		width = width,
#		background="navy",
		plotlyOutput(paste("plot_",id,sep=""), height = height, inline=T)
	)
}


# ______________________________________________________________________________________
# HEADER

header <- dashboardHeader(title = "PromethIon dashboard")


# ______________________________________________________________________________________
# SIDEBAR

source("ui/sideBar.R")


# ______________________________________________________________________________________
# BODY    

source("ui/tabGlobal.R")
source("ui/tabRun.R")
source("ui/tabComparison.R")
source("ui/tabRunInProgress.R")

body <- dashboardBody (
	tabItems(
		tabGlobal,
		tabRun,
		tabComparison,
		tabRunInProgress
	),
	tags$script(HTML("$('body').addClass('fixed');")) # Lock the header bar and the side bar
	#shinyDashboardThemes( theme = "grey_light" )
)


# ______________________________________________________________________________________
# MAIN UI

ui <- dashboardPage(title = 'PROM', header, sidebar, body, skin='blue')
