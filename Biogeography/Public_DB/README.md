# README.ME
Here you can find the txt files and commands used to download the Biopolar (Cao et.al.) and Tara Oceans sequencing data.

## Public database
To determine the precense/absence of the reconstructed MAGs, raw metagenomics data were downloaded from different sources:
- Arctic and Antactic metagenomics data: Project PRJNA588686 [Cao et al.,2020](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-020-00826-9) 
- Tara Oceans: Project PRJEB1787 
- Tara Polar: Project PRJEB9740

### Dowloading data - Tara Oceans (n = 249 samples), Tara Polar (n = 41 samples), Arctic &Antarctic (n = 120 samples)
To dowload the data 
1. Download TSV report from ENA project number
2. Extract ftp.sra.ebi...##### paths from tsv file by:    
   ```cut -f8 download.sequences.txt | tail -n +2 | sed 's/;/\n/g' > tara.polar_get_sequences_path_wget.txt```
3. Download files with:
   ```
   while read -r line
   do
   echo "Downloading sequence $line"
   wget $line
   echo "DONE"
   done < tara.polar_get_sequences_path_wget.txt
   ```
