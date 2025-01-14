For updated MAGs evaluation for completeness and contamination, 
I installed [CheckM2](https://github.com/chklovski/CheckM2) 
which improves the prediction of MAGs quality using ML.

For installation:
```
git clone --recursive https://github.com/chklovski/checkm2.git && cd checkm2
mamba env create -n checkm2 -f checkm2.yml
conda activate checkm2
```

After installation, I ran CheckM2 for all bins created previously with MetaBat2
```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=01:00:00
#SBATCH --mem=20G
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate checkm2

####### Run your script #########################
~/software/checkm2/bin/checkm2 predict --threads 10 --input ../All_bins --output Output \
--database_path //work/ebg_lab/referenceDatabases/checkm2/CheckM2_database/uniref100.KO.1.dmnd
```
