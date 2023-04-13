library(magrittr)
library(tidyverse)
library(ggbiplot)
library(ggrepel)
library(plyr)
library(MASS)

## Most of this is the same as what we did last time
vote_descriptions = read.csv("https://jfukuyama.github.io/teaching/stat670/notes/bills.csv")
members = read.csv("https://jfukuyama.github.io/teaching/stat670/notes/members.csv")
votes = read.csv("https://jfukuyama.github.io/teaching/stat670/notes/votes.csv")
## doing this to make the vote_id column in bills match the column names in votes
vote_descriptions = vote_descriptions %>% mutate(vote_id = str_replace(vote_id, "-", "."))
## Let's get some information about the states: state.abb and state.region are default R datasets
state_descriptions = data.frame(region = state.region, state = state.abb)
table(state_descriptions$region)
## add this information to the members data frame
members = join(members, state_descriptions)
## this makes members and votes go in the same order
joined = join(members, votes, by = "id")
votes = joined[,c(-1, -2, -3, -4, -5, -6, -7)]
members = joined[,1:7]

## Look at the vote_descriptions data frame
table(vote_descriptions$category)
table(vote_descriptions$requires)
table(vote_descriptions$category, vote_descriptions$requires)

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

## passage vs. procedural
votes_passage = votes_recoded[,vote_descriptions$category == "passage"]
passage_prcomp = prcomp(votes_passage, center = TRUE, scale. = FALSE)
plot(passage_prcomp$sdev^2 / sum(passage_prcomp$sdev^2), main = "Passage scree plot")
## projection of senators onto principal axes
ggbiplot(passage_prcomp, var.axes = FALSE, scale = 0, groups = members$party)


votes_procedural = votes_recoded[,vote_descriptions$category == "procedural"]
procedural_prcomp = prcomp(votes_procedural, center = TRUE, scale. = FALSE)
plot(procedural_prcomp$sdev^2 / sum(procedural_prcomp$sdev^2), main = "Procedural scree plot")
## projection of senators onto principal axes
ggbiplot(procedural_prcomp, var.axes = FALSE, scale = 0, groups = members$party)


## Suppose that instead of being interested in party, we want to know about what differentiates regions from each other
ggbiplot(passage_prcomp, var.axes = FALSE, scale = 0, groups = members$region)



## try LDA on the passage votes

passage_lda = lda(x = votes_passage, grouping = members$region)

## how accurate is our LDA model?
table(predict(passage_lda)$class, members$region)

## which bills are important?
ggbiplot(passage_lda, groups = members$region)
table(votes[,"s28.106.1999"])


## Do LDA on just the competitive votes
is_competitive = function(v) {
    frac_yea = mean(v == "Yea", na.rm = TRUE)
    if(frac_yea >= .25 & frac_yea <= .75) {
        return(TRUE)
    }
    return(FALSE)
}
competitive_votes = apply(votes, 2, is_competitive)
votes_competitive = votes_recoded[,competitive_votes]
lda_competitive = lda(x = votes_competitive, grouping = members$region)

table(predict(lda_competitive)$class, members$region)
ggbiplot(lda_competitive, groups = members$region, choices = c(1,2))
ggbiplot(lda_competitive, var.axes = FALSE, groups = members$region, choices = c(1,2))
