# Consolidated data file name
dataFilenameCSV <- "dados_consolidados.csv"
dataFilenameRData <- "dados_consolidados.RData"
# Included files folder
libDir <- "lib"
libs <- c("io.R", "extractwords.R", "plotfuns.R")

# load all files listed in libs
sapply(paste0(libDir,"/",libs), source)

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
make_word_table(data$Index.Keywords, 10, sep = "; ")
make_word_table(data$Author.Keywords, 10, sep = "; ")

### Extract word from text
make_word_table(data$Title, 10, count.repeated=F)
make_word_table(data$Abstract, 10, count.repeated=F)
