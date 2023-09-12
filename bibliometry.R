# Bibliometry with bibliometrix
## Obs: remember to install this package with install.packages("bibliometrix")
## Bibliometrix requires R >= 4.3.0
library(bibliometrix)

## Get data
# We're using CSV because it consistently got all required fields
# The file scopus_2023_09_12.csv was downloaded from in 2023-09-12 from Scopus using the following search parameters:
# Fields: Article title, Abstract, Keywords
# Search query: mangrove* AND soil AND (microbio* OR microorgan* OR bacteri* OR fungus OR fungi OR fungal OR protist* OR archaea)
# Document type: Articles only
# Exported fields: all available information
# Exported documents: 1 - 873 (all)
dataCSV <- "./input/scopus2023_09_12.csv"

# Converting the loaded files into a R bibliographic dataframe
M <- convert2df(file=dataCSV, dbsource="scopus",format="csv")
results <- biblioAnalysis(M)

summary(results, k=10, pause=T, width=130)
plot(x=results, k=10, pause=T)
