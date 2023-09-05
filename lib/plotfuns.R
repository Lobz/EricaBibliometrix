
## Make some basic color palette
col_forest <- 'darkgreen'
col_campo <- '#e69138'

## Makes a color palette with as many colors as "data" has elements, with corresponding names
make_colors <- function(data, extremes = c("darkblue", "red")){
    data <- sort(data)
    params <- sort(unique(data))
    numpars <- length(params)
    colors <- colorRampPalette(extremes)(numpars)
    names(colors) <- params
    colors
}

## histogram for factors
fhist <- function(data, ...) {
    barplot(table(data), ...)
}

## save a plot as pdf
save.plot <- function(name, FUN, width = 600, height = 400, ...) {
    imagedir = "./media/plots/"
    png(paste0(imagedir, name, ".png"), width = width, height = height, ...)
    FUN()
    dev.off()
}

## plot a histogram of a column
my_hist <- function(data, col = make_colors(1:20),...) {
    if (is.factor(data) | is.logical(data) | is.integer(data)) {
        fhist(data, col = col,...)
    }
    else {
        hist(data, col = col, ...)
    }
}

## Plot histograms of altura, delta h , ptos, delta ptos, fustes, posicao
six_hists <- function(data) {
    par(mfrow = c(3,2))
    my_hist(data$altura, xlab = "Altura (cm)")
    my_hist(data$deltah, xlab = "Crescimento (cm)")

    my_hist(data$ptos, xlab = "Pontos de inserção")
    my_hist(data$deltaptos, xlab = "Aumento de pontos de inserção")

    my_hist(data$fustes, xlab = "Fustes")
    my_hist(data$posicao, xlab = "Posição em relação à borda")
    par(mfrow = c(1,1))
}