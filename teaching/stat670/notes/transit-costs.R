## https://github.com/rfordatascience/tidytuesday/blob/main/data/2021/2021-01-05/readme.md
library(tidyverse)
tuesdata <- tidytuesdayR::tt_load('2021-01-05')
transit_cost <- tuesdata$transit_cost

## this is not a great plot because you can't see most of the data
ggplot(transit_cost, aes(x = length, y = cost)) + geom_point()
## log transforming helps
ggplot(transit_cost, aes(x = length, y = cost)) + geom_point() + scale_x_log10() + scale_y_log10()

## let's look at the relationship between cost and length conditioning on stations

## not good, not enough points per facet in most cases
ggplot(subset(transit_cost, !is.na(stations)), aes(x = length, y = cost)) + 
  geom_point() + 
  facet_wrap(~ stations) +
  scale_x_log10() + 
  scale_y_log10()


## looks better
ggplot(subset(transit_cost, !is.na(stations)), aes(x = length, y = cost)) + 
  geom_point() + 
  facet_wrap(~ cut_number(stations, n = 5)) +
  scale_x_log10() + 
  scale_y_log10()

## doesn't work because of too many repeated 0's and 1's
ggplot(transit_cost, aes(x = length, y = cost)) +
  geom_point() +
  facet_wrap(~ cut_number(tunnel / length, n = 5)) +
  scale_x_log10() +
  scale_y_log10()

## manual breaks give a better balance of points
ggplot(transit_cost, aes(x = length, y = cost)) +
  geom_point() +
  facet_wrap(~ cut(tunnel / length, breaks = c(-.01, 0, .5, .9, 1.01))) +
  scale_x_log10() +
  scale_y_log10() +
  stat_smooth(method = "loess")

## another way of doing manual breaks, using case_when
transit_cost = transit_cost |> 
  mutate(tunnel_frac_discretized = case_when(
    tunnel / length == 0 ~ "0",
    tunnel / length > 0 & tunnel / length <= .5 ~ "(0,.5]",
    tunnel / length > .5 & tunnel / length < 1 ~ "(.5,1)",
    tunnel / length >= 1 ~ "1"
)) |> 
  mutate(tunnel_frac_discretized = 
           factor(tunnel_frac_discretized, 
                  levels = c("0", "(0,.5]", "(.5,1)", "1"), 
                  ordered = TRUE))
transit_cost = subset(transit_cost, !is.na(tunnel_frac_discretized))
ggplot(transit_cost, aes(x = length, y = cost)) + 
  geom_point() +
  facet_wrap(~ tunnel_frac_discretized) +
  scale_x_log10() + scale_y_log10()
