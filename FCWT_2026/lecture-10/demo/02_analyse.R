# goal: mean TPM per gene, then a bar
counts <- read.table("data/counts/counts.tsv", sep = "\t", header = TRUE)
mat <- as.matrix(counts[-1])
tpm <- mat / rep(colSums(mat), each = nrow(mat)) * 1e6
mean_tpm <- data.frame(gene = counts$GeneID, tpm = rowMeans(tpm))
top <- head(mean_tpm[order(-mean_tpm$tpm), ], 20)
write.csv(top, "results/mean_tpm.csv", row.names = FALSE)

library(ggplot2)
ggsave("results/mean_tpm.png",
  ggplot(top, aes(x = reorder(factor(gene), tpm), y = tpm)) +
    geom_col() + coord_flip() + theme_minimal(),
  width = 5.4, height = 3.4)
