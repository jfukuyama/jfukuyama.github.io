library(magrittr)
library(tidyverse)
library(ggbiplot)
library(ggrepel)
library(plyr)

# read in the three data sets
vote_descriptions = read.csv("../../datasets/congress_1999/bills.csv")
members = read.csv("../../datasets/congress_1999/members.csv")
votes = read.csv("../../datasets/congress_1999/votes.csv")
## match the column names of votes and the vote_id column in vote_descriptions
vote_descriptions = vote_descriptions %>%
    mutate(vote_id = str_replace(vote_id, "-", "."))

## match names and orders for members and votes
joined = join(members, votes, by = "id")
votes = joined[,(-1:-6)]
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

## Look at what fraction of senators vote yes by party, how we did it in class
voted_yes = (votes == "Yea")
members$yes_fraction = rowMeans(voted_yes)
ggplot(members, aes(x = yes_fraction, color = party)) +
    geom_density() + geom_rug()

## Another way to look at this: using functions, and gives slightly
## different answers because we are removing nas
frac_yes = function(v) {
    mean(v == "Yea", na.rm = TRUE)
}
frac_yes_all_senators = apply(votes, 1, frac_yes)
ggplot(data.frame(members, frac_yes = frac_yes_all_senators)) +
    geom_histogram(aes(x = frac_yes, fill = party))



## Decide how to recode the variables
recode_votes = function(vote) {
    if(is.na(vote)) {
        return(0)
    } else if(vote == "Yea") {
        return(1)
    } else if(vote == "Nay") {
        return(-1)
    } else {
        return(0)
    }
}
votes_numeric = apply(votes, 1:2, recode_votes)

## PCA
out_prcomp = prcomp(votes_numeric)

## scree plot
plot(out_prcomp$sdev^2 / sum(out_prcomp$sdev^2))

## let's look at who the senators are
members_and_scores = data.frame(members, out_prcomp$x)
ggplot(members_and_scores, aes(x = PC1, y = PC2)) +
    geom_point(aes(color = party)) +
    geom_text_repel(aes(label = display_name))
