library(tidyverse)
## data from https://www.bls.gov/tus/data/datafiles-0323.htm
## information on the activities: https://www.bls.gov/tus/lexicons/lexiconnoex0323.pdf
tus = read.csv("~/Downloads/atussum-0323/atussum_0323.dat")

summary(tus$TEAGE)
tus = tus |> mutate(age_binned = cut(TEAGE, breaks = seq(15, 85, by = 15)))
tus_parties = tus |> group_by(TUYEAR, age_binned) |>
  summarise(parties = mean(t120201))

ggplot(tus_parties, aes(x = TUYEAR, y = parties, color = age_binned)) + 
  facet_wrap(~ age_binned) + 
  geom_point()

ggplot(tus_parties, aes(x = TUYEAR, y = parties, color = age_binned)) + 
  stat_smooth(method = "lm", se = FALSE)

tus_gardening = tus |> group_by(TUYEAR) |>
  summarise(gardening = mean(t020501))
ggplot(tus_gardening, aes(x = TUYEAR, y = gardening)) + 
  geom_point()


tus_gardening = tus |> group_by(TUYEAR, age_binned) |>
  summarise(gardening = mean(t020501))
ggplot(tus_gardening, aes(x = TUYEAR, y = gardening, color = age_binned)) + 
  facet_wrap(~ age_binned) + 
  geom_point()
