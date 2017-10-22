
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  shinyjs::useShinyjs(),

  # Application title
  titlePanel("Tercen"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      h3(textOutput("mode")),
      plotOutput("distPlot"),
      shinyjs::hidden(p(id = "runStatus", "Processing...")),
      actionButton("runBtn", "Run", disabled=TRUE)
      
    )
  )
))
