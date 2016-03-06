library(ggvis)
library(dplyr)
library(ggplot2)

# define true defect rate
p <- 0.11

# sample size per month
n <- 300

# number of months to do it for:
m <- 24

# number of series to simulate
reps <- 10

# maximum acceptable threshold defect rate
thresh <- 0.10

# we xcreate control lines on the basis of a hypothesis the true rate
# is greater/equal than thresh, and a hypothesis it is less
sigma <- sqrt(thresh * (1- thresh) / n)
upper <- thresh + 3 * sigma
lower <- thresh - 3 * sigma

# generate some random data
samp <- data.frame(defects = rbinom(m * reps, n, p), 
                   month = 1:m,
                   run = as.factor(rep(1:reps, each = m)),
                   upper = upper,
                   n = n,
                   thresh = thresh) %>%
    mutate(defectsp = defects / n) %>%
    group_by(run) %>%
    mutate(cumdefects = cumsum(defects),
           cumn = cumsum(n),
           cumdefectp = cumdefects / cumn,
           cumsigma = sqrt(cumdefectp * (1 - cumdefectp) / cumn),
           cumupper = cumdefectp + 1.96 * cumsigma,
           cumlower = cumdefectp - 1.96 * cumsigma)

# this is what the control chart will look like:
samp %>%
    ggvis(x = ~month, y = ~defectsp, stroke = ~run) %>%
    layer_lines() %>%
    layer_lines(y = ~upper, stroke := "black") %>%
    hide_legend(scales = "stroke")

head(samp)

# this is your converging confidence interval of the actual proportion of defects:
samp %>%
    filter(run == 3) %>%
    ggvis(x = ~month) %>%
    layer_ribbons(y = ~cumupper, y2 = ~cumlower, fill := "grey") %>%
    layer_lines(y = ~thresh, stroke := "red")
    



