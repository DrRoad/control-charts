library(shiny)
library(ggvis)
library(dplyr)

shinyServer(function(input, output) {

samp_data <- reactive({
    
    # generate some random data
    samp <- data.frame(defects = rbinom(input$m * input$reps, input$n, input$p), 
                       month = 1:input$m,
                       run = as.factor(rep(1:input$reps, each = input$m)),
                       n = input$n) 
        
})
        
samp_data_plus <- reactive({
    sigma <- sqrt(input$thresh * (1 - input$thresh) / input$n)
    upper <- input$thresh + 2 * sigma
    lower <- input$thresh - 2 * sigma
    
    tmp <- samp_data() %>%
        mutate(upper = upper,
               thresh = input$thresh) %>%
        mutate(defectsp = defects / n) %>%
        group_by(run) %>%
        mutate(cumdefects = cumsum(defects),
               cumn = cumsum(n),
               cumdefectp = cumdefects / cumn,
               cumsigma = sqrt(cumdefectp * (1 - cumdefectp) / cumn),
               cumupper = cumdefectp + 1.96 * cumsigma,
               cumlower = cumdefectp - 1.96 * cumsigma)
    
    return(tmp)
    
})


    samp_data_plus %>%
        ggvis(x = ~month, y = ~defectsp, stroke = ~run) %>%
        layer_lines() %>%
        layer_lines(y = ~upper, stroke := "black") %>%
        hide_legend(scales = "stroke") %>%
        bind_shiny("controlChart")

    samp_data_plus %>%
        filter(run == 1) %>%
        ggvis(x = ~month) %>%
        layer_ribbons(y = ~cumupper, y2 = ~cumlower, fill := "grey") %>%
        layer_lines(y = ~thresh, stroke := "red") %>%
        bind_shiny("ribbonChart")
    
})
