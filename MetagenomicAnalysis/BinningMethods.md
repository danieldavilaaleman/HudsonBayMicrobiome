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

1. Using `COMEBin/scripts/gen_cov_file.sh` to generate coverage information. Coverage information is required as input for COMEBin (-p). The input is the assembly file, followed by the reads of all of the samples that went into the assmebly. **NOTE: that the output are sorted bam files, whichc can be used in SemiBin2 and MEtaDecoder**

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
#SBATCH --mem=300G  # Need to increase the memory, if not is going to stuck 
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

Increasing the memory to 300 Gb solve the issue and finish the pipeline

COMEBin results:

```
Run unitem profile:	77

Followed by CheckM and then:

2025-02-11 18:14:23,074 - Final result:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/cluster_res/Leiden_bandwidth_0.1_res_maxedges100respara_5_partgraph_ratio_80.tsv
2025-02-11 18:14:23,075 - Processing file:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/final.contigs_1000.fa
2025-02-11 18:14:23,474 - Reading Map:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/cluster_res/Leiden_bandwidth_0.1_res_maxedges100respara_5_partgraph_ratio_80.tsv
Processing file:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/final.contigs_1000.fa
Reading Map:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/cluster_res/Leiden_bandwidth_0.1_res_maxedges100respara_5_partgraph_ratio_80.tsv.filtersmallbins_200000.tsv
Writing bins:	/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/Binning_Coassembly/COMEBin_output/comebin_res/comebin_res_bins
```

The total number of bins in ```/COMEBin_output/comebin_res/comebin_res_bins``` is **218!**

# SemiBin2

### Installation
Followed the same approach as before with COMEBin

```
conda create -n semibin
conda activate semibin
CONDA_OVERRIDE_CUDA="12.2" mamba install -c conda-forge -c pytorch pytorch python=3.9
CONDA_OVERRIDE_CUDA="12.2" mamba install -c conda-forge -c bioconda semibin=2.1.0 # I have to specify the version of SemiBin, if not downgrade Semibin to version 0.2
```
To run SemiBin2:
```
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
```

The output of SemiBin2 was:

```
[2025-02-11 13:55:31,089] INFO: Setting number of CPUs to 80
[2025-02-11 13:55:31,089] INFO: Binning for short_read
[2025-02-11 13:56:05,079] INFO: Running with GPU.
[2025-02-11 13:56:08,545] INFO: Generating training data...
[2025-02-11 14:06:51,933] INFO: Calculating coverage for every sample.
[2025-02-11 14:51:49,038] INFO: Processed: /scratch/33830640/allEnrichMappedCoassembly.bam
[2025-02-11 14:52:15,678] INFO: Start binning.
[2025-02-11 14:56:24,343] INFO: Number of bins prior to reclustering: 141
[2025-02-11 14:56:27,093] INFO: Running naive ORF finder
[2025-02-11 15:08:39,566] INFO: Number of bins after reclustering: 146
[2025-02-11 15:08:39,727] INFO: Binning finished
```


# MetaDecoder

To install metadecoder, a conda environment was created using:

```
conda create -n metadecoder
conda activate metadecoder
mamba install python=3.9 numpy scipy scikit-learn threadpoolctl
pip3 install -U https://github.com/liu-congcong/MetaDecoder/releases/download/v1.1.0/metadecoder-1.1.0-py3-none-any.whl
pip3 install cupy-cuda101
```







