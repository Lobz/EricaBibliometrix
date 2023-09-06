
# reading and writing csv
my_write.csv <- function(data, filename) {
    write.csv(data, filename, row.names = F, fileEncoding = "utf-8", na = "")
}

my_read.csv <- function(filename) {
    read.csv(filename, fileEncoding = "utf-8", na.strings = c("NA", "na", "", "-", " "), sep = ',', strip.white = T)
}

# A shorthand to list all unique values in an array or list
list_unique <- function(x) {sort(unique(unlist(x)))}

# A shorthand to count unique values in an array or list
count_unique <- function(x) length(list_unique(x))