library(magrittr)
library(tidyverse)
library(ggbiplot)
library(ggrepel)
library(plyr)

vote_descriptions = read.csv("../../datasets/congress_1999/bills.csv")
members = read.csv("../../datasets/congress_1999/members.csv")
votes = read.csv("../../datasets/congress_1999/votes.csv")
## doing this to make the vote_id column in bills match the column names in votes
vote_descriptions = vote_descriptions %>% mutate(vote_id = str_replace(vote_id, "-", "."))
## this makes members and votes go in the same order
joined = join(members, votes, by = "id")
votes = joined[,c(-1, -2, -3, -4, -5, -6)]
members = joined[,1:6]

## Look at members
table(members$party)
table(members$state)

## Look at the vote_descriptions data frame
table(vote_descriptions$category)
table(vote_descriptions$requires)
table(vote_descriptions$category, vote_descriptions$requires)

## Look at the votes data frame
table(unlist(votes))
frac_yes = function(v) {
    mean(v == "Yea", na.rm = TRUE)
}
## Look at what fraction of senators vote yes on different
frac_yes_all_senators = apply(votes, 1, frac_yes)
ggplot(data.frame(members, frac_yes = frac_yes_all_senators)) +
    geom_histogram(aes(x = frac_yes, fill = party)) +
    scale_fill_manual(values = c("D" = "darkblue", "R" = "firebrick"))

## Decide how to recode the variables
## this function maps "Yea" to 1, "Nay" to -1, everything else to 0
recode = function(x) {
    if(is.na(x)) {
        return(0)
    } else if(x == "Yea") {
        return(1)
    } else if(x == "Nay") {
        return(-1)
    } else {
        return(0)
    }
}
votes_recoded = apply(votes, 1:2, recode)

## Look at the PCA plots for different subsets
procedural_ids = subset(vote_descriptions, category == "procedural")$vote_id
votes_procedural = votes_recoded[,procedural_ids]
procedural_prcomp = prcomp(votes_procedural, scale. = FALSE)
## scree plot, variance explained by the first component is very large, indicates one-dimensional structure
plot(procedural_prcomp$sdev^2 / sum(procedural_prcomp$sdev^2))
ggbiplot(procedural_prcomp, scale = 0, var.axes = FALSE, group = members$party)  +
    scale_color_manual(values = c("D" = "darkblue", "R" = "firebrick"))


passage_ids = subset(vote_descriptions, category == "passage")$vote_id
votes_passage = votes_recoded[,passage_ids]
passage_prcomp = prcomp(votes_passage, scale. = FALSE)
## scree plot, variance explained by the first component is very large, indicates one-dimensional structure
plot(passage_prcomp$sdev^2 / sum(passage_prcomp$sdev^2))
ggbiplot(passage_prcomp, scale = 0, var.axes = FALSE, group = members$party)  +
    scale_color_manual(values = c("D" = "darkblue", "R" = "firebrick"))

## let's look at who the senators are
ggplot(data.frame(passage_prcomp$x, members),aes(x = PC1, y = PC2, label = display_name), size  =8) +
    geom_point() + geom_text_repel()
