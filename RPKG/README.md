# Hydrocarbon degradation gene count normalized by Genome Equivalence

Steps:

1. Subsampling 10M Reads per database (tara oceans, tara polar, mmDB, mmDB Arctic, and Cao *et al*)
2. Reads assembly to protein sequences using PLASS
3. hmmsearch for hydrocarbon degradation using CANT-HYD
4. Run MicrobeCensus using the subsampled 10M reads to get Genome Equivalence 
5. Normalized the number of hits by Genome Equivalence
