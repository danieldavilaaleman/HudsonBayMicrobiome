## This script plots RA of each MAGs across enrichment samples
library(ggplot2)
library(tidyr)

fnames <- list.files("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Mapping/dereplicatedBinsVsEnrichments/coverm", full.names = TRUE)
names <- list.files("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Mapping/dereplicatedBinsVsEnrichments/coverm")

for (i in 1:length(fnames)) {
  if (i == 1) {
    ra <- read.table(fnames[i], sep = "\t", header = TRUE)
    colnames(ra)[2] <- names[i]
  } else {
    ra_temp <- read.table(fnames[i], sep = "\t", header = TRUE)
    colnames(ra_temp)[2] <- names[i]
    ra <- merge(ra,ra_temp, by = "Genome")
  }
}

### Remove unmapped row, transform format from wide to long, create a new column for site and remove "AM18_"and ".tsv" from enrichment name
ra <- ra[-grep("unmapped",ra$Genome),]
ra_long <- gather(ra, enrichment, abundance, colnames(ra)[2:19])
ra_long$Site <- gsub("_[^_].*$", "", ra_long$enrichment)
ra_long$enrichment <- gsub(".tsv", "", ra_long$enrichment)
ra_long$enrichment <- gsub("^[^_]+_", "", ra_long$enrichment)

### Re-order Genomes based on phylogenetic tree "GENICE/fasttree.out/Fig1_tree.R"
source("/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/fasttree.out/Fig1_tree.R")
ra_long$Genome <- factor(ra_long$Genome, levels = rev(taxa_order))

### Plotting relative abundance of each MAG in each enrichment bottle
ggplot(ra_long, aes(x = enrichment, y = Genome, color=site, size = ifelse(abundance==0, NA, abundance))) + geom_point(alpha=0.7) + scale_size(range = c(0.5, 10), name="Relative Abundance") + theme_bw() + scale_color_manual(values = c("#E69F00","#56B4E9"))
