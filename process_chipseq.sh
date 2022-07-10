#!/bin/bash
##### This script processes H3K27ac ChIP-seq data from https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60103 #####
### first arguement will be the full path of the reference genome, and the second argument is the full path of where you want the output to be ###

### hard coded path
mm10reference=${1}

### change output file to where u have the SRR_ACC_List stored
### this will also be the location of all the output files
output=${2}

mkdir $output/MACS2
mkdir $output/MACS2/no_input
mkdir $output/no_input
mkdir $output/FastQC
mkdir $output/MultiQC

no_input=$output/no_input

### number of threads to use for these functions
t=4

### download fastq files from NCBI 
### fetch the SRA files needed -> put the list into the $output folder
prefetch --option-file $output/SRR_Acc_List.txt

### putting files into no_input folder
while IFS=: read -r line|| [ -n "$line" ];do
	fastq-dump --split-files --outdir $no_input --gzip $line;
done < $output/SRR_Acc_List.txt

### generate QC reports
fastqc $output/*input/*fastq.gz -t $t -o $output/FastQC
multiqc $output/FastQC/*_fastqc.zip -o $output/MultiQC

echo "### CAN RENAME FILES TO INCLUDE CELL TYPE, HISTONE MARK, etc (ex. SRR1521823_1_CLP_1_H3K27ac) ###"
echo "### CHECK MULTIQC REPORT ###"
read -p "Press [Enter] key to resume..."

### index the reference files
bwa index $mm10reference

### alignment for single-end reads
for FILE in $no_input/*.fastq.gz;do
	x=${FILE##*/};
	bwa mem -t $t $mm10reference $FILE | gzip -3 > $no_input/${x%.fastq.gz}.sam.gz;
done

### convert sam.gz/sam to bam with samtools
for FILE in $no_input/*.sam.gz;do
	x=${FILE##*/};
	samtools view -@ $t -S -b $FILE > $no_input/${x%.sam.gz}.bam;
done

### sort bam files
for FILE in $no_input/*.bam;do
	x=${FILE##*/};
	samtools sort $FILE -o $no_input/${x%.bam}.sorted.bam -@ $t;
done

### index bam files
for FILE in $no_input/*.sorted.bam;do
	samtools index $FILE -@ $t;
done

### picard duplicate marking. This command flags PCR duplicates in bam file
for FILE in $no_input/*.sorted.bam;do
	x=${FILE##*/};
	picard MarkDuplicates I=$FILE O=$no_input/${x%.sorted.bam}.sorted.dupsMarked.bam M=$no_input/${x%.sorted.bam}.sorted.dupsMarked.metrics.txt;
done

### index bam files
for FILE in $no_input/*.sorted.dupsMarked.bam;do
	samtools index $FILE -@ $t;
done

### flagstat
for FILE in $no_input/*.sorted.dupsMarked.bam;do
	x=${FILE##*/};
	samtools flagstat -@ $t $FILE > $output/${x%}.flagstat;
done

### remove intermediate files
rm $no_input/*.sam.gz $output/*input/*.sorted.bam $output/*input/*.sorted.bam.bai

### macs2; no input
arr=($no_input/*.sorted.dupsMarked.bam)

for ((i=0; i<${#arr[@]}; i+=1)); do
	#do something to each element of array
	macs2 callpeak -B -t ${arr[$i]} -f BAM -n ${arr[$i]}.noInput -g mm --call-summits --outdir $output/MACS2/;
done

mv $no_input/*.noInput_* $output/MACS2/no_input

echo "ChIP-seq processing done"
