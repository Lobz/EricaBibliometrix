
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
my_hist <- function(data, breaks = FALSE, col = if(breaks) make_colors(1:breaks) else make_colors(data), ...) {
    if (is.factor(data) | is.logical(data) | is.integer(data)) {
        fhist(data, col = col,...)
    }
    else {
        if (breaks) {
            hist(data, col = col, breaks = breaks, ...)
        }
        else {
            hist(data, col = col, ...)
        }
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

#' Function for plotting the result of a simulation over time
#'
#' The \code{stackplot} function produces a stacked plot of the population over time.
#' Notice that the population should have at least two stages for this function to work.
#'
#' @param mat A matrix or something that can be coerced to matrix
#' @param col Optional. A color vector
#' @param legend Optional. An array of names with the names of the stages. Use \code{legend=FALSE} to supress the legend.
#' @param log.y Logical. Should the y-axis be plotted in a logarithmic scale?
#' @param perc Logical. If set to true, will output the y-axis as a percentage instead of the absolute numbers
#' @param qt Optional. For distributions, show only up to quantile qt (percentage)
#' @param \dots Further parameters to be passed to the lower level plot function
#' @examples
#' data(twospecies)
#' ab <- abundance.matrix(twospecies,seq(0,twospecies$maxtime,by=1))
#' # species 1
#' stackplot(ab[,1:3])
#' # species 2
#' stackplot(ab[,4:5])
#' @export
#' @import grDevices
#' @import graphics
stackplot <- function(mat, col, legend, log.y = FALSE, perc=F, qt=100, ...) {
	dots <- list(...)
	if(missing(col))
		col <- colorRampPalette(c("darkred","pink"))(dim(mat)[2])
	if (log.y) {
		minp <- 1
		log <- "y"
	} else {
		minp <- 0
		log <- ""
	}

    mat<-as.matrix(mat)

	N <- dim(mat)[2]
	time <- as.numeric(rownames(mat))
    if(N>1){
        for (i in (N-1):1) # sums populations IN REVERSE
            mat[,i] = mat[,i] + mat[,i+1]
    }
	mat <- cbind(mat, rep(minp, length(time)))
	# maximo da escala do grafico
	maxp <-max(mat[,1])

    # percentage
    if(perc){
        mat <- mat*100.0/maxp
        maxp <- 100
        minp <- 100.0*minp/maxp
    }

    # cap at quantile
    if(qt<100){
        quant <- maxp*(100.0-qt)/100.0
        linemax <- max(which(mat[,1]>=quant))
        mat <- mat[1:linemax,]
        time <- time[1:linemax]
    }

	if (! "ylim" %in% names(dots)) dots$ylim = c(minp, maxp)
	if (! "xlim" %in% names(dots)) dots$xlim = c(min(time),max(time))

	do.call(plot, c(list(1, type='n', log=log), dots))
	x <- c(time, rev(time))
	for (i in 1:(N)) {
		y <- c(mat[,i], rev(mat[,i+1]))
		polygon(x,y, col=col[i])
	}
    if(N>1) { # legend is unnecessary if N==1
        if (missing(legend)) {
            legend <- c(1:N)
        }
        if (!identical(legend, FALSE)) { # Only displays legend if it was not explicitly disabled by argument
            legend("topleft", legend=legend, fill=col, bg="white")
        }
    }
}
