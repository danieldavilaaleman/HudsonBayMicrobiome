library("ggtree")
library("dplyr")
library(treeio)

setwd("//work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/fasttree.out")

## Read tree file created with FastTree from msa user output of GTDB-TK
tree <- read.tree("dRep_outgroup.tree")

## Read Metadata
meta_data <- read.csv("metadata.csv", header = TRUE)
toremove <- is.na(meta_data)
meta_data[toremove] <- 0 

## Create a DF with tree information and merge with metadata
tree_data <- fortify(tree)
tree_data <- merge(tree_data, meta_data, by.x = "label", by.y = "MAG")

## Plotting the tree
p <- ggtree(tree) %<+% tree_data + geom_tiplab(aes(label = paste(label, " - ", Genus)), size = 3, linesize = 0.5, align = TRUE) + geom_tippoint(aes(color = Order)) + theme_tree2(legend.position = "bottom") + xlim(0, 2)

print(p)

## Get taxa order for bubble plot
taxa_order <- get_taxa_name(p)
