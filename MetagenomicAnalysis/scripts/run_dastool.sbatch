#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=03:00:00
#SBATCH --mem=30G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3

####### Set environment variables ###############
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID

cd $SCRATCH

source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate dastool

####### Run your script #########################
#### Step 1 - Obtain Fasta2Contigs2Bin tabular input for Das_Tools ####
#COMEBin bins
Fasta_to_Contig2Bin.sh -i $WORKDIR/comebin_res_bins -e fa > COMEBin.contigs2bin.tsv
#SemiBin2 bins
Fasta_to_Contig2Bin.sh -i $WORKDIR/SemiBin2_output_bins -e fa > SemiBin2.contigs2bin.tsv
#MetaDecoder
Fasta_to_Contig2Bin.sh -i $WORKDIR/metadecoder.output.bins -e fasta > MetaDecoder.contigs2bin.tsv

#### Step 2 - Running Das_Tool
DAS_Tool -i COMEBin.contigs2bin.tsv,SemiBin2.contigs2bin.tsv,MetaDecoder.contigs2bin.tsv \
-l COMEBin,SemiBin2,MetaDecoder -t 40 -c $WORKDIR/final.contigs_1000.fa  -o DasTool.output --debug --write_bins --write_bin_evals
