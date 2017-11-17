
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
      select(.y, .ci, .ri) %>% 
      group_by(.ci, .ri) %>%
      summarise(mean = mean(.y)) %>%
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
    x    <- dataInput()[['.y']]
    
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

  token = query[["token"]]
  taskId = query[["taskId"]]
  
  # create a Tercen context object using the token
  ctx = tercenCtx(taskId=taskId, authToken=token)
  
  return(ctx)
}

getValues = function(session){
  ctx = getCtx(session)
  data = ctx %>% select(.y , .ci , .ri )
  return(data)
}
