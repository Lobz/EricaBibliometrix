# Consolidated data file name
dataFilenameCSV <- "./input/scopus2023_09_12.csv"
dataFilenameRData <- "./input/scopus2023_09_12.RData"
# Included files folder
libDir <- "lib"
# load all files listed in libs
sapply(list.files(libDir, full.names = T), source)

# load data
load(dataFilenameRData)
#data <- my_read.csv(dataFilenameCSV)
names(data)

### Subgroups
#climateChangeGroup = climate change OR blue C OR greenhouse gas mitigation OR carbon stock OR carbon sink
climateChangeWords <- c("climate change", "blue carbon", "greenhouse gas mitigation", "carbon stock", "carbon sink", "carbon sequestration")
#recoveryGroup = recovery OR microbial succession OR reforest OR replant
recoveryWords <- c("recovery", "microbial succession", "reforestation", "replanting", "restoration", "remediation")

### Plot by year (barplot)
lastYear <- max(data$Year)
firstYear <- min(data$Year)
numberofyears <- lastYear - firstYear +1
yearFreq <- table(data$Year)
plot(yearFreq, main="", xlab="Time", ylab="Number of articles", type="l")
savePlot("./output/pubsbyyear.png")




### Extract keywords (set sep as the separator between keywords)
(keywordTab <- make_word_table(data$Index.Keywords, min.Freq = 1, sep = "; "))
(authorKeywordTab <- make_word_table(data$Author.Keywords, min.Freq = 1, sep = "; "))

## how many keywords to plot in the barplot
maxwords <- 10

par(mar=c(5,12,1,1))
barplot(keywordTab$Rel.Freq[1:maxwords], col = 1, xlab = "Percentage of publications", names.arg = row.names(keywordTab)[1:maxwords], horiz=T, las=2)
savePlot("output/indexkeywords.png")

par(mar=c(5,12,1,1))
barplot(authorKeywordTab$Rel.Freq[1:maxwords], col = 1, xlab = "Percentage of publications", names.arg = row.names(authorKeywordTab)[1:maxwords], horiz=T, las=2)
savePlot("output/authorkeywords.png")

### Find a list of keywords containing the keywords for each group:
keywords <- list_unique(c(rownames(keywordTab), (rownames(authorKeywordTab))))
write(keywords, "./output/keywords.txt")
climateChangeKeywords <- subwords(climateChangeWords, keywords)
recoveryKeywords <- subwords(recoveryWords, keywords)

### Set a variable to list if a document in in each group
wordlistsAK <- make_wordslist(data$Author.Keywords, sep="; ")
wordlistsIK <- make_wordslist(data$Index.Keywords, sep="; ")
data$climateKeywords <- contains_any(wordlistsAK, climateChangeKeywords) | contains_any(wordlistsIK, climateChangeKeywords)
data$recoveryKeywords <- contains_any(wordlistsAK, recoveryKeywords) | contains_any(wordlistsIK, recoveryKeywords)

### Extract word from text
my_stopwords = bibliometrix::stopwords$en
titleWords <- make_word_table(data$Title, min.Freq=1, remove.terms = my_stopwords)
abstractWords <- make_word_table(data$Abstract,  min.Freq=1, remove.terms = my_stopwords)
words <- list_unique(c(rownames(titleWords),rownames(abstractWords)))
write(words, "./output/words.txt")

### Set a variable to list if a document contain any words in each group


#### Plots/tables we want:
# Pubs per year


# Top journals
# Pubz per year per subject

res <- fieldByYear(M, field = "ID", min.freq = 10, n.items = 10, graph = TRUE)
# Table of most cited pubs
# Distribution of citation and author afilliation
# Country of origin?
# Most used words (title, auth-keyword, ind-keywords, separate tables)

#### Group plots:
# Group prevalence per year
#