library(boot)

iso = read.csv("isotope.csv")
iso_young = subset(iso, age <= 10)

## computing the statistic from the data
loess_out = loess(d15N ~ age, data = iso_young, span = .5)
age_seq = seq(0, 10, length.out = 100)
loess_preds = predict(loess_out, newdata = data.frame(age = age_seq))
loess_df = data.frame(age = age_seq, pred = loess_preds)
age_at_max = age_seq[which.max(loess_preds)]


ggplot(iso_young) + geom_point(aes(x = age, y = d15N))
ggplot(iso_young) + geom_point(aes(x = age, y = d15N)) +
    geom_line(aes(x = age, y = pred), color = "blue", data = loess_df)

## writing a function to compute the statistic
get_age_at_max = function(data, i) {
    loess_out = loess(d15N ~ age, data = data[i,], span = .5)
    age_seq = seq(0, 10, length.out = 100)
    loess_preds = predict(loess_out, newdata = data.frame(age = age_seq))
    loess_df = data.frame(age = age_seq, pred = loess_preds)
    age_at_max = age_seq[which.max(loess_preds)]

}
boot_out = boot(data = iso_young, statistic = get_age_at_max, R = 1000)
## by hand 95% confidence intervals
quantile(boot_out$t, c(.025, .975))
## using the function in the package
boot.ci(boot_out)
