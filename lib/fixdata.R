
library(tools)

### remove empty columns from df
remove.empty.columns <- function (mydf) {
    Filter(function(x)!all(is.na(x)), mydf)
}

### data format conversion
fix.date <- function(date) {
    d <- as.Date(date, optional = T)
    if(is.na(d)) {
        d <- as.Date(date, tryFormats = c("%Y-%m-%d", "%d %b %Y", "%d-%b-%Y", "%b-%d", "%Y-%m-%dt%H:%M:%Sz"), optional = T)
    }
    d
}
# vectorized
fix.dates <- function(x) {
    sapply(x, fix.date)
}

# convert columns with a convert function
convert_with <- function (d, starts, FUN, ...) {
    ns <- names(d)
    names <- unlist(sapply(starts, function(x) ns[startsWith(ns, x)]))
    for (n in names) {
        d[, n] <- FUN(d[, n], ...)
    }
    d
}

### join all of the above
get.data <- function(filename, use.names=T, use.basename=T, remove.extension=T) {
    print(filename)
    d <- my_read.csv(filename)
    if (use.names & !"filename" %in% names(d)){
        if (use.basename) {
            filename <- basename(filename)
        }
        if (remove.extension) {
            filename <- file_path_sans_ext(filename)
        }
        d$filename <- filename
    }
    d
}

### Merge data while keeping filename info
merge.data <- function(d1, d2, origin.column="filename") {

  ## get common columns
  names1 <- names(d1)
  names2 <- names(d2)
  ns <- intersect(names1,names2)

  keys <- setdiff(ns,origin.column)

  ## merging
  m <- merge(d1, d2, by=keys, all=T)


}

# A shorthand to list all unique values in an array or list
list_unique <- function(x) {sort(unique(unlist(x)))}

# A shorthand to count unique values in an array or list
count_unique <- function(x) length(list_unique(x))