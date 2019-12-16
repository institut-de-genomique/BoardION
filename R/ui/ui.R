# ______________________________________________________________________________________
# FUNCTIONS

makeGraphBox <- function(name, id, width=6, height="350px", collapsed=FALSE) {
	box(
		title = name,
		status = "primary",
		solidHeader = TRUE,
                collapsible = TRUE,
		collapsed = collapsed,
		width = width,
#		background="navy",
		plotlyOutput(paste("plot_",id,sep=""), height = height, inline=T) %>% withSpinner(type=6)
	)
}


# ______________________________________________________________________________________
# HEADER

header <- dashboardHeader(title = "BoardIon")


# ______________________________________________________________________________________
# SIDEBAR

source("ui/sideBar.R")


# ______________________________________________________________________________________
# BODY    

#source("ui/tabGlobal.R")
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
	tags$script(HTML("$(function(){
		$('body').addClass('fixed');
	});
	
	")) # Lock the header bar and the side bar
	#shinyDashboardThemes( theme = "grey_light" )
)


# ______________________________________________________________________________________
# MAIN UI

ui <- dashboardPage(title = 'PROM', header, sidebar, body, skin='blue')
