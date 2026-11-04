#!/usr/bin/env Rscript
# pearson_scatter.png — one dot per spot, x = gene A count, y = gene B count,
# with the fitted straight line. The dots sit on the line: the straight-line
# relationship Pearson measures. Used on the slide after "Pearson — a straight line".
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/pearson_scatter.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# the 8 spots the slides use
gene_a  <- c(12, 15, 18, 22, 25, 31, 34, 40)
gene_b  <- c(9, 11, 14, 18, 21, 26, 29, 34)

# the fitted line: intercept -2.195, slope 0.9115
fit <- lm(gene_b ~ gene_a)
b0  <- coef(fit)[1]
b1  <- coef(fit)[2]

# hand-set canvas: counts on both axes
x_lo <- 6
x_hi <- 45
y_lo <- 3
y_hi <- 39

p_pearson <- ggplot(data.frame(gene = gene_a, value = gene_b),
                    aes(x = gene, y = value)) +
  plot_base("Pearson: a straight line through the values",
            x_breaks = c(10, 20, 30, 40), x_limits = c(x_lo, x_hi),
            y_breaks = c(10, 20, 30), y_limits = c(y_lo, y_hi)) +
  # gene counts on both axes, not spot number
  labs(x = "gene A count (UMI)", y = "gene B count (UMI)") +
  # the fitted line, drawn across the canvas
  annotate("segment", x = 8, xend = x_hi,
           y = b0 + b1 * 8, yend = b0 + b1 * x_hi,
           colour = accent, linewidth = 0.4) +
  annotate("text", x = 9, y = 32, hjust = 0, size = 2.6,
           colour = accent, label = "r = 0.9994") +
  geom_point(size = 2, colour = text, fill = text) +
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_pearson, "pearson_scatter.png")

cat("clean fit: intercept", round(b0, 4), "slope", round(b1, 4),
    "r =", round(cor(gene_a, gene_b), 4), "\n")
