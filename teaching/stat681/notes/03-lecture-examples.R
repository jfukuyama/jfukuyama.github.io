## =============================================================
## STAT-S681 -- Lecture 3: From Models to Simulators
## Runnable lecture-code companion (R)
##
## Five examples, paired with the "From Models to Simulators" slides:
##   1. Bernoulli trials and their sum
##   2. A two-state hidden Markov model with normal observations
##   3. A Markov (bigram) language model
##   4. A topic model
##   5. A discrete-time SIR epidemic model
##
## Run this script top to bottom. No external data files needed, and no
## packages beyond base R.
## =============================================================

set.seed(681)  # set once, here -- never inside a simulator function

## =============================================================
## Example 1: Bernoulli trials and their sum
## =============================================================
##
## Model:
##   X_i ~iid Bernoulli(p),  i = 1, ..., n
##   Y = sum_i X_i
##
## Supplied: n, p
## Random:   X_1, ..., X_n, and Y (Y is random too -- it's a
##           deterministic *function* of the X_i's, but a deterministic
##           function of a random variable is still random)
## Computed: Y, from X_1, ..., X_n

n <- 20
p <- 0.3

## Generate the n individual trials
x <- rbinom(n, size = 1, prob = p)
x

## The total is a deterministic function of the trials already generated
y <- sum(x)
y

## Inspect what we generated
table(x)
mean(x)  # should be near p, but won't equal it exactly

## ---- A second implementation: generate only the total ----
## Same model, shorter code -- this never creates x_1, ..., x_n.
y_short <- rbinom(1, size = n, prob = p)
y_short

## Check the claim: repeat both implementations many times and
## compare the resulting distributions.
n_rep <- 2000
y_long_rep  <- replicate(n_rep, sum(rbinom(n, size = 1, prob = p)))
y_short_rep <- replicate(n_rep, rbinom(1, size = n, prob = p))

par(mfrow = c(1, 2))
hist(y_long_rep,  main = "sum of n Bernoullis",    xlab = "y", breaks = -0.5:(n + 0.5))
hist(y_short_rep, main = "single Binomial(n,p) draw", xlab = "y", breaks = -0.5:(n + 0.5))
par(mfrow = c(1, 1))


## =============================================================
## Example 2: A two-state hidden Markov model
## =============================================================
##
## Model:
##   Z_1 ~ Categorical(pi)
##   Z_t | Z_{t-1} ~ Categorical(A[Z_{t-1}, ]),  t = 2, ..., T
##   Y_t | Z_t = k ~ Normal(mu_k, sigma_k^2)
##
## Supplied: pi (initial-state probabilities), A (transition matrix),
##           mu, sigma (state-specific observation parameters), T
## Latent:   Z_1, ..., Z_T
## Observed: Y_1, ..., Y_T
##
## Concrete story: Z_t is which regime the economy is in this quarter
## (1 = recession, 2 = expansion), and Y_t is a noisy observed
## indicator -- quarterly GDP growth (%) -- whose typical level and
## volatility depend on the regime. We see Y_t; the regime itself is
## never directly observed. This is a real macroeconomics model
## (Hamilton, 1989).
##
## Written as an explicit loop, with no HMM package, so every random
## draw is visible.

simulate_hmm <- function(n_steps, pi, A, mu, sigma) {
  n_states <- length(pi)
  z <- integer(n_steps)
  y <- numeric(n_steps)

  ## Initial state: depends only on pi
  z[1] <- sample.int(n_states, size = 1, prob = pi)
  y[1] <- rnorm(1, mean = mu[z[1]], sd = sigma[z[1]])

  ## Every later state depends on the *previous* state;
  ## every observation depends on the *current* state.
  for (t in 2:n_steps) {
    z[t] <- sample.int(n_states, size = 1, prob = A[z[t - 1], ])
    y[t] <- rnorm(1, mean = mu[z[t]], sd = sigma[z[t]])
  }

  list(z = z, y = y)
}

## Small, concrete parameters: state 1 is "recession", state 2 is
## "expansion", and both regimes are fairly persistent (the diagonal of
## A is large) -- recessions and expansions both tend to last a while.
pi_init <- c(0.5, 0.5)
A <- matrix(
  c(0.95, 0.05,   # from recession: stay w.p. .95, shift to expansion w.p. .05
    0.10, 0.90),  # from expansion: shift to recession w.p. .10, stay w.p. .90
  nrow = 2, byrow = TRUE
)
mu <- c(-1, 3)     # average quarterly GDP growth (%): recession, expansion
sigma <- c(1.5, 1) # recessions are also more volatile
n_steps <- 100

sim1 <- simulate_hmm(n_steps, pi_init, A, mu, sigma)

## Plot the latent regime and observed GDP growth in aligned panels
plot_hmm_run <- function(sim, title_suffix = "") {
  par(mfrow = c(2, 1), mar = c(2, 4, 2, 1))
  plot(sim$z, type = "s", ylim = c(0.5, 2.5), yaxt = "n",
       ylab = "regime", xlab = "",
       main = paste("Latent regime (1 = recession, 2 = expansion)", title_suffix))
  axis(2, at = c(1, 2))
  plot(sim$y, type = "l", ylab = "GDP growth (%)", xlab = "quarter",
       main = paste("Observed GDP growth", title_suffix))
  par(mfrow = c(1, 1))
}

