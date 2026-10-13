# Sufficiency and conditional dependence, and how to diagnose it in plots

Suppose we have a family of models indexed by $\theta$, and our data $X$ comes from $P_\theta$.
Let $S$ be a statistic (a function of the data alone).

## Sufficiency

**Definition** $S$ is sufficient for $\theta$ if the distribution $X \mid S$ does not depend on $\theta$.
It can (and generally does), depend on $S(X)$.
Another way of saying this is that for each possible value $s = S(X)$, where is a distribution $Q_s$ such that for every parameter value, $(X \mid S(X) = s) \sim Q_s$.

The general interpretation is that a sufficient statistic contains all the information we need to infer $\theta$.

**Example** (Rather silly): The full data is always sufficient.
If we take $S(X) = X$, our "sufficient statistic" is just the original data.
We have done no reduction in this case.
To check the definition, we need to be able to describe the conditional distribution $X \mid S(X)$.
This turns out to be particularly simple: if $S(X) = X$, then the distribution of $X \mid S(X) = s$ is the same as the distribution of $X \mid X = s$.
This is technically a distribution, but it is one with no variation, it's just $X = s$ with probability 1.
This clearly depends on $s$ but not on $\theta$, so the full data is sufficient.

**Example** If $X = (X_1,\ldots, X_n)$ with the $X_i$ independent $\text{Bernoulli}(\theta)$ random variables, then $S(X) = \sum_{i=1}^n X_i$ is sufficient.
This takes a little bit more probability than we have seen in the course, but if we work out the distribution of $X \mid S(X) = s$, it turns out to be the uniform distribution over all sequences with $s$ of the $X_i$'s equal to 1.
These distributions again depend on $s$ but not on $\theta$, and so $S(X) = \sum_{i=1}^n X_i$ is sufficient.

## Bayes sufficiency

Suppose we are in the Bayesian setup, where we have
$$
\theta \sim \pi, \quad X \mid \theta \sim P_\theta.
$$

**Definition** (Bayes sufficiency). For this model, $S$ is Bayes sufficient for $\theta$ if $\theta \perp \!\!\! \perp X \mid S$. (Read that $\theta$ and $X$ are conditionally independent given $S$).

Ordinary sufficiency implies Bayes sufficiency for every prior.
Bayes sufficiency for one prior can be weaker (for example, when the prior places zero mass on some parameter values).

If we have an observed dataset $x$, Bayes sufficiency implies that the distribution $\theta \mid X = x$ is the same as the distribution $\theta \mid S(X) = S(x)$.
That is, the posterior distribution is the same whether we condition on the full data or on the sufficient statistic.


## Visual and quantitative checks for independence

We are going to want to try to use these definitions to create diagnostic criteria or plots for sufficiency.
Therefore, we are going to need to know how to visualize or otherwise diagnose independence and conditional independence.
We start with independence before moving on to conditional independence.

Consider two scalar random variables $Y$ and $Z$.
The definition of independence says that for any (measurable) set $A$ and $B$, $P(Y \in A, Z \in B) = P(Y \in A)P(Z \in B)$.

Equivalently, the distribution of $Z$ is the same at almost every value of $Y$, and the distribution of $Y$ is the same at almost every value of $Z$ (with almost every being a technical term from probability).

Suppose we simulated a large number of pairs of these random variables and plotted them.
The visual translation of "the distribution of $Y$ is the same at almost every value of $Z$" is: divide the plot up into little strips corresponding to intervals around a collection of potential values of $Y$.
Is the distribution of $Z$ within each of those strips the same or different?
If the distributions are noticeably different, then we have visual evidence that $Y$ and $Z$ are not independent.
If they look quite similar, our visual check hasn't given us evidence that the two are not independent.

$Y$ and $Z$ play interchangeable roles, so we could also cut the plot up into little strips corresponding to intervals around various values of $Z$ and check whether the distribution of $Y$ within each of those strips look the same or different.

The same definition of conditional independence can be changed into a quantitative check that a computer can run.
For any given rectangle $Y \in A, Z \in B$, we can compute the fraction of our simulations that satisfied that condition.
We can also compute the fraction of simulations that satisfied $Y \in A$ and the fraction of simulations that satisfied $Z \in B$.
Then the product of the estimated marginals can be compared to the estimated joint to see if the numbers are similar.
(There are also corresponding statistical tests so that you can take into account the expected variability.)

## Visual and quantitative checks for conditional independence given a discrete random variable

Suppose now that we have random variables $Y$, $Z$, and $S$, where $S$ is a discrete random variable.

We have a way of simulating from the joint distribution of $(Y, Z, S)$, and we would like to check whether $Y  \perp \!\!\! \perp  Z \mid S = s$.
How might we do this?

Conditioning on $S = s$ just means simulating from the joint distribution of $(Y, Z, S)$ and throwing away all the runs that didn't satisfy $S = s$.
To check conditional independence, we can therefore rejection $(Y, Z, S)$ conditional on $S = s$, and make the same sort of plot of $Y$ and $Z$ using the accepted samples that we described before.

The same visual and quantitative diagnostics apply to that plot/set of samples of $(Y, Z)$.


## Visual and quantitive checks for conditional independence given a continuous random variable

