# Biogeography analysis

For biogeography analysis, metagenomics data from enrichments samples, environmental samples and 
publicly available data (TARA Oceans, TARA Polar and Antarctic) were mapped against generated dereplicated
bins.

## Create virtualenv in ComputeCan for MicrobeCensus
In #ComputeCanada, to install a software is adviced to create a virtual environment inside the job to be fast and give some protecting against filesystem performance issues. For doing this, I need to create a **requirements.txt** file that contains all the information of the environment to be reproducible between jobs.



## Enrichments
For enrichments metagenomics data, [coverM](https://github.com/wwood/CoverM) genome v.0.7.0 together with minimap2 version 2.28-r1209 and samtools version 1.21 was implemented for TAD80 (trimmed_mean) calculation using a Snakefile using min-read-percent-identity of 95%.

## Environmental
To determine the precense/absence of a reconstructed MAG, coverM trimmed_mean, which removed the 10% of the bases with highest and 10% of bases with lowest coverage (TAD80) was implemented in the Snakefile.

For Average Genome Size, MicrobeCensus v1.1.1 was implemented. Installation was using an virtualenv following the steps in ```scripts/run_microbecensus.sbatch```. Because python 3.11 was used, an updated version of MicrobeCensus developed by https://pypi.org/project/MicrobeCensus-SourceApp/ was implemented.

## Public database
To determine the precense/absence of the reconstructed MAGs, raw metagenomics data were downloaded from different sources:
- Arctic and Antactic metagenomics data: Project PRJNA588686 [Cao et al.,2020](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-020-00826-9)
- Tara Oceans: Project PRJEB1787
- Tara Polar: Project PRJEB9740

### Dowloading data - Tara Oceans (n = 249 samples), Tara Polar (n = 41 samples), Arctic &Antarctic (n = 120 samples)
To dowload the data 
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
