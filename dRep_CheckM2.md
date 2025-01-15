Due to dRep uses CheckM1 for Genome quality assessment before dereplication, I extracted Medium quality bins (Completeness >70%, contamination <5%) to a new directory before running CheckM1.

To copy all the medium quality MAGs to a new directory, I created a file with all the quality MAGs
```
cat Output/quality_report.tsv | awk '$2 > 70' | awk '$3 < 5' | cut -f1 > list_HQ_MAGs_names.txt
```

Then I use a loop to copy all the MAGs in the new direcotry
```
for mag in `cat list_HQ_MAGs_names.txt`
do  echo "Copying $mag.fa"
cp ../All_bins/${mag}.fa HQ_MAGs/
done
```

dRep is installed in **instrain** conda environment. Dereplicate was running using ```--ignoreGenomeQuality -comp 70 -con 5 --S_algorithm gANI --S_ani 0.95```
```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=04:00:00
#SBATCH --mem=50G
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate instrain

####### Run your script #########################
dRep dereplicate -g HQ_MAGs/*.fa --ignoreGenomeQuality -comp 70 -con 5 --S_algorithm gANI --S_ani 0.95
```










