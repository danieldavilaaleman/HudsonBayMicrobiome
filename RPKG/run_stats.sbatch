#!/bin/bash
#SBATCH --time=4-12:00:00
#SBATCH --account=def-chubert
#SBATCH --cpus-per-task=12
#SBATCH --mem=20G

module load seqkit/2.5.1

for file in tara.polar/*.fastq.gz
do
echo "Stats of  $file"
seqkit stats $file 
echo "DONE"
done
