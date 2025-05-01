! /bin/bash
#SBATCH --time=2-12:00:00
#SBATCH --account=def-chubert
#SBATCH --cpus-per-task=12
#SBATCH --mem=80G

module load minimap2
module load samtools

for file in *fastq.gz
do
filename=$(basename -s .fastq.gz $file)
echo "Running CoverM in $filename"
coverm genome --single $file -t 12 -d ~/dereplicated_genomes -x fa --min-read-percent-identity 95 \
-m relative_abundance -o ${filename}.coverm.out
echo "DONE"
done
