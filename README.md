# Setup packrat 

```R
packrat::init(options = list(
  use.cache = TRUE,
  external.packages = 'devtools',
  load.external.packages.on.startup = FALSE))
  
remove.packages("rtson", lib = "./packrat/lib/x86_64-pc-linux-gnu/3.3.2")
remove.packages("tercen", lib = "./packrat/lib/x86_64-pc-linux-gnu/3.3.2")

devtools::install_github("tercen/TSON", ref = "1.4-rtson", subdir="rtson", upgrade_dependencies = FALSE)
devtools::install_github("tercen/teRcen", ref = "0.4.3", upgrade_dependencies = FALSE)

packrat::status()
packrat::snapshot()

# .gitignore add
packrat/src

```

# Shiny app

A simple shiny tercen operator :
 - display an histrogram
 - compute the mean
 
```
devtools::install_github("tercen/teRcen")

shiny::runApp(port=3044, launch.browser = FALSE)
```

```R
library(shiny)
library(rtercen)
 
# devtools::install_github("tercen/rtercen")
  
shinyServer(function(input, output, session) {
  
  dataInput = reactive({getValues(session)})

  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    x    <- dataInput()
  
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })

})

getValues = function(session){
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  
  token = query[["token"]]
  workflowId = query[["workflowId"]]
  stepId = query[["stepId"]]
  
  # create a Tercen client object using the token
  client = rtercen::TercenClient$new(authToken=token)
  # get the cube query defined by your workflow
  query = client$getCubeQuery(workflowId, stepId)
  # execute the query and get the data
  cube = query$execute()
  
  x = cube$sourceTable$getColumn("values")$getValues()$getData()
  return(x)
}

```






