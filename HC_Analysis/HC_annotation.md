# Hydrocarbon analysis
## Bin annotation
The first step for the identification of hydrocarbon degrading genes in reconstructed bins is gene annotation using [Prodigal](https://github.com/hyattpd/Prodigal).  

After gene annotation, HMM from [CANT-HYD](https://github.com/dgittins/CANT-HYD-HydrocarbonBiodegradation) were implemented for hydrocarbon degrading genes identification using trusted cut off parameter.

A Snakefile was created for performing the gene annotation and identification of hydrocarbon degrading genes. You can find it on ```HC_Analysis/scripts/Snakefile```

For creating the config.yaml file for snakemake pipeline, the following command was run:
```
echo "Bins:" > config.yaml
basename -s .fa $(ls -1 ../allbins.metaWRAP/*.fa) | sed 's/$/:/g' > bins.names.txt
ls -1 ../allbins.metaWRAP/*.fa > complete.txt
paste bins.names.txt complete.txt -d "," | sed 's/^/  /g' | sed 's/,/  /g' >> config.yaml
```
After analysis is performed, the results were inspected using

```
for i in hmmsearch.AlkB_MAB*.tblout; do echo "file: $i" ; read -n 1 -s -r -p "" key; if [["$key" != " " ]]; then echo; echo "Exiting loop."; break; fi; echo ; bat $i; done
```

## Enrichment annotation

For enrichments, I performed plass assembly of **all** Clean reads using this Snakefile
```
configfile: "config.yaml"

samples = list(config["samples"].keys()) ## Get the keys of the config dictionary ##

rule all: ## Run all the rules - set as input the final results that you need ##
    input:
        "PLASS_output.co-assembly.faa"
        #expand("PLASS_output.{samples}", samples=samples) ## For using replicate "{samples}_R{replicate}" ##

rule create_mmseqs_DB:
    input:
        r1="/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/CleanData/Enrichments_gz/{samples}_qc_R1.fastq.gz",
        r2="/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/CleanData/Enrichments_gz/{samples}_qc_R2.fastq.gz"
    output:
        directory("PLASS_output.{samples}")
    conda:
        "/home/franciscodaniel.davi/software/miniconda3/envs/plass" ## Conda environment for plass##
    log:
        "logs/{samples}.log"
    threads:48
    shell:
        """
	    mkdir {output}
	    plass assemble {input.r1} {input.r2} {output}/{wildcards.samples}_plass_assembly.faa tmp 2> {log}
	    """

rule run_plass_coassembly:
    input:
        all_reads="/work/ebg_lab/gm/GENICE/M_Bautista/maria/GENICE/CleanData/Enrichments_gz"
    output:
        "PLASS_output.co-assembly.faa"
    conda:
        "/home/franciscodaniel.davi/software/miniconda3/envs/plass" ## Conda environment for plass##
    log:
        "logs/coassembly.log"
    threads: 48
    shell:
        """
        cat {input}/*_R1.fastq.gz > Concatenated_all_enrichment_reads_R1.fastq.gz
        cat {input}/*_R2.fastq.gz > Concatenated_all_enrichment_reads_R2.fastq.gz
        plass assemble Concatenated_all_enrichment_reads_R1.fastq.gz Concatenated_all_enrichment_reads_R1.fastq.gz {output} tmp 2> {log}
        """
```

Then, I used **hmmsearch** with both HMMs (CANT-HYD.hmm and AlkB_MAB.hmm) to look for HCD genes

```
configfile: "config.yaml"

Samples=list(config["Samples"].keys())

rule all:
    input:
        expand("cant_hyd.out/hmmsearch.{sample}.out", sample=Samples)

rule cant_hyd:
    input:
        "../plass_assemblies/{sample}_plass_assembly.faa"
    output:
        A="cant_hyd.out/hmmsearch.{sample}.out",
        B="cant_hyd.out/hmmsearch.{sample}.tblout",
        C="cant_hyd.out/hmmsearch.AlkB_MAB.{sample}.tblout",
        D="cant_hyd.out/hmmsearch.AlkB_MAB.{sample}.out"
    conda:
        "/home/franciscodaniel.davi/software/miniconda3/envs/cant_hyd"
    log:
        "logs/cant_hyd/{sample}.log"
    threads:24
    shell:
        """
        hmmsearch --cut_tc --tblout {output.B} ../../HMM/CANT-HYD.hmm {input} > {output.A} 2> {log}
        hmmsearch --incE 0.000001 --incdomE 0.000001 --tblout {output.C} ../../HMM/AlkB_MAB.hmm {input} > {output.D}
        """
```
