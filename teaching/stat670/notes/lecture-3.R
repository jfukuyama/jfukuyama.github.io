## ----setup, echo = FALSE-------------------------------------------------
library(knitr)
opts_chunk$set(fig.cap="", fig.width = 4, fig.height = 2.5, dpi=200)

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

