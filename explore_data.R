# Consolidated data file name
dataFilenameCSV <- "./input/scopus2023_09_12.csv"
dataFilenameRData <- "./input/scopus2023_09_12.RData"
# Included files folder
libDir <- "lib"
# load all files listed in libs
sapply(list.files(libDir, full.names = T), source)

# load data
load(dataFilenameRData)
names(M)

data <- my_read.csv(dataFilenameCSV)
data <- remove.empty.columns(data)
data <- convert_with(data, c("Document.Type", "Publication.Stage", "Source", "Open.Access"), as.factor)
data <- convert_with(data, c("Page.count", "Cited", "Year"), as.integer)

## A few infos about years
lastYear <- max(data$Year) #2023
firstYear <- min(data$Year) #1959
numberofyears <- lastYear - firstYear +1
years <- firstYear:lastYear
# This line is to complete the year list adding years with no publications
data$Year <- factor(data$Year, levels=years, ordered=T)

## Function to turn a list of authors into a string
authorstr <- function(x) {
  if (length(x)==1)
    return(x)
  else if (length(x)==2)
    return(paste(x[1],"and",x[2]))
  else {
     return(paste(x[1],"et al."))
  }
}

## Obtain author str to use in refs
data$authorstr <- sapply(strsplit(data$Authors, "; "), authorstr)

##############################################################
################## SUBGROUPS #################################
##############################################################

### Subgroups defined by presence of these terms in Title or Abstract or Keywords, or terms containing these in Keywords

climateChangeWords <- c("climate change", "blue carbon", "greenhouse gas mitigation", "carbon stock", "carbon sink", "carbon sequestration")

recoveryWords <- c("recovery", "microbial succession", "reforestation", "replanting", "restoration", "remediation")

### list of all keywords
wordlistsAK <- make_wordslist(data$Author.Keywords, sep="; ")
wordlistsIK <- make_wordslist(data$Index.Keywords, sep="; ")
keywords <- list_unique(c(unlist(wordlistsAK), (unlist(wordlistsIK))))
write(keywords, "./output/keywords.txt")

### Identify actual keywords that correspond to the lists above
climateChangeKeywords <- subwords(climateChangeWords, keywords)
recoveryKeywords <- subwords(recoveryWords, keywords)

### Set a variable to list if a document contains keywords the keywords selected
data$climateKeywords <- contains_any(wordlistsAK, climateChangeKeywords) | contains_any(wordlistsIK, climateChangeKeywords)
data$recoveryKeywords <- contains_any(wordlistsAK, recoveryKeywords) | contains_any(wordlistsIK, recoveryKeywords)

### And now with abstract and title words
data$climateWords <- str_contains_any(data$Title, climateChangeWords) | str_contains_any(data$Abstract, climateChangeWords)
data$recoveryWords <- str_contains_any(data$Title, recoveryWords) | str_contains_any(data$Abstract, recoveryWords)

### Join keyword and word groups
data$climateGroup <- data$climateKeywords | data$climateWords
data$recoveryGroup <- data$recoveryKeywords | data$recoveryWords

### Create a factor for groups by using binary math
# 0: none
# 1: climate
# 2: recovery
# 3: both
groupLevels <- c("neither", "climate change", "recovery", "both")
data$group <- factor(data$climateGroup + 2*data$recoveryGroup, labels=groupLevels, ordered=F, levels=0:3)
summary(data$group)

#######################################################################
################ KEYWORDS AND WORDS ###################################
#######################################################################

### Extract keywords (set sep as the separator between keywords)
(keywordTab <- make_word_table(data$Index.Keywords, min.Freq = 1, sep = "; "))
write.csv(keywordTab[1:200,], "./output/IDkeywordTable.csv")
(authorKeywordTab <- make_word_table(data$Author.Keywords, min.Freq = 1, sep = "; "))
write.csv(authorKeywordTab[1:200,], "./output/AUkeywordTable.csv")

