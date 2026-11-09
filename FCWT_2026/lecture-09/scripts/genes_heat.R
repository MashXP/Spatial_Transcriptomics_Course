#!/usr/bin/env Rscript
# genes_heat.png — the 10 genes from the table slide, as tiles.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/genes_heat.R

library(ggplot2)

# TPM: mean of 4 tumor-core spots and 4 control spots, per gene
wide <- data.frame(
  gene    = c("MKI67", "CDKN2A", "EPCAM", "KRT19", "CDH1",
             "VIM", "PTPRC", "CD3E", "CD8A", "GAPDH"),
  Control = c(3.0, 2.0, 6.0, 4.0, 5.0, 8.0, 214.5, 96.8, 70.0, 1010.8),
  Tumor   = c(482.5, 190.0, 323.8, 209.0, 151.0, 262.0, 6.0, 2.6, 1.9, 997.8)
)

long <- tidyr::pivot_longer(wide, cols = -gene,
                            names_to = "condition", values_to = "tpm")
long$gene      <- factor(long$gene, levels = rev(wide$gene))
long$condition <- factor(long$condition, levels = c("Control", "Tumor"))

p <- ggplot(long, aes(condition, gene, fill = tpm)) +
  geom_tile() +
  geom_text(aes(label = tpm), size = 3) +
  scale_fill_viridis_c(trans = "log10", name = "TPM") +
  labs(title = "10 genes, tumor vs control", x = NULL, y = NULL) +
  theme_minimal()

ggsave("_assets/genes_heat.png", p, width = 5.6, height = 3.2, dpi = 200)
