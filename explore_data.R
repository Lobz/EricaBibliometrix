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

### Plot by year
my_hist(data$Year)

### Extract keywords
exkey <- sapply(data$Index.Keywords, split_keywords)
