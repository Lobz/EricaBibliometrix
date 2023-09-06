### Organize Scopus Input
#
# R Script for organizing input data imported from Scopus from several different searches
#
# Author: Mali Oz Salles
# Date: Sep 2023

### How to use this script:
# First, you should update the environment variables below

### Setup variables:
# Input files folder
inputFilesDir <- "input";
# Consolidated data file name
dataFilenameCSV <- "dados_consolidados.csv"
dataFilenameRData <- "dados_consolidados.RData"
# Included files folder
libDir <- "lib"
libs <- c("io.R", "fixdata.R")


# load all files listes in libs
sapply(paste0(libDir,"/",libs), source)

# read all files
my_files<- list.files(inputFilesDir, pattern=".*.csv", full.names=T)
my_files

dados <- sapply(my_files, get.data, use.names=F, use.basename=T, remove.extension=T, USE.NAMES=T)
## check col names
(dados_colnames<- (lapply(dados,names)))
# List all colnames of all files
(unique_colnames <- sort(unique(unlist(dados_colnames))))
# List all colnames that are common to all files
(common_colnames <- sort(Reduce(intersect, dados_colnames)))
# The following columns will be dropped as they are not in all files
(dropped_colnames <- setdiff(unique_colnames, common_colnames))
## check row numbers
sapply(dados,nrow)

## Drop extra columns
dados <- lapply(dados, subset, select=common_colnames)

## Merge data from all files
full_dataset <- do.call(rbind, dados)

## Check for duplicate data
dois <- full_dataset$DOI
dups <- duplicated(dois)

## for now, we will remove all duplicates
data <- full_dataset[!dups,]

## Check the content of columns and use the proper type for specific fields
data <- convert_with(data, c("Document.Type", "Publication.Stage", "Source", "Open.Access"), as.factor)
data <- convert_with(data, c("Page.count", "Cited", "Year"), as.integer)
summary(data)

## Save merged data
my_write.csv(data, dataFilenameCSV)
save(data, file=dataFilenameRData)
