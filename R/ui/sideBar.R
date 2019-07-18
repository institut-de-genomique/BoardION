# ______________________________________________________________________________________
# SIDEBAR

menu <- sidebarMenu(
	id = "menu",
	menuItem("Global", tabName = "global"), # stat sur l'ensemble des runs
	menuItem("Run", tabName = "run"),	# stat sur un run
	menuItem("Comparison", tabName = "comparison")
#	menuItem("Test2", tabName = "testTab2")
)
	
sidebar <- dashboardSidebar(
	menu
)