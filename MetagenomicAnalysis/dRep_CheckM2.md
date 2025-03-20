# Dereplication using dRep
Due to dRep uses CheckM1 for Genome quality assessment before dereplication, I extracted the Medium quality bins (Completeness >70%, contamination <5%) got it using CheckM2 to a new directory before running dRep.

To copy all the medium quality MAGs to a new directory, I created a file with all the quality MAGs
```
cat CheckM2/allbins_quality_report_CheckM2.tsv | awk '$2 >= 70' | awk '$3 <= 5' | cut -f1 > Medium.HQ.bins/list.medium.hq.bins.txt
```

Then I use a loop to copy all the MAGs in the new direcotry
```
for mag in `cat list.medium.hq.bins.txt`
do echo "Copying ${mag}.fa to Mediuam.HQ.bins"
cp ../allbins.metaWRAP/${mag}.fa .
done

```

dRep is installed in **instrain** conda environment. Dereplicate was running using ```-comp 50 -con 20 --S_algorithm gANI --S_ani 0.95```

For dRep to completely run using gANI, I download gANI (aka ANIcalculator) and tar the file in ```~/software``` directory. Then add the executable file ANIcalculator to my PATH

dRep generates **72 bins**

To create a CheckM2 quality report of the dereplicated mags, the following command was implemented:
```
for bin in dereplicated_bins/dRep_HQ_MAGs/dereplicated_genomes/*.fa; do magname=$(basename $bin .fa); echo $(grep -w "$magname" CheckM2/allbins_quality_report_CheckM2.tsv) >> dereplicated_mags_quality_report.CheckM2; done
```











