
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)

ui <- shinyUI(fluidPage(
  shinyjs::useShinyjs(),
  tags$script(HTML('setInterval(function(){ $("#hiddenButton").click(); }, 1000*30);')),
  tags$footer(shinyjs::hidden(actionButton(inputId = "hiddenButton", label = "hidden"))),
  uiOutput("body"),
  title = "Shiny Operator 2"
))
