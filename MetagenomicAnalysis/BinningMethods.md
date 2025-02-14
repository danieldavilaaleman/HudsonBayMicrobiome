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

Then crete a python file using nano ```scripts/test.cuda.gpu.py```

The output of the test should be ```CUDA is available```

### Pre-processing

Using `COMEBin/scripts/gen_cov_file.sh` to generate coverage information. Coverage information is required as input for COMEBin (-p). The input is the assembly file, followed by the reads of all of the samples that went into the assmebly. **NOTE: that the output are sorted bam files, whichc can be used in SemiBin2 and MEtaDecoder**

Single-enriched assemblies and the co-assembly of the 18 enrichments were binned independently using COMEBin. Starting with the co-assembly:

First step is to remove the contigs lower than 1,000 bp using the auxiliary scripts in `COMEBin/scripts` followed by generating .bam files required for COMEBin. 
```scripts/run_preprocessing_comebin.sbatch```

The python filter script generates ```contig_lengrh_filter1000.txt``` with the list of contiguous name and length, and the file ```final.contigs_1000.fa``` that is the input to generate bam file.

Final.contigs_1000.fa contains ***110,949 contigs.***

The next step was to generate *.bam* files of each sample fastq files to the filtered Co-Assembly fasta file **final.contigs_1000.fa**
```scripts/run_mapping_comebin.sbatch```

After getting all the *.bam* files (mapping each sample read pairs to the filtered co-assembly), **COMEBin** binning was run using ```scripts/run_binning_comebin.sbatch```

***Note***: Increasing the memory to 300 Gb solve the issue that Comebin pipeline stuck and finish the pipeline

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
To run SemiBin2, ```scripts/run_semibin.sbatch```

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

Then, MetaDecoder was run using ```scripts/run_metadecoder.sbatch```

##### NOTE: I encountered an error during ```metadecoder seed``` due to restrcition permission in ``` miniconda3/envs/metadecoder/lib/python3.9/site-packages/metadecoder/fraggenescan``` so the following step was ```chmod -R 777 miniconda3/envs/metadecoder/lib/python3.9/site-packages/metadecoder``` and that solved the problem.

MetaDecoder identified **139 bins!**

# DasTool

The next step is binning refinement of the three different bin sets using [DasTool](https://github.com/cmks/DAS_Tool). The output bins are dereplicated!

### Installation 

```
conda create -n dastool -c bioconda das_tool
das_tool version 1.1.7-1 has been successfully installed!                                                                                                
                                                                                                                                                         
This version uses DIAMOND as default alignment tool. As an alternative, USEARCH can be installed from the following links                                
                                                                                                                                                         
 > Download: http://www.drive5.com/usearch/download.html                                                                                                 
 > Installation instruction: http://www.drive5.com/usearch/manual/install.html                                                                           
                                                                                                                                                         
                                                                                                                                                         
done
```
### Preparation of input files and running Das_Tool
A contig-ID and bin-ID file for each bin set needs to be provided. The helper script ```Fasta_to_Contigs2Bin.sh``` was used for the generation of the input tabular files for Das_Tool folowed by running DasTool ```scripts/run_dastool.sbatch```

***NOTE:*** DAS_Tool can not use number as name of the bin (COMEBin), so the name of the bin was changed inside COMEBin bin directory as follow:
```
for file in *.fa; do echo $file; mv $file contig.$file ; done
```

I sed **CheckM2** for checking the HQ MAGs resulted from DASTool and got **30 MAGs** Completeness > 70% Contamination < 5%

## MetaWRAP
The second option was refinning *COMEBin, SemiBin2, MetDecoder* bins using ```metawrap refinement``` module using ```script/run_metawrap.sbatch``` and got **44 MAGs** Completeness > 70 % Contamination < 5 %.






















