library(shiny)
library(ggvis)

shinyUI(fluidPage(

  # Application title
  titlePanel("Control chart simulation"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("n",
                  "Number of samples per month:",
                  min = 1,
                  max = 60,
                  value = 30),
    sliderInput("reps",
                "Number of sites to show in control chart:",
                min = 1,
                max = 25,
                value = 5),
    sliderInput("m",
                "Number of months to show:",
                min = 12,
                max = 48,
                value = 24),
    numericInput("p",
                 "True defect rate",
                 min = 0, max = 1, step = 0.01,
                 value = 0.08),
    numericInput("thresh",
                 "Target maximum defect rate",
                 min = 0, max = 1, step = 0.01,
                 value = 0.10)
  ),

    # Show a plot of the generated distribution
    mainPanel(
      h3("Example control chart/s - one line per site"),
      ggvisOutput("controlChart"),
      h3("A single site's converging confidence interval for defect rate"),
      ggvisOutput("ribbonChart")
    )
  )
))
