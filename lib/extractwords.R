library(stringr)

# A function to split and trim keywords from Scopus
split_keywords <- function(keywords, sep=";") str_trim(strsplit(keywords, sep)[[1]])