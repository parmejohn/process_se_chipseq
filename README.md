# Simple pipeline for processing mice single-end, no input, ChIP-seq data

Usage

```
./process_chipseq.sh [reference].fa.gz [output folder]
```

Note that the there needs to be a SRR_ACC_List.txt file located in the output folder, which denotes the desired SRR numbers wanted

Example
If I were to download the mm10 reference, and place it in a references folder
```
./process_chipseq.sh */references/mm10.fa.gz */chipseq/
```

Dependencies
- sra-tools                 2.11.0
- samtools                  1.15.1
- picard                    2.27.4
- multiqc                   1.13a
- fastqc                    0.11.9
- bwa                       0.7.17
- macs2                     2.2.7.1

To easily install these dependencies with anaconda, use the following commands
```
conda env create -f environment.yml
conda activate process_chipseq
```
And then run the command
