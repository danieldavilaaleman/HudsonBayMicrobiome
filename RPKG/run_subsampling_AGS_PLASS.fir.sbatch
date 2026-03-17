#!/bin/bash
#SBATCH --mem=150G
#SBATCH --cpus-per-task=8
#SBATCH --ntasks-per-node=24
#SBATCH --time=05-00:00:00
#SBATCH --account=rrg-chubert

####### Set environment variables ###############
## Add color to the echo messages
BOLD_GREEN='\033[1;33m'
NC='\033[0m'

###### Pre-processing #########
module load seqkit/

##### Pipeline ###########
mkdir subsampling_10M
## Downsampling 10M reads from R1###
for file in *_1.fastq.gz
do
name=$(basename -s _1.fastq.gz $file)
echo -e "${BOLD_GREEN}Downsampling sample R1 $name to 10M reads${NC}"
seqkit sample -p 0.9 ${name}_1.fastq.gz | seqkit seq -m 100 | seqkit head -n 10000000 > subsampling_10M/${name}.10M_1.fastq 
echo -e "${BOLD_GREEN}File $file downsampled${NC}"
echo -e "${BOLD_GREEN}File $file stats${NC}"
seqkit stats -a subsampling_10M/${name}.10M_1.fastq

echo -e "${BOLD_GREEN}Downsampling sample R2 $name to 10M reads${NC}"
seqkit sample -p 0.9 ${name}_2.fastq.gz | seqkit seq -m 100 | seqkit head -n 10000000 > subsampling_10M/${name}.10M_2.fastq 
echo -e "${BOLD_GREEN}File $file downsampled${NC}"
echo -e "${BOLD_GREEN}File $file stats${NC}"
seqkit stats -a subsampling_10M/${name}.10M_2.fastq
done

## Run MicrobeCensus on 10M reads subsampling ##
module load python/3.11
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install -r ~/requirements.txt

for file in subsampling_10M/*.10M_1.fastq
do
filename=$(basename -s .10M_1.fastq $file)
echo -e "${BOLD_GREEN}Running MicrobeCensus in $filename${NC}"
run_microbe_census.py -t 60 -v subsampling_10M/${filename}.10M_1.fastq,subsampling_10M/${filename}.10M_2.fastq subsampling_10M/${filename}.AGS.out
echo -e "${BOLD_GREEN}DONE${NC}"
done

## Run PLASS Assembly ##
for file in subsampling_10M/*.10M_1.fastq
do
filename=$(basename -s .10M_1.fastq $file)
echo -e "${BOLD_GREEN}Running PLASS Assembly in $filename${NC}"
plass assemble subsampling_10M/${filename}.10M_1.fastq subsampling_10M/${filename}.10M_2.fastq subsampling_10M/${filename}.plass_assembly.faa tmp --translation-table 11 --min-length 30
echo -e "${BOLD_GREEN}DONE with $file.${NC}"
done
