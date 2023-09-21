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
data <- convert_with(data, c("Document.Type", "Publication.Stage", "Source", "Open.Access"), as.factor)
data <- convert_with(data, c("Page.count", "Cited", "Year"), as.integer)

## A few infos about years
lastYear <- max(data$Year) #2023
firstYear <- min(data$Year) #1959
numberofyears <- lastYear - firstYear +1
years <- firstYear:lastYear

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

#######################################################################
################ KEYWORDS AND WORDS ###################################
#######################################################################

### Extract keywords (set sep as the separator between keywords)
(keywordTab <- make_word_table(data$Index.Keywords, min.Freq = 1, sep = "; "))
write.csv(keywordTab[1:200,], "./output/IDkeywordTable.csv")
(authorKeywordTab <- make_word_table(data$Author.Keywords, min.Freq = 1, sep = "; "))
write.csv(authorKeywordTab[1:200,], "./output/AUkeywordTable.csv")

keywords <- list_unique(c(rownames(keywordTab), (rownames(authorKeywordTab))))
write(keywords, "./output/keywords.txt")

wordlistsAK <- make_wordslist(data$Author.Keywords, sep="; ")
wordlistsIK <- make_wordslist(data$Index.Keywords, sep="; ")

### Extract word from text
my_stopwords = bibliometrix::stopwords$en
titleWords <- make_word_table(data$Title, min.Freq=1, remove.terms = my_stopwords)
abstractWords <- make_word_table(data$Abstract,  min.Freq=1, remove.terms = my_stopwords)
words <- list_unique(c(rownames(titleWords),rownames(abstractWords)))
write(words, "./output/words.txt")

##############################################################
################## SUBGROUPS #################################
##############################################################

### Subgroups defined by presence of these terms in Title or Abstract or Keywords, or terms containing these in Keywords

climateChangeWords <- c("climate change", "blue carbon", "greenhouse gas mitigation", "carbon stock", "carbon sink", "carbon sequestration")

recoveryWords <- c("recovery", "microbial succession", "reforestation", "replanting", "restoration", "remediation")

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

###############################################
############# PLOTS AND TABLES ################
###############################################

### Plot by year (barplot)
yearFreq <- table(data$Year)
plot(yearFreq, main="", xlab="Time", ylab="Number of articles", type="l")
savePlot("./output/pubsbyyear.png")

### Group prevalence per year
# This line is to complete the year list adding years with no publications
data$y <- factor(data$Year, levels=years, ordered=T)

# Make a table of pubs per year per group
yearFreqTab <- table(y, data$group)
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
maxbars <- 20

mostPubs <- rownames(journalTab[1:maxbars])

## Yearly number of articles for top sources
MP <- subset(M, JI %in% mostPubs, select=c("y","JI"))
journalTabYearly <- table(MP$y, MP$JI)
write.csv(journalTabYearly, "./output/journalTop10Yearly.csv")

## Reduce super long name
mostPubs[5] <- "A.V.L. INT. J. GEN. MOL. MICROBIOL."
## Barplot
par(mar=c(5,15,1,1))
barplot(journalTab[1:maxbars],
  col = 1,
  xlab = "Number of articles",
  names.arg = mostPubs,
  horiz=T,
  las=1)
savePlot("./output/topJournals.png")

# Pubz per year per subject

res <- fieldByYear(M, field = "ID", min.freq = 10, n.items = 10, graph = TRUE)
# Most cited pubs
CR <- citations(M, field = "article", sep = ";")

mostCited <- data[order(data$Cited.by, decreasing=T)[1:20],c("Authors", "Year", "Title", "DOI", "Source.title", "Cited.by")]
my_write.csv(mostCited, "./output/mostcited20.csv")
# Distribution of citation and author afilliation
hist(data$Citec.by,
  main="Distribution of citations",
  xlab="Number of citations",
  ylab="Number of articles")
savePlot("output/distCitations.png")
# Country of origin?
# Most used words (title, auth-keyword, ind-keywords, separate tables)

par(mar=c(5,12,1,1))
barplot(keywordTab$Rel.Freq[1:maxbars],
  col = 1,
  xlab = "Percentage of articles",
  names.arg = row.names(keywordTab)[1:maxbars],
  horiz=T,
  las=1)
savePlot("output/indexkeywords.png")

par(mar=c(5,12,1,1))
barplot(authorKeywordTab$Rel.Freq[1:maxbars],
  col = 1,
  xlab = "Percentage of articles",
  names.arg = row.names(authorKeywordTab)[1:maxbars],
  horiz=T,
  las=1)
savePlot("output/authorkeywords.png")
