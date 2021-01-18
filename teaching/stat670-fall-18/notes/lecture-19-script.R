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

## let's get rid of the extra row for Lincoln Chafee, he's represented as senator 101 and senator 19
members = members[-101,]
votes = votes[-101,]

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

passage_ids = subset(vote_descriptions, category == "passage")$vote_id
votes_passage = votes_recoded[,passage_ids]
passage_prcomp = prcomp(votes_passage, scale. = FALSE)
## scree plot, variance explained by the first component is very large, indicates one-dimensional structure
plot(passage_prcomp$sdev^2 / sum(passage_prcomp$sdev^2))
ggbiplot(passage_prcomp, scale = 0, var.axes = FALSE, group = members$party)  +
    scale_color_manual(values = c("D" = "darkblue", "R" = "firebrick"))

### Above is pretty much the same from last week. Below is new. ###

## Suppose that instead of being interested in party, we want to know about what differentiates regions from each other
ggbiplot(passage_prcomp, scale = 0, var.axes = FALSE, group = members$region)

## try LDA on the passage votes
passage_lda = lda(x = votes_passage[, c(-1, -27, -50)], grouping = members$region)

## how accurate is our LDA model?
table(predict(passage_lda)$class, members$region)

## which bills are important? How do we interpret the biplot?
ggbiplot(passage_lda, groups = members$region)
ggbiplot(passage_lda, groups = members$region, choices = c(1,3))

## let's look one bill that looks important for discriminating between regions
## It actually seems to be quite bad from an interpretation point of view: almost everyone voted the same way on this bill, with one abstention
s28 = votes[,"s28.106.1999"]

## To solve the problem above, we want to filter to competitive votes
## The first thing to do is to make a make a function to describe competitive votes

## The function will take one of the columns of the votes_recoded matrix and return TRUE if between .25 and .75 of the votes were "yes" (coded as 1), and FALSE otherwise
competitive_votes = function(x) {
    frac_yea = mean(x == 1, na.rm = TRUE)
    if(frac_yea >= .25 & frac_yea <= .75)
        return(TRUE)
    return(FALSE)
}
## Then we can use the apply function (first argument the data, second argument 2 means that we want the function to act on the columns of the data matrix, and third argument the function that we want to apply) to find which of the passage votes were competitive.
which_competitive_votes = apply(votes_passage, 2, competitive_votes)

## Finall we can do LDA on just the competitive votes
competitive_lda = lda(x = votes_passage[,which_competitive_votes], grouping = members$region)
## biplot on the competitive votes LDA
ggbiplot(competitive_lda, groups = members$region)
## predictive accuracy is not as good for this model
table(predict(competitive_lda)$class, members$region)
## who voted for s293? (the variable with the strongest loading on the second discriminant axis, separating western states)
table(votes[,"s293.106.1999"], members$region)
