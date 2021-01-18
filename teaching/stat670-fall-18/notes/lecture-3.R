## ----setup, echo = FALSE-------------------------------------------------
library(knitr)
opts_chunk$set(fig.cap="", fig.width = 4, fig.height = 2.5, dpi=200, fig.path="lecture-3-fig/")

## ----tidy-data-----------------------------------------------------------
library(tidyverse)
table1
table2
table3
table4a
table4b

## ----gather--------------------------------------------------------------
table4a %>% 
  gather(`1999`, `2000`, key = "year", value = "cases")

## ----spread--------------------------------------------------------------
table2 %>%
    spread(key = type, value = count)

## ----cytof-load-and-wrangle----------------------------------------------
## done in class
cytof = read.csv("http://jfukuyama.github.io/teaching/stat670/notes/cytof_one_experiment.csv")
## Remember how we plotted ecdf etc plots for singers:
library(lattice)
head(singer)
ggplot(singer) + stat_ecdf(aes(x = height)) + facet_wrap(~ voice.part)
## to do the analogous thing for the cytof data, we can use gather (or melt), but first just take the top of the cytof dataset
cytof = cytof[1:10000,]
cytof_melted = cytof %>% gather(colnames(cytof), key = "marker", value = "value")
## this isn't how we did it in class, but you can also use the "melt" function in dplyr
cytof_melted_alt = melt(cytof)

## ----cytof-plots, fig.width = 8, fig.height = 8--------------------------
## make an ecdf plot
ggplot(cytof_melted, aes(x = value)) + stat_ecdf() + facet_wrap(~ marker)
## make a histogram, play around with the bins, allow the scales on the y axis to vary by plot
ggplot(cytof_melted, aes(x = value)) +
    geom_histogram() +
    facet_wrap(~ marker)
ggplot(cytof_melted, aes(x = value)) +
    geom_histogram(bins = 300) +
    facet_wrap(~ marker, scales = "free_y")
## make a density plot, play around with the kernel width
ggplot(cytof_melted, aes(x = value)) +
    geom_density() +
    facet_wrap(~ marker, scales = "free_y")
ggplot(cytof_melted, aes(x = value)) +
    geom_density(adjust = .1) +
        facet_wrap(~ marker, scales = "free_y")

## ----cytof-density-and-histogram-----------------------------------------
## for the question about plotting a density and histogram on the same plot: what makes this tricky is that the density and the histogram plots have different ranges of y values. You can put them both on the same plot, but the density will be pushed all the way down to the x axis (check on your own, it's easier to see when the density is in a contrasting color). The y = ..density.. part of the geom_histogram command below changes this so that the scales are the same and you can see both at once.
## Thanks to Joe Stoica for the pointer!
ggplot(cytof) +
    geom_histogram(aes(x = NKp30, y = ..density..), bins = 1000) +
    geom_density(aes(x = NKp30), color = "red", adjust = .1)

## ----summarise-----------------------------------------------------------
library(dplyr)
## for the data
library(lattice)
singer %>% summarise(median(height))
singer %>% group_by(voice.part) %>% summarise(median(height))

## ----boxplot-one, fig.width = 2------------------------------------------
library(ggplot2)
## lattice is for the singer data
library(lattice)
ggplot(singer, aes(x = "Height", y = height)) +
    geom_boxplot()

## ----boxplot-two---------------------------------------------------------
ggplot(singer, aes(x = voice.part, y = height)) +
    geom_boxplot() +
    coord_flip()

## ----iqr-----------------------------------------------------------------
(iqr = qnorm(.75) - qnorm(.25))

## ----uav-lav-------------------------------------------------------------
(uav = qnorm(.75) + 1.5 * iqr)
(lav = qnorm(.25) - 1.5 * iqr)

## ----prob-outside-value-one-sample---------------------------------------
(prob_outside = pnorm(uav, lower.tail = FALSE) + pnorm(lav, lower.tail = TRUE))

## ----prob-outside-value-many-samples-------------------------------------
n = 30
1 - (1 - prob_outside)^n

## ----prob-outside-value-many-more-samples--------------------------------
n = 3000
1 - (1 - prob_outside)^n

## ----boxplot-simulation--------------------------------------------------
set.seed(0)
df = data.frame(y = rnorm(30), x = "dummy variable")
ggplot(df) +
    geom_boxplot(aes(x = x, y = y)) +
    coord_flip()

## ----boxplot-simulation-larger-------------------------------------------
set.seed(0)
df = data.frame(y = rnorm(3000), x = "dummy variable")
ggplot(df) +
    geom_boxplot(aes(x = x, y = y)) +
    coord_flip()