### Extract word from text
my_stopwords = bibliometrix::stopwords$en
titleWords <- make_word_table(data$Title, min.Freq=1, remove.terms = my_stopwords)
abstractWords <- make_word_table(data$Abstract,  min.Freq=1, remove.terms = my_stopwords)
words <- list_unique(c(rownames(titleWords),rownames(abstractWords)))
write(words, "./output/words.txt")

## Now, keyword tabs per group
dataClimate <- subset(data, climateGroup)
dataRecovery <- subset(data, recoveryGroup)
(keywordTabClimate <- make_word_table(dataClimate$Index.Keywords, min.Freq = 1, sep = "; "))
write.csv(keywordTabClimate[1:200,], "./output/IDkeywordTableClimate.csv")
(authorKeywordTabClimate <- make_word_table(dataClimate$Author.Keywords, min.Freq = 1, sep = "; "))
write.csv(authorKeywordTabClimate[1:200,], "./output/AUkeywordTableClimate.csv")

###############################################
############# PLOTS AND TABLES ################
###############################################

### Plot by year (barplot)
yearFreq <- table(data$Year)
plot(yearFreq, main="", xlab="Time", ylab="Number of articles", type="l")
savePlot("./output/pubsbyyear.png")

### Group prevalence per year

# Make a table of pubs per year per group
yearFreqTab <- table(data$Year, data$group)
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
# Table number of publications per journal
totalArticles <- sort(table(data$Source.title), decreasing=T)
# Table number of citations per journal
totalCitations <- by(data$Cited.by, data$Source.title, sum)
# Organize by number of articles
totalCitations <- totalCitations[rownames(totalArticles)]
# Join the two
journalTab <- cbind(totalArticles, totalCitations)

write.csv(journalTab, "./output/journalTotals.csv")

## how many elements to plot in each barplot
maxbars <- 30

## Distribution of papers published and total citations
hist(totalArticles,
  breaks=30,
  main="Distribution of articles per source",
  xlab="Number of articles from source",
  ylab="Number of sources"
)
savePlot("output/distArticlesJournals.png")
hist(totalCitations,
  breaks=maxbars,
  main="Distribution of total citations per source",
  xlab="Number of citations of articles from source",
  ylab="Number of sources"
)
savePlot("output/distCitationsJournals.png")

mostPubs <- rownames(journalTab)[1:10]

## Yearly number of articles for top sources
MP <- subset(data, Source.title %in% mostPubs, select=c("Year","Source.title"))
journalTabYearly <- table(MP$Year, MP$Source.title)
write.csv(journalTabYearly, "./output/journalTop10Yearly.csv")

## Most cited articles
mostCited <- data[order(data$Cited.by, decreasing=T),c("authorstr", "Year", "Source.title", "Cited.by")]
my_write.csv(mostCited, "./output/mostcited.csv")
# Distribution of citation
hist(data$Cited.by,
  breaks=maxbars,
  main="Distribution of citations",
  xlab="Number of citations",
  ylab="Number of articles")
savePlot("output/distCitations.png")

# Country of origin?
## Easier to do this w bibliometrix

# Most used words (title, author-keyword, index-keywords, separate tables)
# index keywords
par(mar=c(5,12,1,2))
barplot(keywordTab$Freq[maxbars:1],
  col = 1,
  main = "Most frequent Index Keywords",
  xlab = "Number of articles",
  xlim = c(0,500),
  names.arg = row.names(keywordTab)[maxbars:1],
  horiz=T,
  las=1)
savePlot("output/indexkeywords.png")

# author keywords
par(mar=c(5,10,1,2))
barplot(authorKeywordTab$Freq[maxbars:1],
  col = 1,
  main = "Most frequent Author Keywords",
  xlab = "Number of articles",
  names.arg = row.names(authorKeywordTab)[maxbars:1],
  horiz=T,
  las=1)
savePlot("output/authorkeywords.png")
