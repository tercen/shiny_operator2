source("ui.R")
source("server.R")

# Set appropriate options
#options("tercen.serviceUri"="http://tercen:5400/api/v1/")
#options("tercen.workflowId"= "4133245f38c1411c543ef25ea3020c41")
#options("tercen.stepId"= "2b6d9fbf-25e4-4302-94eb-b9562a066aa5")
#options("tercen.username"= "admin")
#options("tercen.password"= "admin")

# add ?mode=<mode> after opening browser window. mode can be either "show", "run" or "showResult"

runApp(shinyApp(ui, server))  
