# Simple pipeline for processing mice, single-end, no input, ChIP-seq data

## Usage

```
./process_chipseq.sh [reference].fa.gz [output folder]
```

**Note** that there needs to be an SRR_Acc_List.txt file located in the output folder, which denotes the desired SRR accession numbers for the ChIP-seq files wanted. An example of this can be found in the ../chipseq/ folder.

Also, after downloading and running FastQC and MultiQC on the desired files, the script will stop until the Enter button is pressed, giving the user time to check the QC metrics.

### Example
If the reference were mm10 and the output folder was ../chipseq/ with an SRR_Acc_List.txt for B-cell and T-cell H3K27ac ChIP-seq data (Lara-Astiaso et al. 2014; GSE59636).

**Note** The absolute path must be used.
```
./process_chipseq.sh path_to_file/mm10.fa.gz path_to_folder/chipseq/
```

## Dependencies
- sra-tools                 2.11.0
- samtools                  1.15.1
- picard                    2.27.4
- multiqc                   1.13a
- fastqc                    0.11.9
- bwa                       0.7.17
- macs2                     2.2.7.1

## Conda Installation
To easily install these dependencies with conda, use the following commands
```
conda env create -f environment.yml
conda activate process_chipseq
```
and then feel free to run the script.

## References
Lara-Astiaso D, Weiner A, Lorenzo-Vivas E, Zaretsky I, Jaitin DA, David E, Keren-Shaul H, Mildner A, Winter D, Jung S, Friedman N, Amit I. 2014. Chromatin state dynamics during blood formation. Science 345:943–949.
