# RKPG analysis for AlkB and CYP153 genes

For performing comparative metagenomics, reads per kilobase genome equivalents was calculated for AlkB and CYP53.  
The followed steps:  
1. Downsample 10 million reads from each FASTQ file using seqkit with seed default ```run_downsampler.sbatch```
2. Confirm that each downsampled files has ~10M reads ```run_stats.sbatch```
3. mmseqs2 translates the nucleotide reads to putative protein fragments, search against a protein reference databases.
   1. Convert downsampled read files to fasta using seqkit ```run_fastq2fasta.sbatch```
   2. Create a database that mmseqs2 can read from fasta files
   3. 


