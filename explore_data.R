# Consolidated data file name
dataFilenameCSV <- "./input/scopus2023_09_12.csv"
dataFilenameRData <- "./input/scopus2023_09_12.RData"
# Included files folder
libDir <- "lib"
# load all files listed in libs
sapply(list.files(libDir, full.names = T), source)

# load data
load(dataFilenameRData)
# data <- my_read.csv(dataFilenameCSV)
names(M)

### Subgroups defined by presence of these terms in Title or Abstract or Keywords, or terms containing these in Keywords
climateChangeWords <- c("climate change", "blue carbon", "greenhouse gas mitigation", "carbon stock", "carbon sink", "carbon sequestration")
recoveryWords <- c("recovery", "microbial succession", "reforestation", "replanting", "restoration", "remediation")


### Extract keywords (set sep as the separator between keywords)
(keywordTab <- make_word_table(M$ID, min.Freq = 1, sep = "; "))
write.csv(keywordTab[1:200,], "./output/IDkeywordTable.csv")
(authorKeywordTab <- make_word_table(M$DE, min.Freq = 1, sep = "; "))
write.csv(authorKeywordTab[1:200,], "./output/AUkeywordTable.csv")

### Find a list of keywords containing the keywords for each group:
keywords <- list_unique(c(rownames(keywordTab), (rownames(authorKeywordTab))))
write(keywords, "./output/keywords.txt")
climateChangeKeywords <- subwords(climateChangeWords, keywords)
recoveryKeywords <- subwords(recoveryWords, keywords)

### Set a variable to list if a document in in each group
wordlistsAK <- make_wordslist(M$DE, sep="; ")
wordlistsIK <- make_wordslist(M$ID, sep="; ")
M$climateKeywords <- contains_any(wordlistsAK, climateChangeKeywords) | contains_any(wordlistsIK, climateChangeKeywords)
M$recoveryKeywords <- contains_any(wordlistsAK, recoveryKeywords) | contains_any(wordlistsIK, recoveryKeywords)

### Extract word from text
my_stopwords = bibliometrix::stopwords$en
titleWords <- make_word_table(M$TI, min.Freq=1, remove.terms = my_stopwords)
abstractWords <- make_word_table(M$AB,  min.Freq=1, remove.terms = my_stopwords)
words <- list_unique(c(rownames(titleWords),rownames(abstractWords)))
write(words, "./output/words.txt")

### Set a variable to list if a document contain any words in each group
M$climateWords <- str_contains_any(M$TI, climateChangeWords) | str_contains_any(M$AB, climateChangeWords)
M$recoveryWords <- str_contains_any(M$TI, recoveryWords) | str_contains_any(M$AB, recoveryWords)

### Join keyword and word groups
M$climateGroup <- M$climateKeywords | M$climateWords
M$recoveryGroup <- M$recoveryKeywords | M$recoveryWords
### Create a factor for groups by using binary math
# 0: none
# 1: climate
# 2: recovery
# 3: both
groupLevels <- c("neither", "climate change", "recovery", "both")
M$group <- factor(M$climateGroup + 2*M$recoveryGroup, labels=groupLevels, ordered=F, levels=0:3)
summary(M$group)

#### Plots/tables we want:
# Pubs per year
### Plot by year (barplot)
lastYear <- max(M$PY)
firstYear <- min(M$PY)
numberofyears <- lastYear - firstYear +1
years <- firstYear:lastYear
yearFreq <- table(M$PY)
plot(yearFreq, main="", xlab="Time", ylab="Number of articles", type="l")
savePlot("./output/pubsbyyear.png")

### Group prevalence per year
# This line is to complete the year list adding years with no publications
y <- factor(M$PY, levels=years, ordered=T)
# Make a table of pubs per year per group
yearFreqTab <- table(y, M$group)
# Obs: the columns in this tab are:
# 1: neither
# 2: climate change
# 3: recovery
# 4: both
# Let's change to a better order:
yearFreqTab <- yearFreqTab[,c(1,3,4,2)]
write.csv(yearFreqTab,"./output/yearFreqTab.csv")

# stack plot
# Compare this to the previous plot to see that the upper line is the same, since values are stacked
stackplot(
  yearFreqTab,
  main="Articles per year", # Title
  xlab="Time", # X axis name
  ylab="Number of articles", # Y axis name
  col=c("grey","red","magenta","blue"), # Colors (one for each category)
  legend=colnames(yearFreqTab))
savePlot("./output/pubsbyyeargrouped2023.png")

# Top journals
# Pubz per year per subject

res <- fieldByYear(M, field = "ID", min.freq = 10, n.items = 10, graph = TRUE)
# Table of most cited pubs
mostCited <- data[order(data$Cited.by, decreasing=T),][1:10,]

# Distribution of citation and author afilliation
hist(data$Cited.by, main="Distribution of citations", xlab="Number of citations", ylab="Number of articles")
# Country of origin?
# Most used words (title, auth-keyword, ind-keywords, separate tables)
## how many keywords to plot in the barplot
maxwords <- 10

par(mar=c(5,12,1,1))
barplot(keywordTab$Rel.Freq[1:maxwords], col = 1, xlab = "Percentage of articles", names.arg = row.names(keywordTab)[1:maxwords], horiz=T, las=2)
savePlot("output/indexkeywords.png")

par(mar=c(5,12,1,1))
barplot(authorKeywordTab$Rel.Freq[1:maxwords], col = 1, xlab = "Percentage of articles", names.arg = row.names(authorKeywordTab)[1:maxwords], horiz=T, las=2)
savePlot("output/authorkeywords.png")
