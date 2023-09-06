### These are some utils to make tables easier to deal with

# Add margins to matrix table
addMargins <- function(m) {
    m <- rbind(m, colSums(m))
    m <- cbind(m, rowSums(m))
    colnames(m)[ncol(m)] <- "total"
    rownames(m)[nrow(m)] <- "total"
    m
}

# convert a table object to a matrix object
table_to_matrix <- function(tab) matrix(tab, nrow(tab), dimnames = dimnames(tab))
