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
save(M, file="./input/scopus2023_09_12.RData")
results <- biblioAnalysis(M)

summary(results, k=10, pause=T, width=130)
pdf()
plot(x=results, k=10, pause=F)
dev.off()

# Conceptual Structure using keywords (method="CA")
pdf("./output/conceptualstr.pdf")
CS <- conceptualStructure(
  M,
  field = "DE",
  minDegree = 10,
  k.max = 20,
  graph = TRUE,
  remove.terms = NULL,
  synonyms = NULL
)
dev.off()

CS$graph
