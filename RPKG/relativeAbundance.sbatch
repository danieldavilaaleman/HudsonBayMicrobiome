#!/bin/bash
#SBATCH --partition=cpu2023
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=07-00:00:00

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID
cd $SCRATCH


###### Pre-processing #########
module load bioconda/2024-10


##### Pipeline ###########
### Copying CleanData from GENICE to SCRATCH ###
while read -r line
do
echo "Copying file $line in SCRATCH directory"
cp  /work/ebg_lab/gm/GENICE/elaine/CleanData/$line .
echo "File $line copied"
done < $WORKDIR/CleanDataGenice.txt


### Convert from fastq to fasta ###
for file in *.fastq.gz
do
filename=$(basename $file .fastq.gz)
echo "Transforming $filename to FASTA file"
seqkit fq2fa $filename.fastq.gz -o ${filename}.fasta -j 48 #Number of threads
echo "$filename converted to FASTA file"
done


### Create mmseqs DB for each Site using the converted fasta files
for site in *R1.fasta
do
echo "Creating mmseqs DB of $site"
sitename=$(basename $site .R1.fasta)
mmseqs createdb ${sitename}.R1.fasta ${sitename}.R2.fasta ${sitename}.DB
echo "mmseqs DB from $site crated"
done

### Extract ORF from each sampleDB ###
for DB in *.DB
do
echo "Extracting ORFs from reads in $DB"
mmseqs extractorfs $DB ${DB}.ORFs --translation-table 11 -v 3
echo "Extracted ORFs from $DB"
done

## Translate ORF from nucleotides to protein sequence ###
for ORF_DB in *DB.ORFs
do
echo "Translate Nucleotide ORFs of $ORF_DB to aminoacids"
mmseqs translatenucs $ORF_DB ${ORF_DB}.translated --translation-table 11 -v 3
echo "$ORF_DB translated"
done

## Mapping protien-translated ORFs DBs to plass protein collection
for translated_DB in *DB.ORFs.translated
do
echo "Mapping with pre-filter module $translated_DB"
mmseqs prefilter $translated_DB \
/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_proteins_rep_DB \
${translated_DB}.mapPlassProtRepCatalog -s 2
echo "$translated_DB pre-filtered"
done

## Score the prefilter hits with gapless alignment ##
for translated_DB in *translated
do
echo "Rescoring $translated_DB"
mmseqs rescorediagonal $translated_DB \
/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/protein_catalog/plass_proteins_rep_DB \
${translated_DB}.mapPlassProtRepCatalog ${translated_DB}.rescored -c 1 --cov-mode 2 \
--min-seq-id 0.95 --rescore-mode 2 -e 0.000001 --sort-results 1
echo "$translated_DB rescored"
done
