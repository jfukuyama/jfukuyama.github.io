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
    sub_matrix = mat[,start_idx:end_idx]
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


birth_year = extract_variable(9, 12, char_matrix)
mothers_age = extract_variable(75, 76, char_matrix)
gest_age = extract_variable(492, 493, char_matrix, na.val = 99)
