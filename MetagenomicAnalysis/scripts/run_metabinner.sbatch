#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=08:00:00
#SBATCH --mem=80G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

#module load python/3.12.5
#source /global/software/bioconda/init-2024-10

#python $WORKDIR/gen_kmer.py $WORKDIR/final.contigs_1000.fa 1000 4 $SCRATCH/

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate metabinner

####### Run your script #########################
bash run_metabinner.sh -a $WORKDIR/final.contigs_1000.fa -o $WORKDIR/metabinner.output -d $WORKDIR/metaBinner.coverage_profile.tsv \
-k $WORKDIR/final.contigs_1000_kmer_4_f1000.csv -t 40 -s huge \
-p ~/software/miniconda3/envs/metabinner/bin
