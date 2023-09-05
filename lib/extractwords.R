library(stringr)

# A function to split and trim keywords from Scopus
split_keywords <- function(keywords, sep="\\W+") {
  str_trim(strsplit(keywords, sep)[[1]])
}

make_word_table <- function(x, cutoff=F, sep="\\W+", count.repeated=F) {
  # convert all to lowercase to avoid case conflicts
  x <- tolower(x)
  wordlists <- sapply(x, split_keywords, sep=sep)
  if (!count.repeated) {
    wordlists <- sapply(wordlists, list_unique)
  }
  tab <- sort(table(unlist(wordlists)), decreasing=T)
  if (cutoff) {
    tab <- tab[1:cutoff]
  }
  tab
}