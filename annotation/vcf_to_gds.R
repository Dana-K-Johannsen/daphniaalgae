##installing and loading packages
install.packages("BiocManager")
BiocManager::install("SeqArray")
library(SeqArray)

#define file paths
vcf_file <- "/project/berglandlab/chlorella_sequencing/variant_calling/combined_chlorella_annotated.vcf"
gds_file <- "/project/berglandlab/chlorella_sequencing/variant_calling/combined_chlorella_annotated.gds"

#convert
seqVCF2GDS(vcf.fn = vcf_file, out.fn = gds_file, parallel = TRUE)

#open and check file
gds <- seqOpen(gds_file)
print(seqSummary(gds))
seqClose(gds)