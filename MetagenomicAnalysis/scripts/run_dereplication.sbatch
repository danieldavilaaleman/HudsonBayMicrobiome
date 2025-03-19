#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=04:00:00
#SBATCH --mem=80G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate instrain

####### Run your script #########################
dRep dereplicate -g ../Medium.HQ.bins/*.fa -comp 50 -con 20 --S_algorithm gANI --S_ani 0.95 -p 48 dRep_HQ_MAGs
