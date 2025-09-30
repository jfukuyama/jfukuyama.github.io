library(vegan)
library(cluster)
library(fpc)

otu_tab = read.csv("genus_counts.csv", row.names = 1)
sample_df = read.csv("sample_data.csv")
pyro_indices = which(sample_df$SeqTech == "Pyro454")
otu_tab = otu_tab[,pyro_indices]
sample_df = sample_df[pyro_indices,]

d = vegdist(t(otu_tab), method = "bray")

pamk_fit = pamk(d, krange = 1:6)
