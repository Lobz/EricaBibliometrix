
# reading and writing csv
my_write.csv <- function(data, filename) {
    write.csv(data, filename, row.names = F, fileEncoding = "utf-8", na = "")
}

my_read.csv <- function(filename) {
    read.csv(filename, fileEncoding = "utf-8", na.strings = c("NA", "na", "", "-", " "), sep = ',', strip.white = T)
}
