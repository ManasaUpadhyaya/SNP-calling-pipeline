#!/bin/bash 
alignment=0
index=0 
while getopts "a:b:r:ef:o:zvih" OPTION
do
case $OPTION in
a) reads1=$OPTARG;;
b) reads2=$OPTARG;;
r) ref=$OPTARG;;
e) realign=1;;
f) millsFile=$OPTARG;;
z) gunzip=1;;
o) output=$OPTARG;;
v) verbose=1;;
i) index=1;;
h) echo " The a and b flags hold the input and check if the files exist; the r flag is to invoke the reference genome file; the e flag performs the realignment; the f file is for the location of the millsFile; the z flag is for unzipping; the o flag takes the output flag from the user; the index flag checks for the indexing; the verbose flag prints out every line of the command "
esac
done 
# the next set of commands are for checking if the files exist
# checking if reads 1 and 2 exists 

if [[ $verbose -eq 1 ]]; then 
echo " Checking if both the input read files exist " 
fi
if [[ $verbose -eq 1 ]]; then 
echo " Checking if Reads1 exists " 
fi

if [[ -f $reads1  ]]; then 
echo " reads1 file exists " 
else
echo " reads1 file does not exist"
exit 
fi

if [[ $verbose -eq 1 ]]; then
echo " Checking if Reads2 exists " 
fi
if [[ -f $reads2  ]]; then 
echo " reads2 file exists " 
else 
echo " reads2 file does not exist"
exit 
fi

# The next command is to check if the reference genome file exists
if [[ $verbose -eq 1 ]]; then
echo " Checking existence of reference genome file " 
fi
if [[ -f $ref  ]]; then 
echo " The reference genome file exists " 
else 
echo " The genome file doesn't exist "
exit 
fi
# if [[ -f $output.vcf.gz ]]; then 
# echo " The output file already exists. Do you want to overwrite it, if yes, enter 1. Else enter 0."
# read n

# Command to index the reference genome file
if [[ $verbose -eq 1 ]]; then 
echo " Indexing the reference genome file using BWA tool "
fi
bwa index $ref


# Creating the lane.sam file 
bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref $reads1 $reads2 > lane.sam
if [[ $verbose -eq 1 ]]; then
echo " Created the lane.sam file "
fi

# Deleting unusual FLAG information on SAM records using the fixmate tool
if [[ $verbose -eq 1 ]]; then
echo " Clearing the lane.sam file using the fixmate tools because BWA creates junk information " 
fi
samtools fixmate -O bam lane.sam lane_fixmate.bam

# Creating the tmp directory and the lane_tmp directory.
if [[ $verbose -eq 1 ]]; then 
echo " Creating the temp and lane_tmp directories" 
fi
mkdir temp
cd temp 
mkdir lane_tmp 
cd

# Sorting the file that was previously cleaned by fixmate
if [[ $verbose -eq 1 ]]; then 
echo " Sorting the lane.fixmate file" 
fi
samtools sort -O bam -o lane_sorted.bam -T ~/temp/lane_tmp lane_fixmate.bam

# Indexing the sorted lane file
if [[ $verbose -eq 1 ]]; then 
echo " Indexing the sorted lane.fixmate file" 
fi
samtools index lane_sorted.bam

# creating the .fai file and sequence dictionary 
if [[ $verbose -eq 1 ]]; then
echo "Dictionary creation after the FAI file creation" 
fi
samtools faidx $ref 
samtools dict $ref -o chr17.dict

# JAVA Commands start here

if [[ $realign -eq 1 ]]; then # realign is to check if realignment is happenning

if [[ $verbose -eq 1 ]]; then
echo "GATK COMMAND 1: Realignment begins"
fi 
java -Xmx2g -jar ~/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $ref -I ~/lane_sorted.bam -o lane.intervals -known $millsFile 2>> kupadhyaya6.log

# JAVA COMMAND TWO: INDELALIGNER
if [[ $verbose -eq 1 ]]; then 
echo "GATK COMMAND 2 Indel realigner step" 
fi
java -Xmx4g -jar ~/GenomeAnalysisTK.jar -T IndelRealigner -R $ref -I ~/lane_sorted.bam -targetIntervals lane.intervals -known $millsFile -o lane_realigned.bam 2>> kupadhyaya6.log
fi


# INDEXING THE LANE REALIGNED FILE 
if [[ $index -eq 1 ]]; then
if [[ $verbose -eq 1 ]]; then
echo " Indexing the realigned lane file " 
fi
samtools index lane_realigned.bam
fi 

# Using BCF TOOLS to create the output.vcf.gz file.
# Output file creation
if [[ $verbose -eq 1 ]]; then
echo " The output file is going to be formed using BCF tools " 
fi
bcftools mpileup -Ou -f $ref lane_realigned.bam | bcftools call -vmO z -o $output.vcf.gz

# Unzipping the output file
if [[ $gunzip -eq 1 ]]; then
if [[ $verbose -eq 1 ]]; then
echo " The output file is going to be unzipped " 
fi
gunzip -dk $output.vcf.gz
fi 








