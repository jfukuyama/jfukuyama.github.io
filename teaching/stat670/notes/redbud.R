library(ggplot2)
library(BIEN)
library(maps)
indiana_species = BIEN_list_state(country = "United States", state = "Indiana")
redbud = BIEN_stem_species("Cercis canadensis")

ggplot(redbud, aes(x = stem_dbh_cm, color = dataset)) + stat_ecdf()

ggplot(redbud, aes(x = stem_dbh_cm, fill = dataset)) + 
  geom_histogram(bins = 50, alpha = .5, position = "identity") + xlim(c(0,40))
ggplot(redbud, aes(x = stem_dbh_cm)) + 
  geom_density() + xlim(c(0,40))

table(redbud$dataset)
