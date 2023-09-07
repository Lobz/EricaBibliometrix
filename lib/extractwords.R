library(stringr)
library(tm)

# A function to split and trim keywords from Scopus
split_keywords <- function(keywords, sep="\\W+") {
  str_trim(strsplit(keywords, sep)[[1]])
}

make_word_table <- function(x, cutoff=F, sep="\\W+") {
  # count total number of items
  corpus_size <- length(x)

  # convert all to lowercase to avoid case conflicts
  x <- tolower(x)

  # split text into words/keywords
  wordlists <- sapply(x, split_keywords, sep=sep)
  wordlists <- sapply(wordlists, list_unique)
  tab <- sort(table(unlist(wordlists)), decreasing=T)


  if (cutoff) {
    tab <- tab[1:cutoff]
  }

  tab <- table_to_matrix(tab)
  percents <- 100.00*tab/corpus_size
  tab <- cbind(tab,percents)
  colnames(tab) <- c("Freq", "Rel.Freq")
  as.data.frame(tab)
}
