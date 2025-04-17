# Biogeography analysis

For biogeography analysis, metagenomics data from enrichments samples, environmental samples and 
publicly available data (TARA Oceans, TARA Polar and Antarctic) were mapped against generated dereplicated
bins.

## Enrichments
For enrichments metagenomics data, [coverM](https://github.com/wwood/CoverM) genome was implemented for 
relative abundance calculation using a Snakefile.

## Environmental
To determine the precense/absence of a reconstructed MAG, coverM trimmed_mean, which removed the 10% of the bases with highest and 10% of bases with lowest coverage (TAD80) was implemented in the Snakefile.

## Public database
To determine the precense/absence of the reconstructed MAGs, raw metagenomics data were downloaded from different sources:
- Arctic and Antactic metagenomics data [Cao et al.,2020](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-020-00826-9)
- Tara Oceans: Project PRJEB1787
- Tara Polar: Project PRJEB9740

### Tara Oceans
To dowload the data (n = 249)
1. Download TSV report from ENA project number
2. Extract ftp.sra.ebi...##### paths from tsv file by:    
   ```cut -f8 download.sequences.txt | tail -n +2 | sed 's/;/\n/g' > sequences_path_wget.txt```
3. Download files with:
   ```
   while read -r line
   do
   echo "Downloading sequence $line"
   wget $line
   echo "DONE"
   done < sequences_path_wget.txt
   ```
