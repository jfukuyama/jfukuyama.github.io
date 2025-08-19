library(MASS)
library(magrittr)
gen.1 <- aov(Wt ~ Litter * Mother, genotype)
gen.2 <- aov(Wt ~ Mother * Litter, genotype)

summary(gen.1)
summary(gen.2)

drop1(gen.1, . ~ .)
drop1(gen.2, . ~ .)

model.matrix(gen.1)
model.matrix(gen.2)

fit.1 <- lm(genotype$Wt ~ 0 + model.matrix(gen.1)) %>% fitted
fit.1.nolitter <- lm(genotype$Wt ~ 0 + model.matrix(gen.1)[,c(1, 5:16)]) %>% fitted
fit.1.nomother <- lm(genotype$Wt ~ 0 + model.matrix(gen.1)[,c(1:4, 8:16)]) %>% fitted
fit.1.nointeraction <- lm(genotype$Wt ~ 0 + model.matrix(gen.1)[,1:7]) %>% fitted

sum(fit.1^2) - sum(fit.1.nolitter^2)
sum(fit.1^2) - sum(fit.1.nomother^2)
sum(fit.1^2) - sum(fit.1.nointeraction^2)
drop1(gen.1, . ~ .)


### Repeat with Helmert contrasts
op <- options(contrasts = c("contr.helmert", "contr.poly"))

gen.1.1 <- aov(Wt ~ Litter*Mother, genotype)
gen.2.1 <- aov(Wt ~ Mother*Litter, genotype)

summary(gen.1.1)
summary(gen.2.1)

drop1(gen.1.1, . ~ .)
drop1(gen.2.1, . ~ .)

model.matrix(gen.1.1)
model.matrix(gen.2.1)

fit.1.1 <- lm(genotype$Wt ~ 0 + model.matrix(gen.1.1)) %>% fitted
fit.1.1.nolitter <- lm(genotype$Wt ~ 0 + model.matrix(gen.1.1)[,c(1, 5:16)]) %>% fitted
fit.1.1.nomother <- lm(genotype$Wt ~ 0 + model.matrix(gen.1.1)[,c(1:4, 8:16)]) %>% fitted
fit.1.1.nointeraction <- lm(genotype$Wt ~ 0 + model.matrix(gen.1.1)[,1:7]) %>% fitted

sum(fit.1.1^2) - sum(fit.1.1.nolitter^2)
sum(fit.1.1^2) - sum(fit.1.1.nomother^2)
sum(fit.1.1^2) - sum(fit.1.1.nointeraction^2)
drop1(gen.1.1, . ~ .)
drop1(gen.2.1, . ~ .)

### plotting


ggplot(genotype) +
    geom_point(aes(x = Mother, y = lm(Wt ~ 1, data = genotype) %>% fitted))
ggplot(genotype) +
    geom_point(aes(x = Mother, y = lm(Wt ~ Mother, data = genotype) %>% fitted))
ggplot(genotype) +
    geom_point(aes(x = Mother,
                   y = lm(Wt ~ Litter, data = genotype) %>% fitted,
                   color = Litter))
ggplot(genotype) +
    geom_point(aes(x = Mother,
                   y = lm(Wt ~ Mother + Litter, data = genotype) %>% fitted,
                   color = Litter))
ggplot(genotype) +
    geom_point(aes(x = Mother,
                   y = lm(Wt ~ Mother * Litter, data = genotype) %>% fitted,
                   color = Litter))

ggplot(genotype) + geom_point(aes(x = Mother,
                                  y = fit.1.1.nomother,
                                  color = Litter))
dev.new()
ggplot(genotype) + geom_point(aes(x = Mother,
                                  y = fit.1.nomother,
                                  color = Litter))
