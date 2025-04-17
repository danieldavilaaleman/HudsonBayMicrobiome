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
- Tara Oceans
- Tara Polar

### Arctic and Antarctic
To dowload the data 
1. Access SRA NCBI project PRJNA588686
2. Send to/ File / Summary
3. ENA project PRJNA588686 - Download report / TSV
4. To Download using sratoolkit and Experiment accession SRX######
   ```cat Summary.report.tsv | sed 's/,/\t/g' | cut -f1 | tail -n +2 > seq_ac_number.txt ```
5. This gets a list file with all experiment accession numbers to dowload
6. Create a script to dowload data
   ```
   while read -r line
   do
   echo "Downloading sequence $line"
   prefetch $line
   echo "DONE"
   done < seq_ac_number.txt
   ```
