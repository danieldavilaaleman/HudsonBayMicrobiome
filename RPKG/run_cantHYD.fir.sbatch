#!/bin/bash
#SBATCH --mem=100G
#SBATCH --cpus-per-task=8
#SBATCH --ntasks-per-node=24
#SBATCH --time=01-00:00:00
#SBATCH --account=rrg-chubert

####### Set environment variables ###############
## Add color to the echo messages
BOLD_GREEN='\033[1;33m'
NC='\033[0m'

###### Pre-processing #########
module load hmmer/3.4

##### Pipeline ###########
mkdir CANT-HYD
### Running HMMER with CANT-HYD ###
for sample in subsampling_10M/*.faa
do
name=$(basename -s .faa $sample)
hmmsearch -E 1e-9 --incE 1e-9 --incdomE 1e-9 --tblout CANT-HYD/${name}.ALKB_MAB.hmmsearch.tblout \
/home/ddavila/projects/rrg-srijakb/ddavila/HudsonBay/HMMs/AlkB_MAB.hmm $sample > CANT-HYD/${name}.ALK_B_MAB.hmmsearch.out

hmmsearch --cut_tc --tblout CANT-HYD/${name}.CANT-HYD.hmmsearch.tblout \
/home/ddavila/projects/rrg-srijakb/ddavila/HudsonBay/HMMs/CANT-HYD.hmm $sample > CANT-HYD/${name}.CANT-HYD.hmmsearch.out
done
