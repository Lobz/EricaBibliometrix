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
climateChangeKeywords <- c("climate change", "blue carbon", "greenhouse gas mitigation", "carbon stock", "carbon sink")
#recoveryGroup = recovery OR microbial succession OR reforest OR replant
recoveryKeywords <- c("recovery", "microbial succession", "reforestation", "replanting", "restoration", "remediation")

### Plot by year (barplot)
lastYear <- max(data$Year)
firstYear <- min(data$Year)
numberofyears <- lastYear - firstYear +1
yearFreq <- table(data$Year)
plot(yearFreq, main="", xlab="Time", ylab="Number of articles", type="l")
savePlot("./output/pubsbyyear.png")




### Extract keywords (set sep as the separator between keywords)
(keywordTab <- make_word_table(data$Index.Keywords, min.Freq = 1, sep = "; "))

par(mar=c(5,12,1,1))
barplot(keywordTab$Rel.Freq, col = 1, xlab = "Percentage of publications", names.arg = row.names(keywordTab), horiz=T, las=2)
savePlot("output/indexkeywords.png")

(authorKeywordTab <- make_word_table(data$Author.Keywords, min.Freq = 1, sep = "; "))
keywords <- list_unique(c(rownames(keywordTab), (rownames(authorKeywordTab))))
write(keywords, "./output/keywords.txt")
barplot(authorKeywordTab$Rel.Freq, col = 1, xlab = "Percentage of publications", names.arg = row.names(authorKeywordTab), horiz=T, las=2)
savePlot("output/authorkeywords.png")

### Find a list of keywords containing the keywords for each group:
climateChangeKeywords <- subwords(climateChangeKeywords, keywords)
recoveryKeywords <- subwords(recoveryKeywords, keywords)

### Set a variable to list if

### Extract word from text
my_stopwords = bibliometrix::stopwords$en
titleWords <- make_word_table(data$Title, min.Freq=1, remove.terms = my_stopwords)
abstractWords <- make_word_table(data$Abstract,  min.Freq=1, remove.terms = my_stopwords)
words <- list_unique(c(rownames(titleWords),rownames(abstractWords)))
write(words, "./output/words.txt")

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