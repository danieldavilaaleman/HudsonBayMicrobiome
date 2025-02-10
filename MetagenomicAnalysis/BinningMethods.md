# Binning tools implemented 
The output of the Megahit Co-assembly of the 18 enrichments and the single-enrichmet assemblies are the target of the binning into MAGs.

For Binning the output of MegaHit assembly, we used the tools [COMEBin](https://github.com/ziyewang/COMEBin), [SemiBin2](https://github.com/BigDataBiology/SemiBin), and [MetaDecoder](https://github.com/liu-congcong/MetaDecoder).

## COMEBIN
### Preprocessing of Assembly data
Conda environment for COMEBin was created following installation instrictions [here](https://github.com/ziyewang/COMEBin). With a few modifications:

### Installation
```
conda create -n pytorch
conda activate pytorch
CONDA_OVERRIDE_CUDA="12.2" mamba install -c conda-forge pytorch python=3.7.12
CONDA_OVERRIDE_CUDA="12.2" mamba install pytorch==1.10.1 torchvision==0.11.2 torchaudio==0.10.1 cudatoolkit=10.2 -c pytorch
CONDA_OVERRIDE_CUDA="12.2" mamba install pytorch==1.10.2 -c pytorch  ## REALLY Important that CUDA version and not cpu version of pytorch is installed
CONDA_OVERRIDE_CUDA="12.2" mamba install -c bioconda comebin
```

Then, I requested and interactive GPU environment to test that CUDA was succesfully installed
```
salloc -N1 -n1 -c4 --mem=25gb --gres=gpu:1 -p bigmem -t 00:10:00
```

Then crete a python file using nano (est.cuda.gpu.py):

```
#! /usr/bin/env python 
# -------------------------------------------------------
import torch
# -------------------------------------------------------
print("Defining torch tensors:")
x = torch.Tensor(5, 3)
print(x)
y = torch.rand(5, 3)
print(y)

# -------------------------------------------------------
# let us run the following only if CUDA is available
if torch.cuda.is_available():
    print("CUDA is available.")
    x = x.cuda()
    y = y.cuda()
    print(x + y)
else:
    print("CUDA is NOT available.")

# -------------------------------------------------------
```

The output of the test should be ```CUDA is available```

### Preprocessing

1. Using `COMEBin/scripts/gen_cov_file.sh` to generate coverage information. Coverage information is required as input for COMEBin (-p). The input is the assembly file, followed by the reads of all of the samples that went into the assmebly.

Single-enriched assemblies and the co-assembly of the 18 enrichments were binned independently using COMEBin. Starting with the co-assembly:

First step is to remove the contigs lower than 1,000 bp using the auxiliary scripts in `COMEBin/scripts` followed by generating .bam files required for COMEBin:

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
conda activate pytorch

####### Run your script #########################
python ~/software/COMEBin/COMEBin/scripts/Filter_tooshort.py ../MegaHIT_Coassembly/All_Coassembly_megahit_out/final.contigs.fa 1000

# COMEBin bam generation files for binning. I copied and unzip fastq.gz files of the reads for this command.
bash ~/software/COMEBin/COMEBin/scripts/gen_cov_file.sh -a final.contigs_1000.fa \
-o comebine.coassembly.bamfiles -f _R1.fastq -r _R2.fastq *fastq -t 20 -m 45 -l 1000

```

The python filter script generates `contig_lengrh_filter1000.txt` with the list of contiguous name and length, and the file `final.contigs_1000.fa` that is the input to generate bam file.

Final.contigs_1000.fa contains ***110,949 contigs.***

The next step was to generate *.bam* files of each sample fastq files to the filtered Co-Assembly fasta file **final.contigs_1000.fa**

```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=08:00:00
#SBATCH --mem=50G
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate comebin

####### Run your script #########################
#python ~/software/COMEBin/COMEBin/scripts/Filter_tooshort.py ../MegaHIT_Coassembly/All_Coassembly_megahit_out/final.contigs.fa 1000

bash ~/software/COMEBin/COMEBin/scripts/gen_cov_file.sh -a final.contigs_1000.fa \
-o comebine.coassembly.bamfiles -f _R1.fastq -r _R2.fastq R3_E1_qc_R* -t 40 -m 50 -l 1000
```

After getting all the *.bam* files (mapping each sample read pairs to the filtered co-assembly), **COMEBin** command:

```
#!/bin/bash
####### Reserve computing resources #############
#SBATCH --time=12:00:00
#SBATCH --mem=50G
#SBATCH --partition=bigmem
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5

####### Set environment variables ###############
source ~/software/miniconda3/etc/profile.d/conda.sh
conda activate pytorch
nvidia-smi

####### Run your script #########################
run_comebin.sh -a final.contigs_1000.fa \
-p comebine.coassembly.bamfiles/work_files/ \
-o COMEBin_output \
-n 6 \
-t 48
```










