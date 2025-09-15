#!/usr/bin/env bash
#
#SBATCH -J download_SRA # A single job name for the array
#SBATCH --ntasks-per-node=10 # one core
#SBATCH -N 1 # on one node
#SBATCH -t 6:00:00 ### 6 hours
#SBATCH --mem 10G
#SBATCH -o /scratch/gpk3qr/compBio/logs/prefetch.%A_%a.out # Standard output
#SBATCH -e /scratch/gpk3qr/compBio/logs/prefetch.%A_%a.err # Standard error
#SBATCH -p standard
#SBATCH --account berglandlab_standard

wd=/scratch/qpk3qr/compBio
### run as: sbatch --array=1-$( wc -l < /project/berglandlab/Dana/metadata/oldalgaepaths.csv )%10 ~/daphnia_algae/downloadSRA.sh
### sacct -j 64052181
### cat /scratch/gpk3qr/compBio/logs/prefetch.52222298_*.out | grep -B1 "do not"
### cat /scratch/gpk3qr/compBio/logs/prefetch.52222298_52.out

module load gcc/11.4.0 sratoolkit/3.1.1 


# cat /home/gpk3qr/CompEvoBio_modules/data/runs.csv | nl | grep "SRR1988514"


sranum=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /project/berglandlab/Dana/metadata/oldalgaepaths.csv | cut -f8 -d',' )
sampName=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /project/berglandlab/Dana/metadata/oldalgaepaths.csv | cut -f8 -d',' )
#proj=$( sed "${SLURM_ARRAY_TASK_ID}q;d" ~/metadata/runs_missing.csv | cut -f2 -d',' )

echo $sampName " / " $sranum

### sranum=SRR1184609; proj=PRJNA194129

if [ ! -d "/scratch/gpk3qr/compBio/fastq/" ]; then
  mkdir /scratch/gpk3qr/compBio/fastq/
fi

if [ ! -d "/scratch/gpk3qr/compBio/fastq/${sranum}" ]; then
  mkdir /scratch/gpk3qr/compBio/fastq/${sranum}
fi

if ls /scratch/gpk3qr/compBio/fastq/${sranum}*fastq.gz 1> /dev/null 2>&1; then
    echo "files do exist"
else
  echo "files do not exist"

  echo "force re-download"
  prefetch \
  -o /scratch/gpk3qr/compBio/sra/${sranum}.sra \
  -p \
  ${sranum}


  fasterq-dump \
  --split-files \
  --split-3 \
  --outfile /scratch/gpk3qr/compBio/fastq/${sranum}/${sranum} \
  -e 10 \
  -p \
  --temp /scratch/gpk3qr/tmp \
  /scratch/gpk3qr/compBio/sra/${sranum}.sra

  ls -lh /scratch/gpk3qr/compBio/fastq/${sranum}

fi

if [ -f "/scratch/gpk3qr/compBio/fastq/${sranum}_1.fastq" ]; then
  gzip /scratch/gpk3qr/compBio/fastq/${sranum}_1.fastq
  gzip /scratch/gpk3qr/compBio/fastq/${sranum}_2.fastq
fi

if [ -f "/scratch/gpk3qr/compBio/fastq/${sranum}" ]; then
  gzip -c /scratch/gpk3qr/compBio/fastq/${sranum} > /scratch/gpk3qr/compBio/fastq/${sranum}.fastq.gz
  rm /scratch/gpk3qr/compBio/fastq/${sranum}
fi

rm /scratch/gpk3qr/fastq/${sranum}.sra
#cat /home/gpk3qr/CompEvoBio_modules/data/runs.csv | nl | grep "SRR12463313"
