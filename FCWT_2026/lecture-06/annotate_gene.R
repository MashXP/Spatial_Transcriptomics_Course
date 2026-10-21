# annotate_gene.R
#
# Input : counts_sample_name_merge.tsv   (gene-by-sample, columns already renamed)
# Ref   : Human.GRCh38.p13.annot.tsv      (GeneID -> Symbol, Description, ...)
# Output: counts_annotated.tsv
#
# The counts matrix is keyed by Entrez GeneID in its row names. To attach
# symbols we look up each row name in the reference and keep the original
# row order - match() does that; merge() would re-sort and lose it.

library(here)

counts_dir <- here("FCWT_2026", "lecture-06", "counts")
counts_file <- file.path(counts_dir, "counts_sample_name_merge.tsv")
annot_file  <- file.path(counts_dir, "Human.GRCh38.p13.annot.tsv")
out_file    <- file.path(counts_dir, "counts_annotated.tsv")

counts <- read.delim(counts_file, row.names = 1)
annot  <- read.delim(annot_file)

# Where does each counted gene sit in the reference table?
idx <- match(rownames(counts), annot$GeneID)

cat("genes in counts      :", nrow(counts), "\n")
cat("matched in reference :", sum(!is.na(idx)), "\n")
cat("unmatched            :", sum(is.na(idx)), "\n")

stopifnot(all(!is.na(idx)))   # stop early rather than write a half-annotated file

# Attach the annotation, keeping GeneID as the first column.
annotated <- data.frame(
  GeneID      = rownames(counts),
  Symbol      = annot$Symbol[idx],
  # Description = annot$Description[idx],
  # GeneType    = annot$GeneType[idx],
  # EnsemblGeneID = annot$EnsemblGeneID[idx],
  counts,
  row.names = NULL,
  check.names = FALSE
)

write.table(annotated, out_file, sep = "\t", row.names = FALSE, quote = FALSE)
cat("written:", out_file, "\n")
