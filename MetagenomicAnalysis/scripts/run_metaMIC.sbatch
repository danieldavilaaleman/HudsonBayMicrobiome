#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=23:00:00
#SBATCH --mem=50G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate mateMIC

#metaMIC download_model
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH
####### Run your script #########################
# Step 1  -- Prepare concatenate read files for mapping with bwa
cat $WORKDIR/../CleanData/Enrichments_gz/*_R1.fastq.gz > AllEnrichmentSamples_R1.fastq.gz
cat $WORKDIR/../CleanData/Enrichments_gz/*_R2.fastq.gz > AllEnrichmentSamples_R2.fastq.gz

gzip -d AllEnrichmentSamples_R1.fastq.gz
gzip -d AllEnrichmentSamples_R2.fastq.gz

# Step 2 -- Map paired-end reads to assembled contigs

bwa index $WORKDIR/final.contigs_1000.fa
bwa mem -a -t 8 $WORKDIR/final.contigs_1000.fa AllEnrichmentSamples_R1.fastq.gz AllEnrichmentSamples_R2.fastq.gz |\
samtools view -h -q 10 -m 50 -F 4 -b | samtools sort > MappingAllEnrichmentSamples.bam

# Step 3 -- Generate pileup file

samtools mpileup -C 50 -A -f $WORKDIR/final.contigs_1000.fa MappingAllEnrichmentSamples.bam | awk '$3 != "N"' > pileup_file

# Step 4 For metagenomics, Extract features
metaMIC extract_feature --bam MappingAllEnrichmentSamples.bam -c $WORKDIR/final.contigs_1000.fa -o metaMIC_Output\
 --pileup pileup_file -m meta

#Step 5 Misassembly breakpoint identification and correction
metaMIC predict -c $WORKDIR/final.contigs_1000.fa -o metaMIC_Output -a MEGAHIT -m meta
