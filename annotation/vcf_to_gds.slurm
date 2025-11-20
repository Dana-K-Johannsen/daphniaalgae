#!/bin/bash
#SBATCH --job-name=snpeff_chlorella
#SBATCH -o /scratch/gpk3qr/erroroutputs/snpeff.%A.out
#SBATCH -e /scratch/gpk3qr/erroroutputs/snpeff.%A.err
#SBATCH --time=08:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --partition=standard

module load R   
Rscript vcf_to_gds.R