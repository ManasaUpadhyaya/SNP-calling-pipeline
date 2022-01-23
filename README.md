# Single-nucleotide-polymorphism-calling-pipeline-
Bash script that generates an output VCF file, and a file with the SNPs and indels.
Description:
The code is a SNP calling pipeline. The code first maps all the reads to an external reference genome strain and creates an alignment file. The alignment file is then processed (file sorting, sorting, alignment and improvement). The final step is the actual variant calling which generates the VCF file, and the files with the SNPs and indels.

Requirements:
1. BWA for alignment 
2. samtools/HTS package for processing and calling variants
3. GATK version 3.7.0 for improving the alignment 

Input flags:
-a Input reads file – pair 1
-b Input reads file – pair 2
-r Reference genome file
-e Perform read re-alignment
-o Output VCF file name
-f Mills file location
-z Output VCF file should be gunzipped (*.vcf.gz)
-v Verbose mode; print each instruction/command to tell the user 
what your script is doing right now
-i Index your output BAM file (using samtools index)
-h Print usage information (how to run your script and the arguments 
it takes in) and exit

Output files:
VCF file, summary file of SNPs and Indels, log file.
