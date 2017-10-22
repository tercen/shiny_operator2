
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)
library(tercen)
library(dplyr)

# devtools::install_github("tercen/rtercen")

shinyServer(function(input, output, session) {
  
  dataInput = reactive({getValues(session)})
  mode = reactive({getMode(session)})
  
  observeEvent(input$runBtn, {
    
    shinyjs::disable("runBtn")
    shinyjs::show("runStatus")
    
    (ctx = getCtx(session))  %>% 
      select(.values, .cindex, .rindex) %>% 
      group_by(.cindex, .rindex) %>%
      summarise(mean = mean(.values)) %>%
      ctx$addNamespace() %>%
      ctx$save()
    
    
  })
  
  output$mode = renderText({ 
    mode()
  })
  
  output$distPlot <- renderPlot({
    m = mode()
    if (m == 'run'){
      shinyjs::enable("runBtn")
    }
    # generate bins based on input$bins from ui.R
    x    <- dataInput()[['.values']]
    
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
    
    
  })
  
})

getMode = function(session){
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  return(query[["mode"]])
}

getCtx = function(session){
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  
  print(query)
  token = query[["token"]]
  workflowId = query[["workflowId"]]
  stepId = query[["stepId"]]
  taskId = query[["taskId"]]
  serviceUri = query[["serviceUri"]]
  mode = query[["mode"]]
  
  # create a Tercen context object using the token
  ctx = tercenCtx(workflowId=workflowId, stepId=stepId, taskId=taskId, authToken=token, serviceUri=serviceUri)
  
  return(ctx)
}

getValues = function(session){
  ctx = getCtx(session)
  data = ctx %>% select(.values , .cindex , .rindex )
  return(data)
}