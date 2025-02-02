# Binning tools implemented 
For Binning the output of MegaHit assembly, we used the tools [COMEBin](https://github.com/ziyewang/COMEBin), [SemiBin2](https://github.com/BigDataBiology/SemiBin), 
and [MetaDecoder](https://github.com/liu-congcong/MetaDecoder).

## COMEBIN
### Preprocessing of Assembly data
Conda environment for COMEBin was created following installation istrictions [here](https://github.com/ziyewang/COMEBin)

1. Using ```COMEBin/scripts/gen_cov_file.sh`` to generate coverage information. Coverage information is required as input for COMEBin (-p). The input is the assembly file, followed by the reads of all of the samples that went into the assmebly.



