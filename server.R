
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)
library(tercen)
library(dplyr)
library(jsonlite)
 
options("tercen.workflowId"= "3aa8703da6b7534488c2f9632a0c0b0d")
options("tercen.stepId"= "282-14")
options("tercen.username"= "admin")
options("tercen.password"= "admin")

shinyServer(function(input, output, session) {
  
  dataInput = reactive({getValues(session)})
  mode = reactive({getMode(session)})
  settingsValue = reactiveValues()
  settingsValue$isInitialized = FALSE
   
  observeEvent(input$saveSettingsBtn, {
    showModal(modalDialog(
      title='Saving',
      span('Saving settings, please wait ...'),
      footer = NULL
    ))
    settings = list(bins=input$bins)
    setSettings(session,settings)
    removeModal()
  })
  
  observeEvent(input$bins, {
    if (settingsValue$isInitialized){
      settingsValue$value = list(bins=input$bins)
    } else {
      settingsValue$value = getSettings(session)
      settingsValue$isInitialized = TRUE
 
      # update ui
      updateSliderInput(session, 'bins', value=settingsValue$value$bins)
      shinyjs::show("bins")
    }
  })
  
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
    
    if (!is.null(m) && m == 'run'){
      shinyjs::enable("runBtn")
    }
    
    shinyjs::enable("saveSettingsBtn")
    
    if (is.null(settingsValue$value)){
      settingsValue$value = getSettings(session)
    } 
    
    settings = settingsValue$value
      
    # generate bins based on input$bins from ui.R
    x    <- dataInput()[['.y']]
    bins <- seq(min(x), max(x), length.out = settings$bins + 1)
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  })
})

getSettings = function(session) {
  fileSettings = getFileSettings(session)
  if (is.null(fileSettings)){
    settings = list(bins=30)
    return(settings)
  }
  ctx = getCtx(session)
  bytes = ctx$client$fileService$download(fileSettings$id)
  settings = fromJSON(rawToChar(bytes))
  return(settings)
}

setSettings = function(session, settings){
  ctx = getCtx(session)
  fileSettings = getFileSettings(session)
  if (!is.null(fileSettings)){
    ctx$client$fileService$delete(fileSettings$id,fileSettings$rev)
  }
   
  workflowId = getWorkflowId(session)
  stepId = getStepId(session)
  workflow = ctx$client$workflowService$get(workflowId)
  
  fileDoc = FileDocument$new()
  fileDoc$name = 'webapp-operator-settings'
  fileDoc$projectId = workflow$projectId
  fileDoc$acl$owner = workflow$acl$owner
  fileDoc$metadata$contentType = 'application/octet-stream'
  
  metaWorkflowId = Pair$new()
  metaWorkflowId$key = 'workflow.id'
  metaWorkflowId$value = workflowId
  
  metaStepId = Pair$new()
  metaStepId$key = 'step.id'
  metaStepId$value = stepId
  
  fileDoc$meta = list(metaWorkflowId, metaStepId)
  content = toJSON(settings)
  bytes = charToRaw(content)
  fileDoc = ctx$client$fileService$upload(fileDoc, bytes)
  fileDoc
}

getFileSettings = function(session) {
  ctx = getCtx(session)
  workflowId = getWorkflowId(session)
  stepId = getStepId(session)
  workflow = ctx$client$workflowService$get(workflowId)
  
  files = ctx$client$fileService$findFileByWorkflowIdAndStepId(
    startKey=list(workflowId,stepId),
    endKey=list(workflowId,''),
    descending=TRUE, limit=1 )
  
  if (length(files) > 0) {
    return (files[[1]])
  } 
  
  return (NULL)
}

getMode = function(session){
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  return(query[["mode"]])
}

getWorkflowId = function(session){
  return(getOption("tercen.workflowId"))
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  return(query[["workflowId"]])
}

getStepId = function(session){
  return(getOption("tercen.stepId"))
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)
  return(query[["stepId"]])
}

getCtx = function(session){
  # retreive url query parameters provided by tercen
  query = parseQueryString(session$clientData$url_search)

  token = query[["token"]]
  taskId = query[["taskId"]]
   
  # create a Tercen context object using the token
  # ctx = tercenCtx(taskId=taskId, authToken=token)
  
  ctx = tercenCtx()
  
  return(ctx)
}

getValues = function(session){
  ctx = getCtx(session)
  data = ctx %>% select(.y , .ci , .ri )
  return(data)
}
