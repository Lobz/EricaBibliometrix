# Consolidated data file name
dataFilenameCSV <- "dados_consolidados.csv"
dataFilenameRData <- "dados_consolidados.RData"
# Included files folder
libDir <- "lib"
libs <- c("io.R", "plotfuns.R")

# load all files listed in libs
sapply(paste0(libDir,"/",libs), source)

# load data
load(dataFilenameRData)
names(full_dataset)

### Plot by year
hist(full_dataset$Year)

### Extract keywords
library(stringr)
keywords <- full_dataset$Index.Keywords[1]
split_keywords <- function(keywords) str_trim(strsplit(keywords, ";")[[1]])
exkey <- sapply(full_dataset$Index.Keywords, split_keywords)
sort(unique(unlist(full_dataset$Document.Type)))
