#!/bin/bash
#SBATCH --mem=80G
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=01-00:00:00

####### Set environment variables ###############
module load bioconda

WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH 

####### Pre-processing data  ###############
source ~/software/miniconda3/etc/profile.d/conda.sh

for file in /work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/CleanData/Enrichments_gz/*R1.fastq.gz
do
name=$(basename $file R1.fastq.gz)
echo "Subsampling $name files"
seqkit sample -p 0.8 -s 11 $file | seqkit head -n 10000000 > ${name}_10M_R1.fastq 
done

####### Running mmseqs2 ###################

#Create a mmseqs database format of the  representative arctic hydrocarbon proteins
mmseqs createdb $WORKDIR/../rep_arctic.HCD.proteins.faa rep.arctic.HCD.proteins.db

# Create a sequencing read database of each metagenome sample that want to test
for sample in *_10M_R1.fastq
do
sample_name=$(basename -s "_10M_R1.fastq" $sample)
echo "Running sample $sample_name"
mkdir $sample_name
cd $sample_name
mmseqs createdb $SCRATCH/$sample $sample_name.db
mmseqs extractorfs $sample_name.db $sample_name.orfs
mmseqs translatenucs $sample_name.orfs $sample_name.trans
mmseqs prefilter $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.prefilter -s 2
mmseqs rescorediagonal $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.prefilter $sample_name.rescore \
-c 1 --cov-mode 2 --min-seq-id 0.95 --rescore-mode 2 -e 0.000001 --sort-results 1
mmseqs filterdb $sample_name.rescore $sample_name.tophit --extract-lines 1
mmseqs swapresults $sample_name.trans $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.tophit $sample_name.swap
#NOTICE that target and query DBs are now swapped in position
mmseqs result2stats $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.trans $sample_name.swap $sample_name.stats --stat linecount
mmseqs createtsv $SCRATCH/rep.arctic.HCD.proteins.db $sample_name.trans $sample_name.stats $sample_name.abundances.tsv --target-column 0
mv $sample_name.abundances.tsv $WORKDIR
cd ..
done
