# Biogeography analysis

For biogeography analysis, metagenomics data from enrichments samples, environmental samples and 
publicly available data (TARA Oceans, TARA Polar and Antarctic) were mapped against generated dereplicated
bins.

## Enrichments
For enrichments metagenomics data, [coverM](https://github.com/wwood/CoverM) genome was implemented for 
relative abundance calculation using a Snakefile.

## Environmental
To determine the precese/absence of a reconstructed MAG, coverM trimmed_mean, which removed the 10% of the bases with highest and 10% of bases with lowest coverage (TAD80) was implemented in the Snakefile.
