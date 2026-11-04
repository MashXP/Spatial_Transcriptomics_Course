#!/usr/bin/env Rscript
# spearman_hot.png — the same 8 spots with the last spot at 500 counts, drawn as
# ranks. The hot spot is the highest gene A count, so it keeps rank 8: the
# diagonal is untouched and rho stays 1. The pink dot is the hot spot.
# Used on the split slide after "The caveat".
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/spearman_hot.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

gene_a_hot <- c(12, 15, 18, 22, 25, 31, 34, 500)
gene_b     <- c(9, 11, 14, 18, 21, 26, 29, 34)

rank_a <- rank(gene_a_hot)
rank_b <- rank(gene_b)

# hand-set canvas: ranks 1..8
x_lo <- 0.4
x_hi <- 8.7
y_lo <- 0.4
y_hi <- 8.7

p_hot_rank <- ggplot(data.frame(rank = rank_a, value = rank_b),
                     aes(x = rank, y = value)) +
  plot_base("Spearman: the order is untouched",
            x_breaks = 1:8, x_limits = c(x_lo, x_hi),
            y_breaks = 1:8, y_limits = c(y_lo, y_hi)) +
  labs(x = "rank of gene A", y = "rank of gene B") +
  # the same diagonal as the clean data: the hot spot is still the highest
  annotate("segment", x = 1, xend = 8, y = 1, yend = 8,
           colour = accent, linewidth = 0.4) +
  annotate("text", x = 1.4, y = 6.8, hjust = 0, size = 2.6,
           colour = accent, label = "rho = 1") +
  geom_point(size = 2, colour = text, fill = text) +
  # the hot spot in the accent colour, at rank 8
  geom_point(data = data.frame(rank = 8, value = 8),
             aes(x = rank, y = value), size = 2, colour = accent, fill = accent) +
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_hot_rank, "spearman_hot.png")

cat("ranks gene A (hot):", rank_a, "\nranks gene B:", rank_b, "\n")
