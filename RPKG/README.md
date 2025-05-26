# RKPG analysis for AlkB and CYP153 genes

For performing comparative metagenomics, reads per kilobase genome equivalents was calculated for AlkB and CYP53.  
The followed steps:  
1. Downsample 10 million reads from each FASTQ file using seqtk
2. Prodigal to identify likely protein coding sequence from each read
3. Protein sequence were search against the KEGG Orthology Database using RAPsearch2
4. Filter alignments with bit scores less than 30
5. Assign eacg read to the KO according to its top scoring hit


