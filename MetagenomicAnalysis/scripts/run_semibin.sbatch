#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=03:00:00
#SBATCH --mem=20G
#SBATCH --partition=gpu-v100
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate semibin
nvidia-smi

####### Run your script #########################
samtools merge $SCRATCH/allEnrichMappedCoassembly.bam $WORKDIR/comebine.coassembly.bamfiles/work_files/*bam

SemiBin2 single_easy_bin --environment ocean \
-i $WORKDIR/final.contigs_1000.fa \
-b $SCRATCH/allEnrichMappedCoassembly.bam \
-o $SCRATCH/SemiBin2.output
