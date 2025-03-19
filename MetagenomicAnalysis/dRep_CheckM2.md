# Dereplication using dRep
Due to dRep uses CheckM1 for Genome quality assessment before dereplication, I extracted the Medium quality bins (Completeness >70%, contamination <5%) got it using CheckM2 to a new directory before running dRep.

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

For dRep to completely run using gANI, I download gANI (aka ANIcalculator) and tar the file in ```~/software``` directory. Then add the executable file ANIcalculator to my PATH









