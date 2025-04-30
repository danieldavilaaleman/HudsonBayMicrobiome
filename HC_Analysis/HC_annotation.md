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
