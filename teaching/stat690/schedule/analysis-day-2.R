library(stringr)
library(magrittr)
num = read.delim("VS15LKBC.PublicUse.USNUMPUB_2019_11_25")
## we want to separate all the characters into individual elements
separated = str_extract_all(string = num[,1], pattern = boundary("character"))
char_matrix = matrix("",
                     nrow = length(separated),
                     ncol = length(separated[[1]]))
for(i in 1:length(separated)) {
    char_matrix[i,] = separated[[i]]
}

extract_variable = function(start_idx, end_idx, mat,
                            numeric = TRUE, na.val = NA) {
    sub_matrix = mat[,start_idx:end_idx, drop = FALSE]
    variable_char = apply(sub_matrix, 1, paste, collapse = "")
    if(numeric) {
        variable = as.numeric(variable_char)
        if(!is.na(na.val)) {
            variable[variable == na.val] = NA
        }
        return(variable)
    }
    return(variable_char)
}


mothers_age = extract_variable(75, 76, char_matrix)
prior_live = extract_variable(171, 172, char_matrix, na.val = 99)


plurality = extract_variable(454, 454, char_matrix)
gest_age = extract_variable(490, 491, char_matrix, na.val = 99)
gest_age_recode = extract_variable(492, 493, char_matrix, na.val = 99)
birth_weight = extract_variable(512, 515, char_matrix, na.val = 9999)

df = data.frame(mothers_age, prior_live, plurality, gest_age, gest_age_recode, birth_weight)

ggplot(df) + geom_jitter(aes(x = gest_age, y = log(birth_weight)), alpha = .1)
ggplot(df) + geom_jitter(aes(x = gest_age, y = birth_weight), alpha = .1)

ggplot(df) + geom_jitter(aes(x = gest_age, y = log(birth_weight)), alpha = .1) + facet_wrap(~ plurality)
ggplot(df, aes(x = gest_age, y = log(birth_weight), color = factor(plurality))) + geom_jitter(alpha = .1) + stat_smooth(method = "lm")
ggplot(df, aes(x = gest_age, y = log(birth_weight))) + geom_jitter(alpha = .1) + facet_wrap(~ plurality) + stat_smooth(method = "lm")

