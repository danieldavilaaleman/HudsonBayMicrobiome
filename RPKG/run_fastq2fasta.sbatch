#!/bin/bash
#SBATCH --time=4-12:00:00
#SBATCH --account=def-chubert
#SBATCH --cpus-per-task=12
#SBATCH --mem=20G

module load seqkit/2.5.1

for file in tara.polar/*
do
filename=$(basename -s .fastq.gz $file)
echo "Converting fastq to fasta of $filename"
seqkit fq2fa $file -o tara.polar/${filename}.fasta
echo "DONE"
done