plot_hmm_run(sim1)

## ---- A second run, same parameters ----
## The rule generating the data (pi, A, mu, sigma) is exactly the same
## as above. Only the realization -- the actual sequence of states and
## observations -- differs.
sim2 <- simulate_hmm(n_steps, pi_init, A, mu, sigma)
plot_hmm_run(sim2, title_suffix = "(second run, same parameters)")


## =============================================================
## Example 3: A Markov (bigram) language model
## =============================================================
##
## Model:
##   P(w_1, ..., w_T) = P(w_1) * prod_{t=2}^T P(w_t | w_{t-1})
##
## Supplied: the transition table P(w_t | w_{t-1}), estimated below from
##           a short piece of real text
## Random:   every w_t
##
## We estimate the transition table from actual text (word counts), then
## treat that table as a *fixed, supplied* parameter and simulate new
## sequences from it. Today we only supply parameters and simulate;
## estimating parameters properly from data is Thursday's topic -- this
## is a preview, not the real thing.

## A short public-domain passage (Lewis Carroll, "Alice's Adventures in
## Wonderland," opening lines, 1865) -- real text, not made up.
corpus_text <- "Alice was beginning to get very tired of sitting by her
sister on the bank, and of having nothing to do: once or twice she had
peeped into the book her sister was reading, but it had no pictures or
conversations in it, and what is the use of a book, thought Alice,
without pictures or conversations?"

## Clean and tokenize: lowercase, strip punctuation, split on whitespace
tokens <- tolower(corpus_text)
tokens <- gsub("[[:punct:]]", "", tokens)
tokens <- strsplit(tokens, "\\s+")[[1]]
tokens <- tokens[tokens != ""]

vocab <- sort(unique(tokens))
n_vocab <- length(vocab)

## Count bigram transitions: how often is word j immediately followed
## by word k in the passage?
bigram_counts <- matrix(0, nrow = n_vocab, ncol = n_vocab,
                         dimnames = list(vocab, vocab))
for (t in seq_len(length(tokens) - 1)) {
  from <- tokens[t]
  to   <- tokens[t + 1]
  bigram_counts[from, to] <- bigram_counts[from, to] + 1
}

## Normalize each row into a probability vector: P(. | word) for each
## starting word. A row of all zeros means that word was never observed
## followed by anything (it only ever appeared last).
row_sums <- rowSums(bigram_counts)
transition_prob <- bigram_counts / ifelse(row_sums == 0, 1, row_sums)

## In this short passage, how many distinct successors did each word
## actually get observed with?
n_successors <- rowSums(bigram_counts > 0)
table(n_successors[row_sums > 0])
## Most words here were seen with only one successor. This sparsity --
## most contexts observed once or not at all -- is exactly the problem
## that motivates the neural language models on the slides, which share
## parameters across contexts instead of estimating a separate
## distribution for each one.

## Simulate a new sequence: current token -> sample next token ->
## append -> repeat.
simulate_markov_text <- function(n_tokens, start_word, transition_prob, vocab) {
  generated <- character(n_tokens)
  generated[1] <- start_word
  for (t in 2:n_tokens) {
    current <- generated[t - 1]
    probs <- transition_prob[current, ]
    if (sum(probs) == 0) {
      ## This word was never seen followed by anything in the passage;
      ## restart from a uniformly chosen word rather than getting stuck.
      generated[t] <- sample(vocab, 1)
    } else {
      generated[t] <- sample(vocab, 1, prob = probs)
    }
  }
  generated
}

cat(paste(simulate_markov_text(15, "alice", transition_prob, vocab), collapse = " "), "\n")
cat(paste(simulate_markov_text(15, "alice", transition_prob, vocab), collapse = " "), "\n")


## =============================================================
## Example 4: A topic model
## =============================================================
##
## Model:
##   theta_d ~ Dirichlet(alpha)                    for each document d
##   z_{d,n} ~ Categorical(theta_d)                for each word n
##   w_{d,n} ~ Categorical(beta_{z_{d,n}})
##
## Supplied: alpha (Dirichlet concentration), beta (topic x word
##           matrices), number of documents, words per document
## Latent:   theta_d (topic proportions), z_{d,n} (topic assignments)
## Observed: w_{d,n} (words)
##
## No topic-model package or real corpus is used here. `beta` is chosen
## by hand to be clearly interpretable -- one topic is sports-flavored,
## the other cooking-flavored -- rather than fit to data, so we already
## know the "ground truth" latent structure the model is generating from.

vocab_topics <- c("ball", "goal", "team", "score", "coach",
                   "recipe", "oven", "bake", "kitchen", "dish")

## Rows are topics, columns are words in vocab_topics; each row sums to 1.
beta <- rbind(
  sports  = c(0.28, 0.24, 0.20, 0.18, 0.10,  0.00, 0.00, 0.00, 0.00, 0.00),
  cooking = c(0.00, 0.00, 0.00, 0.00, 0.00,  0.24, 0.22, 0.22, 0.16, 0.16)
)
colnames(beta) <- vocab_topics

