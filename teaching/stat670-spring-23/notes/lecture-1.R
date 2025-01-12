## ----knitr-opts,echo=FALSE-----------------------------------------------
opts_chunk$set(size='scriptsize', fig.height=2, fig.width=4)

## ----data-read-----------------------------------------------------------
## load required packages and data
library(tidyverse)
options(tibble.print_min = 15)
heights = read_csv("highest-points-by-state.csv")
## switch from feet to meters
heights$elevation = heights$elevation * .3048

## ----data-print----------------------------------------------------------
heights

## ----data-arrange-ascending----------------------------------------------
arrange(heights, elevation)

## ----data-arrange-descending---------------------------------------------
arrange(heights, desc(elevation))

## ----stem-and-leaf-------------------------------------------------------
stem(heights$elevation)

## ----density-estimate----------------------------------------------------
ggplot(heights, aes(x = elevation)) + geom_density()

## ----density-estimate-plus-rug-------------------------------------------
ggplot(heights, aes(x = elevation)) + geom_density() + geom_rug()

