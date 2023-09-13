library(stringr)

# A function to split and trim keywords from Scopus
split_keywords <- function(keywords, sep="\\W+", remove.duplicates=T, remove.terms=c("")) {
  wordlist <- str_trim(strsplit(keywords, sep)[[1]])
  wordlist <- list_unique(wordlist)
  wordlist[!wordlist %in% remove.terms]
}

make_word_table <- function(x, min.Freq=1, sep="\\W+", remove.terms = c("")) {
  # count total number of items
  corpus_size <- length(x)

  # convert all to lowercase to avoid case conflicts
  x <- tolower(x)

  # split text into words/keywords
  wordlists <- sapply(x, split_keywords, sep=sep, remove.terms = remove.terms)
  tab <- sort(table(unlist(wordlists)), decreasing=T)

  tab <- table_to_matrix(tab)
  percents <- 100.00*tab/corpus_size
  tab <- cbind(tab,percents)
  colnames(tab) <- c("Freq", "Rel.Freq")
  tab <- as.data.frame(tab)
  tab <- subset(tab, Freq >= min.Freq)
  tab
}

subwords <- function(x, corpus) {
  list_unique(sapply(x, function(w) corpus[str_detect(corpus, w)]))
}

# find_synonyms <- function(keywords) {

# ### Find synonym keywords
# # find words that end with those words
#   LARGER <- c(keywords, "XXXX")
#   SMALLER <- c("XXXX", keywords)
# # plurals with s
#   (singulars <- SMALLER[LARGER == paste0(SMALLER,"s")])
#   syn1 <- paste0(singulars,";",singulars,"s")
# # plurals with es
#   (singulars2 <- SMALLER[LARGER == paste0(SMALLER,"es")])
#   syn2 <- paste0(singulars2,";",singulars2,"es")
# # plurals with y->ies
#   candidates <- endsWith(LARGER,"y") & endsWith(SMALLER,"ies")
#   candidates <- candidates & str_sub(LARGER, 1, -2) == str_sub(SMALLER, 1, -4)
#   syn3 <- paste0(SMALLER[candidates],";",LARGER[candidates])
#   (subkeys <- LARGER[which(startsWith(LARGER, SMALLER))])

# }