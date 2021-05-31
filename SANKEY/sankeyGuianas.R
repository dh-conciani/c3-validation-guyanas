# library
library(networkD3)
library(dplyr)

pais <- "Guyana"

## carregar tabela
link <- read.table("../tables/transitions.txt", sep="\t", dec= ",", header= TRUE)[1:4]
link$target <- paste(link$target, " ", sep="")

## subset do pais
link <- subset (link, country == pais)

## criar nodes
node <- data.frame(name=c(as.character(link$source), as.character(link$target)) %>% unique())

## criar nomes
link$IDsource <- match(link$source, node$name)-1 
link$IDtarget <- match(link$target, node$name)-1

## criar palheta
# prepare colour scale
ColourScal ='d3.scaleOrdinal() .range(["#006400", "#45C2A5", "#E974ED", "#0000FF", "#EA9999"])'

# Make the Network
p <- sankeyNetwork(Links = link, Nodes = node,
                   Source = "IDsource", Target = "IDtarget",
                   Value = "value", NodeID = "name", 
                   sinksRight=FALSE, colourScale=ColourScal, nodeWidth=40, fontSize=13, nodePadding=20)

p
