library(SeqArray, lib.loc = "~/Rlibs")

#define file paths
vcf_file <- "/project/berglandlab/chlorella_sequencing/variant_calling/combined_chlorella_annotated.vcf" # nolint: line_length_linter.
gds_file <- "/project/berglandlab/chlorella_sequencing/variant_calling/combined_chlorella_annotated.gds" # nolint: line_length_linter.

#convert
seqVCF2GDS(vcf.fn = vcf_file, out.fn = gds_file, parallel = TRUE)

#open and check file
gds <- seqOpen(gds_file)
print(seqSummary(gds))
seqClose(gds)