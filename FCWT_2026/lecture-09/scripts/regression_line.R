#!/usr/bin/env Rscript
# regression_line.png — the same 8 spots with the fitted line drawn across the
# canvas. Every component of the fit is labeled: the fitted line (pink), the
# intercept where the line crosses the y axis (-2.195, gold), the slope as a
# rise-over-run triangle (0.91, gold), and R² (pink) for how tightly the dots
# sit on the line. Used on the right side of the regression slide's code.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/regression_line.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

gene_a <- c(12, 15, 18, 22, 25, 31, 34, 40)
gene_b <- c(9, 11, 14, 18, 21, 26, 29, 34)

# the fitted line: intercept -2.195, slope 0.9115
fit <- lm(gene_b ~ gene_a)
b0  <- coef(fit)[1]
b1  <- coef(fit)[2]

# hand-set canvas: the line must reach the y axis, and the intercept label needs
# room below 0, so y starts at -6
x_lo <- 0
x_hi <- 45
y_lo <- -6
y_hi <- 40

p_fit <- ggplot(data.frame(gene = gene_a, value = gene_b),
                aes(x = gene, y = value)) +
  plot_base("Regression: the fitted line",
            x_breaks = c(0, 10, 20, 30, 40), x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(y_lo, y_hi)) +
  labs(x = "gene A count (UMI)", y = "gene B count (UMI)") +
  # the fitted line, drawn from the y axis across the canvas
  annotate("segment", x = x_lo, xend = x_hi,
           y = b0 + b1 * x_lo, yend = b0 + b1 * x_hi,
           colour = accent, linewidth = 0.4) +
  # the intercept: where the line crosses the y axis, below 0
  annotate("segment", x = 0, xend = 0, y = y_lo, yend = y_hi,
           colour = gold, linewidth = 0.4) +
  annotate("text", x = 0.9, y = b0 - 2.6, hjust = 0, size = 2.6,
           colour = gold, label = "intercept = -2.195") +
  # the slope: the rise over a run of 10 counts
  annotate("segment", x = 30, xend = 40, y = b0 + b1 * 30,
           yend = b0 + b1 * 40, colour = gold, linewidth = 0.4) +
  annotate("segment", x = 40, xend = 40, y = b0 + b1 * 40,
           yend = b0 + b1 * 30, colour = gold, linewidth = 0.4) +
  annotate("text", x = 35, y = b0 + b1 * 30 - 2.6, hjust = 1, size = 2.6,
           colour = gold, label = "slope = 0.91") +
  # how tightly the dots sit on the line
  annotate("text", x = 6, y = 37, hjust = 0, size = 2.6,
           colour = accent, label = "R² = 0.9988 — the dots sit on the line") +
  geom_point(size = 2, colour = text, fill = text) +
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_fit, "regression_line.png")

cat("intercept", round(b0, 4), "slope", round(b1, 4),
    "R² =", round(summary(fit)$r.squared, 4), "\n")
