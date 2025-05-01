#! /bin/bash
#SBATCH --time=2-12:00:00
#SBATCH --account=def-srijakb
#SBATCH --cpus-per-task=12
#SBATCH --mem=10G

while read -r line
do
echo "Downloading sequence $line"
wget $line
echo "DONE"
done < sequences_path_wget.txt
