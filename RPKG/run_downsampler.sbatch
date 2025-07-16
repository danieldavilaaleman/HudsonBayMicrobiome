#!/bin/bash
#SBATCH --time=4-12:00:00
#SBATCH --account=def-chubert
#SBATCH --cpus-per-task=12
#SBATCH --mem=20G

module load seqkit/2.5.1

for file in ~/scratch/tara.oceans/*.fastq.gz
do
filename=$(basename -s .fastq.gz $file)
echo "Downsample 10 million reads in $filename"
seqkit sample -p 0.8 $file | seqkit seq -m 75 | seqkit head -n 10000000 > tara.oceans/${filename}.downsampled.fastq.gz #-p change depending the size of the library
echo "DONE"
done