## Base R has no rdirichlet(); draw one by drawing independent Gammas
## and normalizing -- a standard construction of the Dirichlet.
rdirichlet1 <- function(alpha) {
  g <- rgamma(length(alpha), shape = alpha, rate = 1)
  g / sum(g)
}

simulate_topic_model <- function(n_docs, n_words_per_doc, alpha, beta) {
  n_topics <- nrow(beta)
  documents <- vector("list", n_docs)
  topic_proportions <- matrix(NA, nrow = n_docs, ncol = n_topics,
                               dimnames = list(NULL, rownames(beta)))

  for (d in seq_len(n_docs)) {
    theta_d <- rdirichlet1(alpha)   # this document's topic mixture
    topic_proportions[d, ] <- theta_d

    z <- sample.int(n_topics, size = n_words_per_doc, replace = TRUE, prob = theta_d)
    w <- character(n_words_per_doc)
    for (n in seq_len(n_words_per_doc)) {
      w[n] <- sample(colnames(beta), 1, prob = beta[z[n], ])
    }
    documents[[d]] <- w
  }

  list(documents = documents, topic_proportions = topic_proportions)
}

alpha <- c(sports = 1, cooking = 1)  # symmetric Dirichlet prior
sim_topics <- simulate_topic_model(n_docs = 4, n_words_per_doc = 12,
                                    alpha = alpha, beta = beta)

## Look at each generated document alongside the topic mixture that
## produced it.
for (d in seq_along(sim_topics$documents)) {
  cat("Document", d, "-- theta:",
      round(sim_topics$topic_proportions[d, ], 2), "\n")
  cat(" ", paste(sim_topics$documents[[d]], collapse = " "), "\n\n")
}


## =============================================================
## Example 5: A discrete-time SIR epidemic model
## =============================================================
##
## Model, in discrete time steps t = 0, 1, ..., T, with population size
## N = S_t + I_t + R_t fixed throughout:
##
##   Delta I_t | S_t, I_t ~ Binomial(S_t, 1 - (1 - beta / N)^{I_t})
##   Delta R_t | I_t      ~ Binomial(I_t, gamma)
##
##   S_{t+1} = S_t - Delta I_t
##   I_{t+1} = I_t + Delta I_t - Delta R_t
##   R_{t+1} = R_t + Delta R_t
##
## Supplied: beta, gamma, S_0, I_0, R_0, number of steps T
## Random:   Delta I_t, Delta R_t at every step, and S_t, I_t, R_t
##           themselves (each is a deterministic function of earlier
##           draws, but still random, since those draws are)
## Computed: S_{t+1}, I_{t+1}, R_{t+1}, from S_t, I_t, R_t and the draws
##
## Every step is exactly two binomial draws -- the same building block
## as Example 1. 1 - (1 - beta/N)^{I_t} is the probability that a given
## susceptible individual is infected by at least one of the I_t
## currently infectious individuals this step, if each infectious
## individual independently infects each susceptible one with
## probability beta/N.

simulate_sir <- function(n_steps, beta, gamma, S0, I0, R0) {
  N <- S0 + I0 + R0

  S <- integer(n_steps + 1)
  I <- integer(n_steps + 1)
  R <- integer(n_steps + 1)
  S[1] <- S0
  I[1] <- I0
  R[1] <- R0

  for (t in seq_len(n_steps)) {
    p_infect <- 1 - (1 - beta / N)^I[t]
    delta_I  <- rbinom(1, S[t], p_infect)
    delta_R  <- rbinom(1, I[t], gamma)

    S[t + 1] <- S[t] - delta_I
    I[t + 1] <- I[t] + delta_I - delta_R
    R[t + 1] <- R[t] + delta_R
  }

  data.frame(time = 0:n_steps, S = S, I = I, R = R)
}

## An epidemic that takes off: beta / gamma > 1
sir1 <- simulate_sir(n_steps = 100, beta = 0.3, gamma = 0.1,
                      S0 = 995, I0 = 5, R0 = 0)

plot(sir1$time, sir1$S, type = "l", col = "steelblue", ylim = c(0, sum(sir1[1, 2:4])),
     xlab = "time", ylab = "count", main = "Discrete-time SIR (beta = 0.3, gamma = 0.1)")
lines(sir1$time, sir1$I, col = "firebrick")
lines(sir1$time, sir1$R, col = "darkgreen")
legend("right", legend = c("S", "I", "R"),
       col = c("steelblue", "firebrick", "darkgreen"), lty = 1)

## ---- What happens below the epidemic threshold? ----
## Same recovery rate, much lower transmission rate: beta / gamma < 1.
sir2 <- simulate_sir(n_steps = 100, beta = 0.08, gamma = 0.1,
                      S0 = 995, I0 = 5, R0 = 0)

plot(sir2$time, sir2$I, type = "l", col = "firebrick",
     xlab = "time", ylab = "I(t)",
     main = "Same model, beta = 0.08, gamma = 0.1")
