#!/usr/bin/env Rscript
# pearson_hot.png — the same 8 spots, with the last spot at 500 counts. The fitted
# line goes nearly flat: one extreme count pulls the line, so r drops to 0.658.
# The pink dot is the hot spot. Used on the split slide after "The caveat".
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/pearson_hot.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

gene_a_hot <- c(12, 15, 18, 22, 25, 31, 34, 500)
gene_b     <- c(9, 11, 14, 18, 21, 26, 29, 34)

# the fitted line on the hot data: intercept 17.40, slope 0.0347
fit <- lm(gene_b ~ gene_a_hot)
b0  <- coef(fit)[1]
b1  <- coef(fit)[2]

# hand-set canvas: the hot spot needs room on the right
x_lo <- 0
x_hi <- 540
y_lo <- 0
y_hi <- 40

p_hot <- ggplot(data.frame(gene = gene_a_hot, value = gene_b),
                aes(x = gene, y = value)) +
  plot_base("Pearson: one extreme count pulls the line",
            x_breaks = c(0, 100, 200, 300, 400, 500), x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(y_lo, y_hi)) +
  labs(x = "gene A count (UMI)", y = "gene B count (UMI)") +
  # the pulled line: nearly flat across the canvas
  annotate("segment", x = x_lo, xend = x_hi,
           y = b0 + b1 * x_lo, yend = b0 + b1 * x_hi,
           colour = accent, linewidth = 0.4) +
  annotate("text", x = 150, y = 34, hjust = 0, size = 2.6,
           colour = accent, label = "r = 0.658") +
  annotate("text", x = 500, y = 37, hjust = 1, size = 2.6,
           colour = fade, label = "500 counts") +
  geom_point(size = 2, colour = text, fill = text) +
  # the hot spot in the accent colour
  geom_point(data = data.frame(gene = 500, value = 34),
             aes(x = gene, y = value), size = 2, colour = accent, fill = accent) +
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_hot, "pearson_hot.png")

cat("hot fit: intercept", round(b0, 4), "slope", round(b1, 5),
    "r =", round(cor(gene_a_hot, gene_b), 3), "\n")
