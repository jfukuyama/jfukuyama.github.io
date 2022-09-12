## Question 1

mutations_per_sequence <- function(start_seq, end_seq) {
    ## fill in this part ##
    
    return(num_mutations)
}

## Question 2

## Assume that transition_matrix is a matrix with row and column names (like T below).
## Notice that you can refer to the rows and columns by name in addition to index.
## With T as defined in question 3 below, T["A", "A"] is the 1,1 element of T, T["G", "T"] is the 2,3 element, and so on.
## Using this behavior will make writing this function simpler.

sequence_divergence <- function(start_seq, end_seq, transition_matrix) {
    ## fill in this part ##

    return(divergence)
}


## Question 3

## Use this matrix T as the transition_matrix in the sequence_divergence function.
T <- matrix(c(.93, .05, .01, .01, .05, .93, .01,.01,
             .01, .01, .93, .05, .01, .01, .05, .93))
rownames(T) <- colnames(T) <- c("A", "G", "T", "C")

sequences <- read.csv("sequences.csv", stringsAsFactors = FALSE)
germline <- readLines("germline.txt")

## Question 4
