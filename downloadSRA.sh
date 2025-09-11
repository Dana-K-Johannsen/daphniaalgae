#!/usr/bin/env bash
#
#SBATCH -J download_SRA # A single job name for the array
#SBATCH --ntasks-per-node=10 # one core
#SBATCH -N 1 # on one node
#SBATCH -t 6:00:00 ### 6 hours
#SBATCH --mem 10G
#SBATCH -o /scratch/aob2x/compBio/logs/prefetch.%A_%a.out # Standard output
#SBATCH -e /scratch/aob2x/compBio/logs/prefetch.%A_%a.err # Standard error
#SBATCH -p standard
#SBATCH --account berglandlab_standard

# will need to set this to your own directory- project? scratch?
wd=/scratch/aob2x/compBio
# will need to change this as well --> what is this line doing? (setting up a slurm job/bioinformatics type situation)
### run as: sbatch --array=1-$( wc -l < ~/CompEvoBio_modules/data/runs_missing.csv )%10 ~/CompEvoBio_modules/utils/getSRA/downloadSRA.sh
### sacct -j 64052181
### cat /scratch/aob2x/compBio/logs/prefetch.52222298_*.out | grep -B1 "do not"
### cat /scratch/aob2x/compBio/logs/prefetch.52222298_52.out

#loading necessary packages for genome stuff
module load gcc/11.4.0 sratoolkit/3.0.3 aspera-connect/4.2.4

#will this number need to change?
#SLURM_ARRAY_TASK_ID=194
#change this
# cat /home/aob2x/CompEvoBio_modules/data/runs.csv | nl | grep "SRR1988514"
# SLURM_ARRAY_TASK_ID=1

#change all of these pathways
#these three lines are being used to extract specific values from CSV files
#takes the first column of the line corresponding to the current array task ID and stores it as sranum
sranum=$( sed "${SLURM_ARRAY_TASK_ID}q;d" ~/CompEvoBio_modules/data/runs_missing.csv | cut -f1 -d',' )
#why is this line the same as the preceding line?
sampName=$( sed "${SLURM_ARRAY_TASK_ID}q;d" ~/CompEvoBio_modules/data/runs_missing.csv | cut -f1 -d',' )
#grabbing the SECOND, not the first, column from the same line
proj=$( sed "${SLURM_ARRAY_TASK_ID}q;d" ~/CompEvoBio_modules/data/runs_missing.csv | cut -f2 -d',' )

#prints out the three values to the terminal
echo $sampName " / " $sranum " / " $proj

#potential values for these variables?
### sranum=SRR1184609; proj=PRJNA194129

#checking if this directory (change) does NOT exist (using the value of proj), and if it doesn't, the directory gets created
if [ ! -d "/scratch/aob2x/compBio/fastq/${proj}" ]; then
  mkdir /scratch/aob2x/compBio/fastq/${proj}
fi

#this block checks if FASTQ files for a given sample already exist, and if they don't, the raw sequncing data is downloaded and converted via SRA toolkit
if ls /scratch/aob2x/compBio/fastq/${proj}/${sranum}*fastq.gz 1> /dev/null 2>&1; then
    echo "files do exist"
else
  echo "files do not exist"

  echo "force re-download"
  #downloads SRA file
  prefetch \
  -o /scratch/aob2x/compBio/sra/${sranum}.sra \
  -p \
  ${sranum}

#converts SRA to fastq file
  fasterq-dump \
  --split-files \
  --split-3 \
  --outfile /scratch/aob2x/compBio/fastq/${proj}/${sranum} \
  -e 10 \
  -p \
  --temp /scratch/aob2x/tmp \
  /scratch/aob2x/compBio/sra/${sranum}.sra

  ls -lh /scratch/aob2x/compBio/fastq/${proj}/${sranum}*

fi
#compresses the file (one that was either preexisting or made in the previous lines)
if [ -f "/scratch/aob2x/compBio/fastq/${proj}/${sranum}_1.fastq" ]; then
  gzip /scratch/aob2x/compBio/fastq/${proj}/${sranum}_1.fastq
  gzip /scratch/aob2x/compBio/fastq/${proj}/${sranum}_2.fastq
fi
#how is this block different from the one above> 
if [ -f "/scratch/aob2x/compBio/fastq/${proj}/${sranum}" ]; then
  gzip -c /scratch/aob2x/compBio/fastq/${proj}/${sranum} > /scratch/aob2x/compBio/fastq/${proj}/${sranum}.fastq.gz
  #deletes the original file if the compression was successful
  rm /scratch/aob2x/compBio/fastq/${proj}/${sranum}
fi
#cleanup once the original SRA file is no longer needed (it's been converted to fastq.gz)
#rm /scratch/aob2x/fastq/${sranum}.sra
#outputs CSV file
cat /home/aob2x/CompEvoBio_modules/data/runs.csv | nl | grep "SRR12463313"
