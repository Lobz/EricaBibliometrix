# Bibliometria

## Coleta de dados

A coleta de dados foi feita em 12 de Setembro de 2023, no Scopus, com os seguintes parâmetros:

Campos pesquisados: Títulos, abstracts e keywords

Query da busca:
`mangrove* AND soil AND ( microbio* OR microorgan* OR bacteri* OR fungus OR fungi OR fungal OR protist* OR archaea )`

Restringimos a busca para "Articles only" (apenas artigos). A busca retornou 873 artigos, publicados entre 1959 e 2023. Exportamos os dados em csv, com todas as informações disponíveis.

## Leitura dos dados

Os dados foram analisados usam `R` (https://www.r-project.org/) e o pacote `bibliometrix` (https://www.bibliometrix.org). Obs: para citar o pacote bibliometrix no seu texto, siga as indicações aqui: https://www.bibliometrix.org/vignettes/Introduction_to_bibliometrix.html.

## Classificação

Os dados foram classificados em dois grupos não-exclusivos, o grupo "climate change" e o grupo "recovery". A classificação foi feita buscando a presença, em título, abstract ou palavras-chave, de qualquer uma das palavras associadas a cada grupo, listadas abaixo:

```r
climateChangeWords <- c("climate change", "blue carbon", "greenhouse gas mitigation", "carbon stock", "carbon sink", "carbon sequestration")
recoveryWords <- c("recovery", "microbial succession", "reforestation", "replanting", "restoration", "remediation")
```

Para as palavras chaves, antes determinamos quais palavras-chaves contém as palavras acima. As palavras-chave encontradas foram:

```r
> climateChangeKeywords
[1] "blue carbon"               "blue carbon ecosystem"     "blue carbon ecosystems"    "carbon sequestration"
[5] "carbon sink"               "climate change"            "global climate changes"    "soil carbon sequestration"
[9] "soil carbon stock"
> recoveryKeywords
 [1] "assisted phytoremediation"                 "bacterial-remediation"
 [3] "bioremediation"                            "desert reforestation"
 [5] "ecosystem restoration"                     "electrokinetic remediation"
 [7] "environmental restoration"                 "environmental restoration and remediation"
 [9] "habitat restoration"                       "heavy metal remediation"
[11] "in-situ bioremediation"                    "kandelia obovata restoration"
[13] "kandelium obovatum restoration"            "mangrove recovery"
[15] "mangrove restoration"                      "metal recovery"
[17] "nanobioremediation"                        "oil recovery"
[19] "phytoremediation"                          "recovery"
[21] "reforestation"                             "remediation"
[23] "remediation efficiency"                    "remediation strategies"
[25] "restoration"                               "restoration ecology"
[27] "rhizoremediation"                          "salt pond restoration"
[29] "soil remediation"                          "water bioremediation"
```

No total, encontramos 4 artigos pertencentes aos dois grupos, 44 em apenas "climate change", 123 em apenas "recovery", e 702 em nenhum dos dois grupos.

## Gráficos e tabelas

Produzimos os seguintes gráficos:
- Artigos publicados por ano
- Artigos publicados por ano, de acordo com os grupos
- Artigos publicados por ano, de acordo com os grupos, removendo o ano incompleto de 2023
- Author Keywords mais frequentes
- Index keywords mais frequentes
- Histograma de número de citações por artigo
- Histograma de número de citações por revista
- Histograma de número de publicações por revista

E as seguintes tabelas:
- Artigos mais citados
- Revistas com maior número de publicações
- Revistas com maior número de citações totais
- Keywords mais frequentes
