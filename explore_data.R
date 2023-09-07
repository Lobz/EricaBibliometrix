# Consolidated data file name
dataFilenameCSV <- "dados_consolidados.csv"
dataFilenameRData <- "dados_consolidados.RData"
# Included files folder
libDir <- "lib"
# load all files listed in libs
sapply(list.files(libDir, full.names = T), source)

# load data
load(dataFilenameRData)
names(data)

# restrict data to articles
data <- subset(data, Document.Type=="Article")

### Plot by year (barplot)
lastYear <- max(data$Year)
firstYear <- min(data$Year)
numberofyears <- lastYear - firstYear +1
my_hist(data$Year, main="", xlab="Time", ylab="Number of publications")
savePlot("pubsbyyear.png")


### Extract keywords (set sep as the separator between keywords)
keywordTab <- make_word_table(data$Index.Keywords, 20, sep = "; ")
par(mar=c(5,12,1,1))
barplot(keywordTab$Rel.Freq, col = 1, xlab = "Percentage of publications", names.arg = row.names(keywordTab), horiz=T, las=2)
savePlot("indexkeywords.png")
authorKeywordTab <- make_word_table(data$Author.Keywords, 20, sep = "; ")
barplot(authorKeywordTab$Rel.Freq, col = 1, xlab = "Percentage of publications", names.arg = row.names(authorKeywordTab), horiz=T, las=2)
savePlot("authorkeywords.png")

### Extract word from text
make_word_table(data$Title, 20)
make_word_table(data$Abstract, 20)
